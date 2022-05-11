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
  registerDoParallel(cores = cores_n - 1)
  catchments <- foreach(basin_n = 1:basins_tot) %dopar% {
    print(paste0(basin_n, ' / ', basins_tot))
    new_hydrosheds_catchment(basins_sf$HYBAS_ID[basin_n], 
                             basins_sf, riv_bas_sf, dem_raster) 
  }
  return(catchments)
}

#Does not work -> turncates query to 255 characters
get_bas_bounds <- function(bas_ids, connection, schema){
  ids_as_string <- toString(bas_ids)
  ids_as_string <- sapply(strsplit(ids_as_string, '[, ]+'), function(x) toString(sQuote(x, FALSE)))
  bas_bounds <- st_read(connection, paste0("SELECT * FROM ", schema, ".", 
                                    'basins_all_regions_4_11 WHERE pfaf_id IN (', ids_as_string, ')'))
  return(bas_bounds)
}

db_import_bas_borders <- function(db_con, regions, lvl_range){
  lvl_range <- lvl_range[1]:lvl_range[2]
  table_names <- apply(expand.grid(regions, as.character(lvl_range)), 1, paste0, collapse = '_')
  tables_n <- length(table_names)
  bas_borders <- st_read(con, query = paste0("SELECT pfaf_id, geom FROM basin_boundaries.", table_names[1]))
  bas_borders$pfaf_id <- as.character(bas_borders$pfaf_id)   
  for(table_count in 1:tables_n){
    basin_table <- st_read(con, query = paste0("SELECT pfaf_id, geom FROM basin_boundaries.", table_names[table_count]))
    basin_table$pfaf_id <- as.character(basin_table$pfaf_id)                          
    bas_borders <- bind_rows(bas_borders, basin_table)
    print(table_names[table_count])
  }
  return(bas_borders)
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


CreateSegment <- function(coords, from, to) {
  distance <- 0
  coordsOut <- c()
  biggerThanFrom <- F
  for (i in 1:(nrow(coords) - 1)) {
    d <- sqrt((coords[i, 1] - coords[i + 1, 1])^2 + (coords[i, 2] - coords[i + 
                                                                             1, 2])^2)
    distance <- distance + d
    if (!biggerThanFrom && (distance > from)) {
      w <- 1 - (distance - from)/d
      x <- coords[i, 1] + w * (coords[i + 1, 1] - coords[i, 1])
      y <- coords[i, 2] + w * (coords[i + 1, 2] - coords[i, 2])
      coordsOut <- rbind(coordsOut, c(x, y))
      biggerThanFrom <- T
    }
    if (biggerThanFrom) {
      if (distance > to) {
        w <- 1 - (distance - to)/d
        x <- coords[i, 1] + w * (coords[i + 1, 1] - coords[i, 1])
        y <- coords[i, 2] + w * (coords[i + 1, 2] - coords[i, 2])
        coordsOut <- rbind(coordsOut, c(x, y))
        break
      }
      coordsOut <- rbind(coordsOut, c(coords[i + 1, 1], coords[i + 1, 
                                                               2]))
    }
  }
  if(nrow(coordsOut) > 2){
    coordsOut <- coordsOut[c(1,3),]
  }
  return(coordsOut)
}


CreateSegments_coords <- function(coords, length = 0, n.parts = 0) {
  stopifnot((length > 0 || n.parts > 0))
  # calculate total length line
  total_length <- 0
  for (i in 1:(nrow(coords) - 1)) {
    d <- sqrt((coords[i, 1] - coords[i + 1, 1])^2 + (coords[i, 2] - coords[i + 
                                                                             1, 2])^2)
    total_length <- total_length + d
  }
  # calculate stationing of segments
  if (length > 0) {
    stationing <- c(seq(from = 0, to = total_length, by = length), total_length)
  } else {
    stationing <- c(seq(from = 0, to = total_length, length.out = n.parts+1))
  }
  
  # calculate segments and store the in list
  
  for (i in 1:(length(stationing) - 1)) {
    if (i == 1){
      newlines <- CreateSegment(coords, stationing[i], stationing[i + 1])
    }else{
      tmp <- CreateSegment(coords, stationing[i], stationing[i + 1])
      newlines <- rbind(newlines, tmp)
    }
  }
  return(as.data.frame(unique(newlines)))
}
