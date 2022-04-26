#Import and preprocess dem

source('code/source/libs.R')
source('code/source/experiments/exp_02.R')

all_rasters <- list.dirs(paste0(data_loc, product), full.names = F)
all_rasters <- unique(substr(all_rasters, 1, 7))
all_rasters <- all_rasters[-1]
rasters_n <- length(all_rasters)

foreach(raster_count = 1:rasters_n, .packages = c('data.table', 'sf')) %dopar% {
  rasterfile_dem <- paste0(data_loc, product, all_rasters[raster_count], "_con_grid/", 
                           all_rasters[raster_count], "_con/", all_rasters[raster_count], "_con/w001001.adf")
  dem_raster <- raster(rasterfile_dem)
  writeRaster(dem_raster, paste0("./data/dems_3s/dem_", all_rasters[raster_count], ".tif"), overwrite=TRUE)
}

#Validation plot

plot(dem_raster)
            