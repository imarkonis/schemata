source('code/source/libs.R')
source('code/source/experiments/exp_05.R')
library(parallel)
options(scipen = 15)
regions <- c("af", "as", "na", "au", "eu", "sa_n", "sa_s", "si")

# add basin, sub-basin, interbasin, closed, region, 
for(i in 1:length(regions)){
  print(regions[i])
  river_level <- readRDS(paste0(data_path, '/',regions[i],'_levels.rds'))
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
  a <- Sys.time()
  dist <- simplify2array(
    mclapply(coords_dt$id, 
           par_fun, 
           mc.cores = 40,
           mc.cleanup = TRUE
           )
    )
  print(difftime(Sys.time(),a))
  coords_dt$distance <- dist
  coords_dt[, cum_dist := cumsum(distance), L1]
  coords_dt[, cum_dist_v2 := rev(cum_dist) , L1]  
  print("got coords")
  # Merge back
  river_merged <- merge(river_level_merge, coords_dt, by.x = "gid", by.y = "L1", all.y = T)
  river_merged <- data.table(river_merged)
  river_merged[, dist_dn_km_detailed := dist_dn_km + as.numeric(cum_dist_v2)/1000]
  river_merged[, dist_up_km_detailed := dist_up_km - as.numeric(cum_dist_v2)/1000]
  river_merged[, X2 := NULL]
  river_merged[, Y2 := NULL]
  river_merged[, geom := NULL]
  river_merged[, pt_count_new := NULL]
  river_merged[, geometry := NULL]

  saveRDS(river_merged, paste0(data_path, "/",regions[i],"_xy.rds"))
  
  gc()
  
}

