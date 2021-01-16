#Import and preprocess dem
library(raster)
source('code/source/libs.R')
source('code/source/pilot.R')

data_loc <- "./data/raw/hydrosheds/"
product <- "hydrosheds_dem/dem_15s_grid/"
region <- "eu_dem_15s/"
rasterfile_dem <- paste0(data_loc_basins, product, region, "w001001.adf")

dem_raster_raw <- raster(rasterfile_dem)

e <- extent(LON_MIN, LON_MAX, LAT_MIN, LAT_MAX)
dem_raster <- crop(dem_raster_raw, e)

writeRaster(dem_raster, "./data/experiments/exp01/dem_pilot.tif")


#Validation plot

plot(dem_raster)
            