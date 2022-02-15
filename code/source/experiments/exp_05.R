
experiment <- 'exp05'


results_path <- paste0('./results/experiments/', experiment)
data_path <- paste0('./data/experiments/', experiment)

# database
db_name <- 'earth'
db_schema <- 'basin_boundaries'
host_ip <- '127.0.0.1' 
port_n <- '5432'


# Parallel computing

cores_n <- detectCores()
registerDoParallel(cores = cores_n - 2)

# Constants

# Functions
get_xyz <- function(hyriv_id_sel){
  riv_sel <- subset(region_rivall, hyriv_id == hyriv_id_sel)
  riv_sel_geom <- st_geometry(riv_sel)
  riv_sel_geom_xy <- as.data.table(riv_sel_geom[[1]][[1]])
  names(riv_sel_geom_xy) = c("x", "y")
  
  riv_sel_dt  <-  data.table(riv_sel)
  riv_sel_dt <- subset(riv_sel_dt, select = c(gid, hyriv_id, next_down, main_riv, length_km, dist_dn_km, dist_up_km, ord_clas))
  
  riv_sel_xy <- cbind(data.table(riv_sel_dt), riv_sel_geom_xy)
  z <- extract(x = dem_raster, y = riv_sel_geom[[1]][[1]])
  riv_sel_xy[, z:= z]
  return(riv_sel_xy)
}


