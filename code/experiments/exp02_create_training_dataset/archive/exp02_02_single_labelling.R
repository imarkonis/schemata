#Merge basins, rivers and DEMs

source('code/source/experiments/exp_02.R')
source('code/source/libs.R')
source('code/source/geo_utils.R')
library(stars)

dir.create(paste0("./data/experiments/", experiment, '/training'))
shapefile_rivers <- paste0("./data/experiments/", experiment, "/riv_", region, ".shp")
dem_raster <- raster(rasterfile_dem)

rivers_sf <- st_read(shapefile_rivers)
dem_raster <- raster(rasterfile_dem)

res <- 0.2
lon_cuts <- seq(dem_raster@extent@xmin, dem_raster@extent@xmax, res)
lat_cuts <- seq(dem_raster@extent@ymin, dem_raster@extent@ymax, res)

for(lon_count in 1:(length(lon_cuts) - 1)){
  for(lat_count in 1:(length(lat_cuts) - 1)){
    e <- extent(lon_cuts[lon_count], 
                lon_cuts[lon_count + 1],
                lat_cuts[lat_count],
                lat_cuts[lat_count + 1])
    dem_raster_subset <- crop(dem_raster, e)
    
    rivers_subset <- st_crop(rivers_sf, c(xmin = lon_cuts[lon_count], 
                                          ymin = lat_cuts[lat_count], 
                                          xmax = lon_cuts[lon_count + 1], 
                                          ymax = lat_cuts[lat_count + 1]))
    
    pal <- colorRampPalette(rep("black", 2))
    rivers_raster <- st_rasterize(rivers_subset)
    png(paste0("./data/experiments/", experiment, '/training/',
               lon_cuts[lon_count], "_", lat_cuts[lat_count], "_rivers.png"))
    par(mar = c(0,0,0,0))
    plot(as(rivers_raster, "Raster"), main = NULL, key.pos = NULL, col = pal(2),  legend = FALSE, axes=FALSE, box = FALSE)
    dev.off()
    pal <- colorRampPalette(c("#cb9358", "#955f3b"))
    png(paste0("./data/experiments/", experiment, '/training/',
               lon_cuts[lon_count], "_", lat_cuts[lat_count], "_dem.png"))
    par(mar = c(0,0,0,0))
    plot(dem_raster_subset, col = pal(100),  key.pos = NULL, legend = FALSE, axes=FALSE, box = FALSE)

    dev.off()
  }
}
