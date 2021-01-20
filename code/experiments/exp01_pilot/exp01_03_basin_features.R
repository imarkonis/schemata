#Determine basin features 

source('code/source/pilot.R')
source('code/source/libs.R')

shapefile_rivers <- paste0("./data/experiments/", experiment, "/rivers_pilot_inter.shp")
shapefile_basins <- paste0("./data/experiments/", experiment, "/basins_pilot_inter.shp")
rasterfile_dem <- paste0("./data/experiments/", experiment, "/dem_pilot.tif")

rivers_sf <- st_read(shapefile_rivers)
basins_sf <- st_read(shapefile_basins)
dem_raster <- raster(rasterfile_dem)
riv_bas_ids <- readRDS(paste0("./data/experiments/", experiment, "/riv_bas_id.rds"))

aa <- data.table(cbind(GOID = rivers_sf$GOID,
             length = st_length(rivers_sf)))
basins <- riv_bas_ids[aa, on = 'GOID']

aa <- data.table(cbind(HYBAS_ID = basins_sf$HYBAS_ID,
             area = st_area(basins_sf),
             perimeter = st_length(basins_sf)))
basins <- basins[aa, on = 'HYBAS_ID']

basins[, tot_length := sum(length), by = HYBAS_ID]
basins[, gc := gc_estimate(perimeter, area)]


