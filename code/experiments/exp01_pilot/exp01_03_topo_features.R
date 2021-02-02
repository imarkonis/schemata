library(spatialEco)

source('code/source/libs.R')
source('code/source/geo_utils.R')
source('code/source/geo_functions.R')
source('code/source/experiments/exp_01.R')

cores_n <- detectCores()
cs <- makeCluster(cores_n - 1)

catchments <- readRDS(paste0(data_path, "/catchments.rds"))

hybas_id <- 2101105040 
single_dem <- catchments$`2101105040`$topo
single_dem <- catchments[[1]]$topo

ter_rug_index <- tri(single_dem)
topo_pos_index <- tpi(single_dem)
veg_rug_measure <- vrm(single_dem)
shannon_index <- rasterdiv::Shannon(single_dem)

cellStats(single_dem, 'mean')
cellStats(single_dem, 'sd')
cellStats(single_dem, 'skew')
cellStats(single_dem, 'max') - cellStats(single_dem, 'min')
#csa::csas(single_dem)
#aa <- csa::csas(dem_raster)

cellStats(dem_raster, 'mean')
cellStats(dem_raster, 'sd')
cellStats(dem_raster, 'skew')
cellStats(dem_raster, 'max') - cellStats(single_dem, 'min')

# Validation plots
par(mfrow = c(2, 2))
plot(ter_rug_index, col = gray.colors(10, start = 0.9, end = 0.3, gamma = 2.2, alpha = NULL))
plot(topo_pos_index, col = gray.colors(10, start = 0.9, end = 0.3, gamma = 2.2, alpha = NULL))
plot(veg_rug_measure, col = gray.colors(10, start = 0.9, end = 0.3, gamma = 2.2, alpha = NULL))
plot(shannon_index, col = gray.colors(10, start = 0.9, end = 0.3, gamma = 2.2, alpha = NULL))

par(mfrow = c(4, 2))
for(scale in seq(15, 1, -2)){
  print(plot(raster.moments(single_dem, type = 'mean', s = scale)))
}

