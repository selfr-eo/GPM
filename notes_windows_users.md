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

### TIP: If your authentification token expires and you get authentification errors after the downloader was once working, try:

1. Remove and recreate an empty .urs_cookies file 

rm ~/.urs_cookies
touch ~/.urs_cookies

2. Test authentification by accessing your EarthdData profile:

wget --load-cookies ~/.urs_cookies \
     --save-cookies ~/.urs_cookies \
     --keep-session-cookies \
     --no-check-certificate \
     --auth-no-challenge \
     --netrc \
     "https://urs.earthdata.nasa.gov/profile"


and/or 

wget --load-cookies ~/.urs_cookies \
        --save-cookies ~/.urs_cookies \
        --keep-session-cookies \
        --no-check-certificate \
        --auth-no-challenge=on \
        --netrc \
        -O 3B-DAY.MS.MRG.3IMERG.20170101-S000000-E235959.V07B.nc4 \
        https://gpm1.gesdisc.eosdis.nasa.gov/opendap/hyrax/GPM_L3/GPM_3IMERGDF.07/2017/01/3B-DAY.MS.MRG.3IMERG.20170101-S000000-E235959.V07B.nc4.dap.nc4


3. Try running with curl first on a random file (more robust than wget)

curl -n \
     -c ~/.urs_cookies \
     -b ~/.urs_cookies \
     -L \
     -o 3B-DAY.MS.MRG.3IMERG.20170101-S000000-E235959.V07B.nc4 \
     "https://gpm1.gesdisc.eosdis.nasa.gov/opendap/hyrax/GPM_L3/GPM_3IMERGDF.07/2017/01/3B-DAY.MS.MRG.3IMERG.20170101-S000000-E235959.V07B.nc4.dap.nc4"