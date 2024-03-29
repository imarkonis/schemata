
source('code/source/libs.R')
source('code/source/functions.R')
source('code/source/geo_utils.R')
source('code/source/database.R')
source('code/source/geo_functions.R')
source('code/source/experiments/exp_05.R')

library(RPostgres)
library(data.table)

con <- dbConnect(Postgres(), dbname = db_name, host = host_ip, port = port_n,        
                 user = rstudioapi::askForPassword("Database user"),      
                 password = rstudioapi::askForPassword("Database password"))


schema_tables_rivers <- dbGetQuery(con, "SELECT table_name FROM information_schema.tables WHERE table_schema = 'river_atlas'") 

i <- 4
print(schema_tables_rivers$table_name[i])
query_riv_allinfo <- paste0("SELECT gid, hybas_l12, hyriv_id, main_riv, next_down, length_km, dist_dn_km, dist_up_km, ord_clas, geom FROM river_atlas.", schema_tables_rivers$table_name[i])
region_rivall <- st_read(con, query = query_riv_allinfo)
crs_region <- st_crs(region_rivall$geom[1])
coords <- st_coordinates(region_rivall)
region_rivall <- st_drop_geometry(region_rivall)
region_dt <- data.table(region_rivall)
rm(region_rivall)
coords_dt <- data.table(coords)
rm(coords)
coords_dt[,X2:= data.table::shift(X, n = 1, type = "lag", fill = X[1]), by = L2]
coords_dt[,Y2:= data.table::shift(Y, n = 1, type = "lag", fill = Y[1]), by = L2]
coords_dt$id <- 1:nrow(coords_dt)
coords_dt[,distance:=st_distance(st_sfc(st_point(x= c(.SD$X,.SD$Y)), crs = crs_region$input),st_sfc(st_point(x= c(.SD$X2,.SD$Y2)), crs = crs_region$input), by_element = T),id]
coords_dt[,cum_dist:= cumsum(distance), L2]
print("got coords")
test <- merge(region_dt, coords_dt, by.x = "gid", by.y = "L2", all.y = T)
test <- data.table(test)
test[, dist_up_km_detailed := dist_up_km + as.numeric(cum_dist)/1000]
test[, L1:=NULL]
test[, X2:= NULL]
test[, Y2:= NULL]
print("saving")
saveRDS(test, paste0(data_path, '/',schema_tables_rivers$table_name[i],'_xy_dist.rds'))
