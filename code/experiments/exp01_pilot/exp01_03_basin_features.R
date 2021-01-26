#Determine basin features 

source('code/source/libs.R')
source('code/source/geo_utils.R')
source('code/source/geo_functions.R')
source('code/source/experiments/exp_01.R')

shapefile_rivers <- paste0("./data/experiments/", experiment, "/rivers_pilot_inter.shp")
shapefile_basins <- paste0("./data/experiments/", experiment, "/basins_pilot_inter.shp")
rasterfile_dem <- paste0("./data/experiments/", experiment, "/dem_pilot.tif")

rivers_sf <- st_read(shapefile_rivers)
basins_sf <- st_read(shapefile_basins)
dem_raster <- raster(rasterfile_dem)
riv_bas_ids <- readRDS(paste0("./data/experiments/", experiment, "/riv_bas_id.rds"))

aa <- data.table(cbind(GOID = rivers_sf$GOID,
                       BB_ID = rivers_sf$BB_ID,
             length = st_length(rivers_sf)))
bas_feats <- riv_bas_ids[aa, on = 'GOID']

aa <- data.table(cbind(HYBAS_ID = basins_sf$HYBAS_ID,
             area = st_area(basins_sf),
             perimeter = st_length(basins_sf)))
bas_feats <- bas_feats[aa, on = 'HYBAS_ID']

bas_feats[, tot_length := sum(length), by = HYBAS_ID]
bas_feats[, gc := gc_estimate(perimeter, area)]


rivers_sf[rivers_sf$BB_ID == 996425,]

plot(rivers_sf[rivers_sf$BB_ID == 996425,]$geometry)

riv_bas_ids <- data.table(cbind(HYBAS_ID = riv_bas_sf$HYBAS_ID,
                                BB_ID = riv_bas_sf$BB_ID))
riv_bas_ids[BB_ID == 996425]

single_basin <- basins_sf[basins_sf$BB_ID == 996425, ]
single_river <- rivers_sf[rivers_sf$BB_ID == 996425, ]
single_dem <- crop_basin(single_basin, dem_raster)

dem_dt <- data.table(rasterToPoints(single_dem))
colnames(dem_dt) <- c('lon', 'lat', 'elevation')

ggplot() +
  #geom_raster(data = dem_dt, aes(y = lat, x = lon, fill = elevation)) +
  geom_sf(data = single_basin, alpha = 0.1) +
  geom_sf(data = single_river) +
  labs(x = "", y = "") +
  theme_light()
