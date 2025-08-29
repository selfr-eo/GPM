#!/bin/bash -l

# ---------------- Wrapper script to run gpm.sh downloader for a range of years ----------------
# Wrapper script for IMERG downloader - utilizing scripts developed by ARC Centre of Excellence for Climate Extremes (Copyright)
# NOTES: 
#       - make sure to provide the FULL directory path to avoid unwanted nesting
#       - run from git bash terminal in VScode (if on windows OS)
#   Usage: ./download_years.sh START_YEAR END_YEAR OUTPUT_DIR

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 START_YEAR END_YEAR OUTPUT_DIR"
    exit 1
fi

# Assign input arguments to variables
start_year=$1
end_year=$2
dir=$3

# Loop through the range of years
for (( year=$start_year; year<=$end_year; year++ ))
do
    # Print current timestamp and year
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Processing year: $year ..."
    ./gpm.sh "$year" "$dir"

    # Check if gpm.sh executed successfully
    if [ $? -ne 0 ]; then
        echo "Error: gpm.sh failed for year $year"
        exit 1
    fi
done
