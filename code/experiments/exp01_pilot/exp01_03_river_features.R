#Estimate basin features 

source('code/source/libs.R')
source('code/source/experiments/exp_01.R')

shapefile_rivers <- paste0("./data/experiments/", experiment, "/rivers_pilot_inter.shp")
rivers_sf <- st_read(shapefile_rivers)
riv_bas_ids <- readRDS(paste0("./data/experiments/", experiment, "/riv_bas_id.rds"))

single_basin <- 2101113960
single_basin_goids <- riv_bas_ids[HYBAS_ID %in% single_basin]$GOID
single_riv_net <- rivers_sf[rivers_sf$GOID %in% single_basin_goids, ]

plot(single_riv_net)

#Estimate L/D, where L is backbone river length and 
#D is the distance between backbone river start and end

#Estimate the number of intersections between backbone river
#and the line that connects its start and end