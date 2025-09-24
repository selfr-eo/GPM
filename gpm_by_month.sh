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
# UPDATES - SAFR (10-09-2025)
# - monthly downloader 
#
# To run the script ./gpm_by_month.sh $year $directory

# The year to download:
yr=$1
directory=$2

# The URL, base directory
url=https://gpm1.gesdisc.eosdis.nasa.gov/opendap/hyrax/GPM_L3/GPM_3IMERGDL.07


# Function to check in the year being used is a leap or not
is_leap_year() {
  (( !(yr % 4) && (yr % 100) || !(yr % 400) ))
  }
              

download_file() {
  local month=$1          # Month (01-12)
  local day=$2          # Day of month (1-31)
  local start_time="S000000"   # Start time string (e.g., S013000)
  local end_time="E235959"     # End time string (e.g., E015959)
  local version=$3      # Version string (e.g., V07B)

  # Format day-of-year as 3-digit for folder
  local doy=$(printf "%03d" $day)
  month=$(printf "%02d" $month)

  # Construct date string for filename (mmdd)
  local mmdd=$(printf "%02d" $month)$(printf "%02d" $day)

  # Construct filename
  local file="3B-DAY.MS.MRG.3IMERG.${yr}${mmdd}-${start_time}-${end_time}.${version}"
  local file_save=${file}.nc4
  
  # Construct full URL (Daily Final data)
  local url="https://gpm1.gesdisc.eosdis.nasa.gov/opendap/hyrax/GPM_L3/GPM_3IMERGDF.07/${yr}/${month}/${file_save}.dap.nc4"
  # Use wget to download with Earthdata authentication
  if [[ ! -f "$file_save" ]]; then

    curl -n \
     -c ~/.urs_cookies \
     -b ~/.urs_cookies \
     -L \
     -o "$file_save" \
     "$url" >> "$yr_$month_$day.log" 2>&1

    # wget --load-cookies ~/.urs_cookies \
    #     --save-cookies ~/.urs_cookies \
    #     --keep-session-cookies \
    #     --no-check-certificate \
    #     --auth-no-challenge=on \
    #     --netrc \
    #     -O "$file_save" \
    #     "$url" >> "$yr_$month_$day.log" 2>&1
    
    echo "$(date +'%Y-%m-%d %H:%M:%S') Downloading $file" | tee -a "$yr_$month_$day.log"

  fi
}

              
total_months=12
# function for days in month
get_days_in_month() {
    local month=$1
    local is_leap_year=$2

    case $month in
        1|3|5|7|8|10|12)
            echo 31
            ;;
        4|6|9|11)
            echo 30
            ;;
        2)
            if [[ $is_leap_year -eq 1 ]]; then
                echo 29
            else
                echo 28
            fi
            ;;
        *)
            echo "Error: Invalid month number" >&2
            return 1
            ;;
    esac
}
      
# Main loop to combine everything:
for ((i=1; i<=$total_months; i++)); do
  # change month from 1 to 01 to match url directory:
  ii=$(printf "%02d" $i)

  # get number of days in month
  days_in_month=$(get_days_in_month $i $(is_leap_year "$yr" && echo "1" || echo "0"))

  # Check if the directory exists, create it if not, and then cd into it:
  monthpath="$directory/$yr/$ii"
  if [ -d "$monthpath" ]; then
    cd "$monthpath" || exit 1
  else
    echo "Directory $monthpath does not exist. Creating now..."
    mkdir -p "$monthpath" || { echo "Failed to create directory $monthpath" >&2; exit 1; }
    cd "$monthpath" || exit 1
  fi
  
  echo "Downloading data for days in month $ii in $yr"
  for ((j=1; j<=$days_in_month; j++)); do
    download_file "$ii" "$j" "V07B" #  month, day, version
  done
done

# wget options used:
# --load-cookies ~/.urs_cookies: This option tells wget to load cookies from the file ~/.urs_cookies before beginning any download process. It's used when the server you are connecting to uses cookies for session management.
# --save-cookies ~/.urs_cookies: This option tells wget to save any cookies it receives during the download session to ~/.urs_cookies. It's useful if you want to continue using these cookies in later sessions.
# --keep-session-cookies: Typically wget discards session cookies as they are meant to last only for single session. This option however tells wget to save session cookies as if they are permanent cookies.

# -c or --continue: This option is used to resume broken downloads, if possible. If the file was partially downloaded already, it tries to continue downloading from the point it stopped instead of starting a fresh download.
# -nc or --no-clobber: This option helps in skipping downloads that would download to existing files.
