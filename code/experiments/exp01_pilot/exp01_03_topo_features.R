library(spatialEco)

source('code/source/libs.R')
source('code/source/geo_utils.R')
source('code/source/geo_functions.R')
source('code/source/experiments/exp_01.R')

shapefile_basins <- paste0("./data/experiments/", experiment, "/basins_pilot.shp")
rasterfile_dem <- paste0("./data/experiments/", experiment, "/dem_pilot.tif")

basins_sf <- st_read(shapefile_basins)
dem_raster <- raster(rasterfile_dem)

single_dem <- crop_basin(basins_sf, dem_raster)

hybas_id <- 2101105040 
single_basin <- basins_sf[basins_sf$HYBAS_ID == hybas_id, ]
single_dem <- crop_basin(single_basin, dem_raster)

ter_rug_index <- tri(single_dem)
topo_pos_index <- tpi(single_dem)
veg_rug_measure <- vrm(single_dem)
shannon_index <- rasterdiv::Shannon(single_dem)

cellStats(single_dem, 'mean')
cellStats(single_dem, 'sd')
cellStats(single_dem, 'skew')
cellStats(single_dem, 'max') - cellStats(single_dem, 'min')
csa::csas(single_dem)
aa <- csa::csas(dem_raster)

cellStats(dem_raster, 'mean')
cellStats(dem_raster, 'sd')
cellStats(dem_raster, 'skew')
cellStats(dem_raster, 'max') - cellStats(single_dem, 'min')

# Validation plots
plot(ter_rug_index, col = gray.colors(10, start = 0.9, end = 0.3, gamma = 2.2, alpha = NULL))
plot(topo_pos_index, col = gray.colors(10, start = 0.9, end = 0.3, gamma = 2.2, alpha = NULL))
plot(veg_rug_measure, col = gray.colors(10, start = 0.9, end = 0.3, gamma = 2.2, alpha = NULL))
plot(shannon_index, col = gray.colors(10, start = 0.9, end = 0.3, gamma = 2.2, alpha = NULL))

for(scale in seq(15, 1, -2)){
  print(plot(raster.moments(single_dem, type = 'mean', s = scale)))
}

