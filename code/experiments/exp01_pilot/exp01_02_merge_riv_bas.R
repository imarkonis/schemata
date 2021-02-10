#Merge basins, rivers and DEMs

source('code/source/libs.R')
source('code/source/functions.R')
source('code/source/geo_utils.R')
source('code/source/experiments/exp_01.R')

shapefile_rivers <- paste0("./data/experiments/", experiment, "/rivers_pilot.shp")
shapefile_basins <- paste0("./data/experiments/", experiment, "/basins_pilot.shp")
raster_dem <- paste0("./data/experiments/", experiment, "/dem_pilot.tif")

rivers_sf <- st_read(shapefile_rivers)
basins_sf <- st_read(shapefile_basins)
dem_raster <- raster(raster_dem)

riv_bas_sf <- st_intersection(basins_sf[1], rivers_sf)
riv_bas_ids <- data.table(cbind(HYBAS_ID = riv_bas_sf$HYBAS_ID,
                                GOID = riv_bas_sf$GOID))
saveRDS(riv_bas_ids, paste0("./data/experiments/", experiment, "/riv_bas_id.rds"))
st_write(riv_bas_sf, paste0("./data/experiments/", experiment, "/riv_bas_pilot.shp"), append = FALSE)

catchments_pilot <- import_hydrosheds_catchments(shapefile_basins, shapefile_rivers, raster_dem)
names(catchments_pilot) <- basins_sf$HYBAS_ID
saveRDS(catchments_pilot, paste0("./data/experiments/", experiment, "/catchments.rds"))

hybas_id <- 2101105040 
single_catchment <- new_hydrosheds_catchment(hybas_id, basins_sf, rivers_sf, dem_raster)
all_catchments <- catchment(basins_sf, rivers_sf, dem_raster)

#Validation plots
plot(catchments_pilot[[271]])
plot(catchments_pilot$`2101105040`)
plot(single_catchment)
