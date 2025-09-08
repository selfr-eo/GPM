## Notes for windows users

The scripts in this folder must be run using either Git Bash or virtual linux machines (fx WSL).

To use these, the packages [nco, cdo, parallel, netcdf4] should be installed on your conda environment.

Additionally, you must follow the steps at https://disc.gsfc.nasa.gov/information/howto?title=How%20to%20Generate%20Earthdata%20Prerequisite%20Files to download the prerequisite files for download, following steps for WINDOWS if running with Git Bash, LINUX if using WSL.

workflow:
1. open git bash terminal
2. run ./download_years.sh START_YEAR END_YEAR DIR

- to check files are downloading properly
1. open WSL terminal
2. activate conda environment (gpm_env)
3. run view_download.py (change filename in script to file you want to check)
