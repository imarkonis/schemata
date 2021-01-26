#Estimate basin features 

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
             riv_length = st_length(rivers_sf)))
basin_feats <- riv_bas_ids[aa, on = 'GOID']

aa <- data.table(cbind(HYBAS_ID = basins_sf$HYBAS_ID,
             area = st_area(basins_sf),
             perimeter = st_length(basins_sf)))
basin_feats <- basin_feats[aa, on = 'HYBAS_ID']

basin_feats[, tot_riv_length := sum(riv_length), by = HYBAS_ID]
basin_feats[, gc := gc_estimate(perimeter, area)]

basin_feats <- unique(basin_feats[, .(HYBAS_ID, area, perimeter, tot_riv_length, gc)])
saveRDS(basin_feats, './data/experiments/exp01/basin_feats.rds')


# Validation plots

plot(gc~tot_riv_length, data = basin_feats)
