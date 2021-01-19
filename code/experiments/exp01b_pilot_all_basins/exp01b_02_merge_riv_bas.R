#Merge basins, rivers and DEMs
library(raster)
source('code/source/pilot_b.R')
source('code/source/libs.R')
source('code/source/geo_utils.R')

shapefile_rivers <- paste0("./data/experiments/", experiment, "/rivers_pilot.shp")
shapefile_basins <- paste0("./data/experiments/", experiment, "/basins_pilot.shp")
rasterfile_dem <- paste0("./data/experiments/", experiment, "/dem_pilot.tif")

rivers_sf <- st_read(shapefile_rivers)
basins_sf <- st_read(shapefile_basins)
dem_raster <- raster(rasterfile_dem)
riv_bas_sf <- st_intersection(basins_sf, rivers_sf)


#Validation plots

dem_dt <- data.table(rasterToPoints(dem_raster))
colnames(dem_dt) <- c('lon', 'lat', 'elevation')

ggplot() +
  geom_raster(data = dem_dt, aes(y = lat, x = lon, fill = elevation)) +
  geom_sf(data = basins_sf, alpha = 0.1) +
  geom_sf(data = riv_bas_sf) +
  labs(x = "", y = "") +
  theme_light()

hybas_id <- 2101105040 
single_basin <- basins_sf[basins_sf$HYBAS_ID == hybas_id, ]
single_river <- riv_bas_sf[riv_bas_sf$HYBAS_ID == hybas_id, ]
single_dem <- crop_basin(single_basin, dem_raster)

dem_dt <- data.table(rasterToPoints(single_dem))
colnames(dem_dt) <- c('lon', 'lat', 'elevation')

ggplot() +
  geom_raster(data = dem_dt, aes(y = lat, x = lon, fill = elevation)) +
  geom_sf(data = single_basin, alpha = 0.1) +
  geom_sf(data = single_river) +
  labs(x = "", y = "") +
  theme_light()

single_dem <- crop_basin(basins_sf, dem_raster)

dem_dt <- data.table(rasterToPoints(single_dem))
colnames(dem_dt) <- c('lon', 'lat', 'elevation')

ggplot() +
  geom_raster(data = dem_dt, aes(y = lat, x = lon, fill = elevation)) +
  geom_sf(data = basins_sf, alpha = 0.1) +
  geom_sf(data = riv_bas_sf) +
  labs(x = "", y = "") +
  theme_light()
