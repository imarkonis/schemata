source('./code/source/experiments/exp_06.R')
source('./code/source/libs.R')
source('./code/source/geo_utils.R')
library(png)

data_source_path <- paste0("./data/experiments/", experiment, '/dems/')
data_save_path <- paste0("./data/experiments/", experiment, '/coarse/')

dir.create(data_save_path)
dir.create(paste0(data_save_path, 'scale_1'))
dir.create(paste0(data_save_path, 'scale_2'))
dir.create(paste0(data_save_path, 'scale_4'))
dir.create(paste0(data_save_path, 'scale_8'))
dem_files_png <- list.files(data_source_path, pattern = "*dem.png")
pal <- colorRampPalette(c("white", "black"))

length(dem_files_png)
foreach(file_count = 1:5, .packages = c('data.table', 'sf', 'png')) %dopar% {
  dem_raster <- raster(paste0(data_source_path, dem_files_png[file_count]))

  png(paste0(data_save_path, 'scale_1/', dem_files_png[file_count]))
  par(mar = c(0, 0, 0, 0))
  plot(dem_raster, main = NULL, key.pos = NULL, col = rev(pal(100)),  
                             legend = FALSE, axes=FALSE, box = FALSE)
  dev.off()
  
  png(paste0(data_save_path, 'scale_2/', dem_files_png[file_count]))
  par(mar = c(0, 0, 0, 0))
  plot(aggregate(dem_raster, 2), main = NULL, key.pos = NULL, col = rev(pal(100)),  
       legend = FALSE, axes=FALSE, box = FALSE)
  dev.off()
  
  png(paste0(data_save_path, 'scale_4/', dem_files_png[file_count]))
  par(mar = c(0, 0, 0, 0))
  plot(aggregate(dem_raster, 4), main = NULL, key.pos = NULL, col = rev(pal(100)),  
       legend = FALSE, axes=FALSE, box = FALSE)
  dev.off()
  
  png(paste0(data_save_path, 'scale_8/', dem_files_png[file_count]))
  par(mar = c(0, 0, 0, 0))
  plot(aggregate(dem_raster, 8), main = NULL, key.pos = NULL, col = rev(pal(100)),  
       legend = FALSE, axes=FALSE, box = FALSE)
  dev.off()
}

pal <- colorRampPalette(c("#cb9358", "#955f3b"))

plot(dem_raster,  col = rev(pal(100)))
par(mar = c(0,0,0,0))
plot(aggregate(dem_raster, 8), col = rev(pal(100)),  key.pos = NULL, legend = FALSE, axes=FALSE, box = FALSE)



res <- 0.5
lon_cuts <- seq(dem_raster@extent@xmin, dem_raster@extent@xmax, res)
lat_cuts <- seq(dem_raster@extent@ymin, dem_raster@extent@ymax, res)

for(lon_count in 1:(length(lon_cuts) - 1)){
  for(lat_count in 1:(length(lat_cuts) - 1)){
    e <- extent(lon_cuts[lon_count], 
                lon_cuts[lon_count + 1],
                lon_cuts[lon_count],
                lat_cuts[lat_count + 1])
    dem_raster_subset <- crop(dem_raster, e)
    writeRaster(dem_raster_subset, paste0(data_path, '/dem_', lon_cuts[lon_count], '_', lon_cuts[lon_count]))

