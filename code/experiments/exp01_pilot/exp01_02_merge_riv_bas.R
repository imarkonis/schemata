#Merge basins, rivers and DEMs
library(raster)
library(rgdal)
library(sp)

source('code/source/libs.R')
source('code/source/pilot.R')
source('code/source/graphics.R')

data_loc_rivers <- "./data/raw/hydrosheds/GEE/"
shapefile_rivers <- paste0(data_loc_rivers, "rivers_pilot.shp")
shapefile_basins <- "./data/experiments/exp01/basins_pilot.shp"
rasterfile_dem <- "./data/experiments/exp01/dem_pilot.tif"

rivers_sf <- st_read(shapefile_rivers)
basins_sf <- st_read(shapefile_basins)
dem_raster <- raster(rasterfile_dem)


#Validation plot

dem_dt <- data.table(rasterToPoints(dem_raster))
colnames(dem_dt) <- c('lon', 'lat', 'elevation')

ggplot() +
  geom_raster(data = dem_dt, aes(y = lat, x = lon, fill = elevation)) +
  geom_sf(data = basins_sf, alpha = 0.1) +
  geom_sf(data = rivers_sf) +
  labs(x = "", y = "") +
  theme_light()

