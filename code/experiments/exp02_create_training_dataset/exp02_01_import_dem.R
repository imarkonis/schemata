#Import and preprocess dem

source('code/source/libs.R')
source('code/source/experiments/exp_02.R')

data_loc <- "./data/raw/hydrosheds/"
product <- "hydrosheds_dem/dem_15s_grid/"
region <- "eu_dem_15s/"
rasterfile_dem <- paste0(data_loc, product, region, "w001001.adf")

dem_raster_raw <- raster(rasterfile_dem)

e <- extent(LON_MIN, LON_MAX, LAT_MIN, LAT_MAX)
dem_raster <- crop(dem_raster_raw, e)

writeRaster(dem_raster, paste0("./data/experiments/", experiment, "/dem.tif"))


#Validation plot

plot(dem_raster)
            