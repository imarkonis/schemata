
experiment <- 'exp05'


results_path <- paste0('./results/experiments/', experiment)
data_path <- paste0('./data/experiments/', experiment)

if(!dir.exists(results_path)) {dir.create(paste0('./results/experiments/', experiment))}
if(!dir.exists(data_path)) {dir.create(paste0('./data/experiments/', experiment))}


# Parallel computing

cores_n <- detectCores()
registerDoParallel(cores = cores_n - 2)

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

