#!/bin/bash
# Copyright 2021 ARC Centre of Excellence for Climate Extremes
#
# author: Sam Green <sam.green@unsw.edu.au>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# This script is to download 3hr V07 GPM data from gpm1.gesdisc.eosdis.nasa.gov on the NCI server
# I needed to follow https://disc.gsfc.nasa.gov/information/howto?title=How%20to%20Generate%20Earthdata%20Prerequisite%20Files 
# to set-up the prerequisite files to be able to download the data.
#
# This downloads the full day's data from 2 days from the date the script is run.
#
# Date created: 25-10-2023

# UPDATES - SAFR (29-08-2025)
# - directory now a command line input
# - version now a variable input
# - sequenceID now a variable input (more robust than index)
# - wget fields updated to be compatible running with git bash shell on windows computer
#
# To run the script ./gpm.sh $year $directory

# The year to download:
yr=$1
directory=$2

# The URL, base directory, and step size
#url=https://gpm1.gesdisc.eosdis.nasa.gov/opendap/GPM_L3/GPM_3IMERGHH.07
url=https://gpm1.gesdisc.eosdis.nasa.gov/opendap/hyrax/GPM_L3/GPM_3IMERGHH.07
#directory="/g/data/ia39/aus-ref-clim-data-nci/gpm/data/tmp"
step_size=$((30*60))
              
# Create time strings for the 30min data in the format hhmmss
# i.e. 0000000 - 003000 is 00:00:00 - 00:30:00
declare -a time_pairs
declare -a sequenceIDs

for ((time=$(date -d"today 00:00:00" +%s); time<$(date -d"today 23:59:59" +%s); time+=$step_size)); do
  start_time=$(date -d"@$time" +%H%M%S)
  end_time=$(date -d"@$((time+step_size-1))" +%H%M%S)
  time_pairs+=("$start_time,$end_time")

done

# compute sequence IDs
for ((seq=0; seq<=1410; seq+=30)); do
  sequenceIDs+=("$(printf "%04d" $seq)")
done

# Function to check in the year being used is a leap or not
is_leap_year() {
  (( !(yr % 4) && (yr % 100) || !(yr % 400) ))
  }
              

download_file() {
  #local yr=$1           # Year (e.g., 2023)
  local day=$1          # Day of year (1-365)
  local start_time=$2   # Start time string (e.g., S013000)
  local end_time=$3     # End time string (e.g., E015959)
  local sequenceID=$4   # Sequence indicator (e.g., 0000, 0030, 0060)
  local version=$5      # Version string (e.g., V07B)

  # Format day-of-year as 3-digit for folder
  local doy=$(printf "%03d" $day)

  # Construct date string for filename (mmdd)
  local dt=$(date -d "01/01/$yr +$((day-1)) days" "+%m%d")
  
  # Construct filename
  local file="3B-HHR.MS.MRG.3IMERG.${yr}${dt}-${start_time}-${end_time}.${sequenceID}.${version}.HDF5"
  local file_save=${file}.nc4
  
  # Construct full URL
  local url="https://gpm1.gesdisc.eosdis.nasa.gov/opendap/hyrax/GPM_L3/GPM_3IMERGHH.07/${yr}/${doy}/${file}.dap.nc4"
  
  # Use wget to download with Earthdata authentication
  wget --load-cookies ~/.urs_cookies \
       --save-cookies ~/.urs_cookies \
       --keep-session-cookies \
       --no-check-certificate \
       --auth-no-challenge=on \
       -O "$file_save" \
       "$url" >> "$yr_$day.log" 2>&1

  echo "$(date +'%Y-%m-%d %H:%M:%S') Downloading $file" | tee -a "$yr_$day.log"
}

# download_file() {
#   local day=$1
#   local start_time=$2
#   local end_time=$3
#   local sID=$4
#   local version=$5
#   local dt=$(date -d "01/01/$yr +$day days -1 day" "+%m%d")
#   local file="3B-HHR.MS.MRG.3IMERG.${yr}${dt}-${start_time}-${end_time}.${sID}.${version}.HDF5"
#   local file_save=${file}.nc4
#   local url="https://gpm1.gesdisc.eosdis.nasa.gov/opendap/hyrax/GPM_L3/GPM_3IMERGHH.07/${yr}/${doy}/${file}.dap.nc4"
#   wget --load-cookies ~/.urs_cookies \
#        --save-cookies ~/.urs_cookies \
#        --keep-session-cookies \
#        --no-check-certificate \
#        --auth-no-challenge=on \
#        -O "$file_save" \
#        "$url" >> "$yr_$day.log" 2>&1
#   #wget --load-cookies ~/.urs_cookies --save-cookies ~/.urs_cookies --keep-session-cookies --no-check-certificate --auth-no-challenge=on -O "$file_save" "$url" >> "$yr_$day.log" 2>&1
#   echo "$(date +'%Y-%m-%d %H:%M:%S') Downloading $file" | tee -a "$yr_$day.log"
#   }
              
# Loop either 365 or 366 depending on leap year
total_days=$(is_leap_year "$yr" && echo "366" || echo "365")
              
# Main loop to combine everything:
for ((i=1; i<=$total_days; i++)); do
  # change day from 1 to 001 to match url directory:
  ii=$(printf "%03d" $i)
  # Check if the directory exists, create it if not, and then cd into it:
  daypath="$directory/$yr/$ii"
  if [ -d "$daypath" ]; then
    cd "$daypath" || exit 1
  else
    echo "Directory $daypath does not exist. Creating now..."
    mkdir -p "$daypath" || { echo "Failed to create directory $daypath" >&2; exit 1; }
    cd "$daypath" || exit 1
  fi
              
  echo "Downloading data for day $ii in $yr"
  for ((j=0; j<${#time_pairs[@]}; j++)); do
    IFS="," read -ra time_pair <<< "${time_pairs[j]}"
    download_file "$ii" "S${time_pair[0]}" "E${time_pair[1]}" "${sequenceIDs[j]}" "V07B" #  day, start time, end time, sequence ID, version
  done
done

# wget options used:
# --load-cookies ~/.urs_cookies: This option tells wget to load cookies from the file ~/.urs_cookies before beginning any download process. It's used when the server you are connecting to uses cookies for session management.
# --save-cookies ~/.urs_cookies: This option tells wget to save any cookies it receives during the download session to ~/.urs_cookies. It's useful if you want to continue using these cookies in later sessions.
# --keep-session-cookies: Typically wget discards session cookies as they are meant to last only for single session. This option however tells wget to save session cookies as if they are permanent cookies.

# -c or --continue: This option is used to resume broken downloads, if possible. If the file was partially downloaded already, it tries to continue downloading from the point it stopped instead of starting a fresh download.
# -nc or --no-clobber: This option helps in skipping downloads that would download to existing files.
