source('code/source/experiments/exp_06.R')
source('code/source/libs.R')
source('code/source/geo_utils.R')
library(stars)

dir.create(paste0("./data/experiments/", experiment, '/dems'))

res <- 0.2

all_rasters <- list.dirs(paste0(data_loc, product), full.names = F)
all_rasters <- unique(substr(all_rasters, 1, 7))
all_rasters <- all_rasters[-1]
rasters_n <- length(all_rasters)


foreach(raster_count = 1:rasters_n, .packages = c('data.table', 'sf')) %dopar% {
  rasterfile_dem <- paste0("./data/dems_3s/dem_", all_rasters[raster_count], ".tif")
  dem_raster <- raster(rasterfile_dem)

lon_cuts <- seq(dem_raster@extent@xmin, dem_raster@extent@xmax, res)
lat_cuts <- seq(dem_raster@extent@ymin, dem_raster@extent@ymax, res)

for(lon_count in 1:(length(lon_cuts) - 1)){
  for(lat_count in 1:(length(lat_cuts) - 1)){
    e <- extent(lon_cuts[lon_count], 
                lon_cuts[lon_count + 1],
                lat_cuts[lat_count],
                lat_cuts[lat_count + 1])
    dem_raster_subset <- crop(dem_raster, e)
    
    pal <- colorRampPalette(c("#cb9358", "#955f3b"))
    png(paste0("./data/experiments/", experiment, '/dems/',
               lon_cuts[lon_count], "_", lat_cuts[lat_count], "_dem.png"))
    par(mar = c(0,0,0,0))
    plot(dem_raster_subset, col = pal(100),  key.pos = NULL, legend = FALSE, axes=FALSE, box = FALSE)

    dev.off()
  }
}
}
