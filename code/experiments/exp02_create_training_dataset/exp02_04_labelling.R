#Merge basins, rivers and DEMs

source('code/source/exp_02.R')
source('code/source/libs.R')
source('code/source/geo_utils.R')
library(stars)

dir.create(paste0("./data/experiments/", experiment, '/training'))
shapefile_rivers <- paste0("./data/experiments/", experiment, "/rivers.shp")
rasterfile_dem <- paste0("./data/experiments/", experiment, "/dem.tif")

rivers_sf <- st_read(shapefile_rivers)
dem_raster <- raster(rasterfile_dem)

res <- 0.5
lon_cuts <- seq(LON_MIN, LON_MAX, 0.5)
lat_cuts <- seq(LAT_MIN, LAT_MAX, 0.5)

lon_count <- 1
lat_count <- 1

for(lon_count in 1:(length(lon_cuts) - 1)){
  for(lat_count in 1:(length(lat_cuts)- 1)){
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
    rivers_raster <- st_rasterize(rivers_subset[, "CONTINENT"])
    png(paste0("./data/experiments/", experiment, '/training/',
               lon_cuts[lon_count], "_", lat_cuts[lat_count], "_rivers.png"))
    plot(rivers_raster, main = NULL, key.pos = NULL, col = pal(2))
    dev.off()
    pal <- colorRampPalette(c("black", "white"))
    png(paste0("./data/experiments/", experiment, '/training/',
               lon_cuts[lon_count], "_", lat_cuts[lat_count], "_dem.png"))
    plot(dem_raster_subset, col = pal(100),  legend = FALSE, axes=FALSE, box = FALSE)

    dev.off()
  }
}

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
rivers_raster <- stars::st_rasterize(rivers_subset)
plot(rivers_subset[, "CONTINENT"], col = pal(2), main = '')
plot(rivers_raster, col = pal(2), main = '')
pal <- colorRampPalette(c("black", "white"))
plot(dem_raster_subset, col = pal(100))
