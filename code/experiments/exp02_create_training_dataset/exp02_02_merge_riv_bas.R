#Merge basins, rivers and DEMs

source('code/source/exp_02.R')
source('code/source/libs.R')
source('code/source/geo_utils.R')

shapefile_rivers <- paste0("./data/experiments/", experiment, "/rivers.shp")
shapefile_basins <- paste0("./data/experiments/", experiment, "/basins.shp")
rasterfile_dem <- paste0("./data/experiments/", experiment, "/dem.tif")

rivers_sf <- st_read(shapefile_rivers)
basins_sf <- st_read(shapefile_basins)
dem_raster <- raster(rasterfile_dem)
riv_bas_sf <- st_intersection(basins_sf, rivers_sf)

riv_bas_ids <- data.table(cbind(HYBAS_ID = riv_bas_sf$HYBAS_ID,
                                GOID = riv_bas_sf$GOID))

basins_sf_inter <- basins_sf[basins_sf$HYBAS_ID %in% riv_bas_ids$HYBAS_ID, ]
rivers_sf_inter <- rivers_sf[rivers_sf$GOID %in% riv_bas_ids$GOID, ]

saveRDS(riv_bas_ids, paste0("./data/experiments/", experiment, "/riv_bas_id.rds"))
st_write(riv_bas_sf, paste0("./data/experiments/", experiment, "/riv_bas.shp"))
st_write(basins_sf_inter, paste0("./data/experiments/", experiment, "/basins_inter.shp"))
st_write(rivers_sf_inter, paste0("./data/experiments/", experiment, "/rivers_inter.shp"))


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


