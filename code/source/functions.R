#Generic functions necessary for code run

#Methods for catchment class
catchment <- function(single_basin, single_river, single_dem){
  single_catchment <- list(basin = single_basin, 
                           river = single_river, 
                           topo = single_dem)
  class(single_catchment) <- "catchment"
  return(single_catchment)
}

new_hydrosheds_catchment <- function(hydrosheds_id, basins_sf, riv_bas_sf, dem_raster){
  single_basin <- basins_sf[basins_sf$HYBAS_ID == hydrosheds_id, ]
  single_river <- riv_bas_sf[riv_bas_sf$HYBAS_ID == hydrosheds_id, ]
  single_dem <- crop_basin(single_basin, dem_raster)
  
  single_catchment <- catchment(single_basin, single_river, single_dem)
  return(single_catchment)
}

import_hydrosheds_catchments <- function(shapefile_basins, shapefile_rivers, raster_dem){
  basins_sf <- st_read(shapefile_basins)
  rivers_sf <- st_read(shapefile_rivers)
  dem_raster <- raster(raster_dem)
  catchments <- list()
  basins_tot <- length(basins_sf$HYBAS_ID)
  cores_n <- detectCores()
  cs <- makeCluster(cores_n - 1)
  catchments <- foreach(basin_n = 1:basins_tot) %dopar% {
    print(paste0(basin_n, ' / ', basins_tot))
    new_hydrosheds_catchment(basins_sf$HYBAS_ID[basin_n], 
                             basins_sf, riv_bas_sf, dem_raster) 
  }
  return(catchments)
}

plot.catchment <- function(object) {
  dem_dt <- data.table(rasterToPoints(object$topo))
  colnames(dem_dt) <- c('lon', 'lat', 'elevation')
  
  ggplot() +
    geom_raster(data = dem_dt, aes(y = lat, x = lon, fill = elevation)) +
    geom_sf(data = object$basin, alpha = 0.1) +
    geom_sf(data = object$river) +
    labs(x = "", y = "") +
    theme_light()
}