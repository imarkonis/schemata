#Import and preprocess dem
library(raster)
source('code/source/libs.R')
source('code/source/experiments/exp_01.R')

data_loc <- "./data/raw/hydrosheds/"
product <- "hydrosheds_dem/dem_15s_grid/"
region <- "eu_dem_15s/"
rasterfile_dem <- paste0(data_loc, product, region, "w001001.adf")

dem_raster_raw <- raster(rasterfile_dem)

e <- extent(LON_MIN - 1, LON_MAX + 1, LAT_MIN - 1, LAT_MAX + 1)
dem_raster <- crop(dem_raster_raw, e)

writeRaster(dem_raster, paste0("./data/experiments/", experiment, "/dem_pilot.tif"), overwrite = TRUE)


#Validation plot

plot(dem_raster)
            