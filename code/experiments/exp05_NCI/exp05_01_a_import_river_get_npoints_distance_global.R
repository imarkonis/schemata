
source('code/source/libs.R')
source('code/source/functions.R')
source('code/source/geo_utils.R')
source('code/source/database.R')
source('code/source/geo_functions.R')
source('code/source/experiments/exp_05.R')

schema_tables_rivers <- dbGetQuery(con, "SELECT table_name FROM information_schema.tables WHERE table_schema = 'river_atlas'") 


for(i in 1:length(schema_tables_rivers$table_name)){
  print(schema_tables_rivers$table_name[i])
  query_riv_allinfo <- paste0("SELECT gid, hybas_l12, hyriv_id, main_riv, next_down, length_km, dist_dn_km, dist_up_km, ord_clas, geom FROM river_atlas.", schema_tables_rivers$table_name[i])
  region_rivall <- st_read(con, query = query_riv_allinfo)
  region_test <- head(region_rivall)
  # sample point roughly every 500 m
  region_rivall$sample_num <- region_rivall$length_km/0.5
  new_points <- st_sample(region_rivall$geom, round(region_rivall$sample_num))
  coords_dt[, distance := st_distance(st_sfc(st_point(x= c(.SD$X,.SD$Y)), crs = crs_in),st_sfc(st_point(x= c(.SD$X2,.SD$Y2)), crs = crs_in), by_element = T),id]
  coords_dt[, cum_dist := cumsum(distance), L2]
  coords_dt[, cum_dist_v2 := rev(cum_dist) , L2]  
  print("got coords")
  test <- merge(region_dt, coords_dt, by.x = "gid", by.y = "L2", all.y = T)
  test <- data.table(test)
  test[, dist_dn_km_detailed := dist_dn_km + as.numeric(cum_dist_v2)/1000]
  test[, dist_up_km_detailed := dist_up_km - as.numeric(cum_dist_v2)/1000]
  test[, L1 := NULL]
  test[, X2 := NULL]
  test[, Y2 := NULL]
  print("saving")
  saveRDS(test, paste0(data_path, '/',schema_tables_rivers$table_name[i],'_xy_dist.rds'))
}



