
experiment <- 'exp05'


results_path <- paste0('./results/experiments/', experiment)
data_path <- paste0('./data/experiments/', experiment)

if(!dir.exists(results_path)) {dir.create(paste0('./results/experiments/', experiment))}
if(!dir.exists(data_path)) {dir.create(paste0('./data/experiments/', experiment))}


# Parallel computing

#cores_n <- detectCores()
#registerDoParallel(cores = cores_n - 2)

# Constants

# Functions

par_fun <- function(x, crs_use = crs_in, dt = coords_dt){
  return(dt[id == x, st_distance(st_sfc(st_point(x= c(.SD$X,.SD$Y)), crs = crs_use),st_sfc(st_point(x= c(.SD$X2,.SD$Y2)), crs = crs_use), by_element = T),])
}

get_equid_points_on_river <- function(river_seg, dist_m = 500) {
  num <- as.numeric(st_length(river_seg)/dist_m)
  points_st <- st_sample(river_seg, size = num, type = "regular")
  return(as.data.frame(points_st))
}


par_regions <- function(region, crs_use = crs_in){
  river_level <- readRDS(paste0(data_path, '/',region,'_levels.rds'))
  river_level <- as.data.table(river_level)
  crs_region <- st_crs(river_level$geom[1])
  river_level[, pt_count:= nrow(st_coordinates(geom)), pfaf_id_level]
  new_points <- river_level[pt_count < 30, 
                            cbind(
                              as.data.frame(
                                suppressWarnings(st_sample(geom, size = 30, type = "regular"))
                              ), 
                              gid), 
                            (pfaf_id_level)]
  river_level_merge <- merge(river_level, new_points, by = c("gid", "pfaf_id_level"), all = T)
  river_level_merge[, geom_pts := st_cast(geom, "MULTIPOINT")]
  river_level_merge[pt_count < 30, geom_pts := geometry]
  river_level_merge[, pt_count_new:= nrow(st_coordinates(geom_pts)), pfaf_id_level]
  river_level_merge[,min(pt_count_new)]
  # get coordinates
  coords_dt <- st_coordinates(river_level_merge$geom_pts)
  coords_dt <- as.data.table(coords_dt)
  coords_dt[, X2 := data.table::shift(X, n = 1, type = "lag", fill = X[1]), by = L1]
  coords_dt[, Y2 := data.table::shift(Y, n = 1, type = "lag", fill = Y[1]), by = L1]
  # save coordinate system 
  if(R.Version()$major > 3){
    crs_in <- crs_region$input
  }else{
    crs_in <- crs_region$epsg
  }
  # distance between points
  coords_dt$id <- 1:nrow(coords_dt)
  coords_dt[, distance := st_distance(st_sfc(st_point(x= c(.SD$X,.SD$Y)), crs = crs_use),st_sfc(st_point(x= c(.SD$X2,.SD$Y2)), crs = crs_use), by_element = T), id]
  coords_dt[, cum_dist := cumsum(distance), L1]
  coords_dt[, cum_dist_v2 := rev(cum_dist) , L1]  
  print("got coords")
  # Merge back
  river_level_merge$L1 <- 1:nrow(river_level_merge) 
  river_merged <- merge(river_level_merge, coords_dt, by.x = "L1", by.y = "L1", all.y = T)
  river_merged <- data.table(river_merged)
  river_merged[, dist_dn_km_detailed := dist_dn_km + as.numeric(cum_dist_v2)/1000]
  river_merged[, dist_up_km_detailed := dist_up_km - as.numeric(cum_dist_v2)/1000]
  river_merged[, X2 := NULL]
  river_merged[, Y2 := NULL]
  river_merged[, geom := NULL]
  river_merged[, pt_count_new := NULL]
  river_merged[, geometry := NULL]
  river_merged[, L1 := NULL]
  saveRDS(river_merged, paste0(data_path, "/",region,"_xy.rds"))
  
  gc()
  
}