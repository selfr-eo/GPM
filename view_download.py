
# Check that the downloaded files are readable....

import xarray as xr

# Path to your file
file_path = "IMERG/2000/001/3B-HHR.MS.MRG.3IMERG.20000101-S003000-E005959.0030.V07B.HDF5.nc4"

# Open the NetCDF file
ds = xr.open_dataset(file_path, engine='netcdf4')  # engine can also be 'h5netcdf'

# Quick summary
print(ds)

# List variables
print("Variables:", list(ds.data_vars))
