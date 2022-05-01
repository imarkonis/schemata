
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

for(i in 1:length(schema_tables_rivers$table_name)){
  print(schema_tables_rivers$table_name[i])
  query_riv_allinfo <- paste0("SELECT * FROM river_atlas.", schema_tables_rivers$table_name[i])
  region_rivall <- st_read(con, query = query_riv_allinfo)
  coords <- st_coordinates(region_rivall)
  print("got coords")
  region_sub <- subset(region_rivall,select = c("gid", "hybas_l12", "hyriv_id", "main_riv", "next_down", "length_km", "dist_dn_km", "dist_up_km", "ord_clas"))
  rm(region_rivall)
  region_sub <- st_drop_geometry(region_sub)
  test <- merge(region_sub, coords, by.x = "gid", by.y = "L2", all.y = T)
  test <- data.table(test)
  test[,L1:=NULL]
  print("saving")
  saveRDS(test, paste0(data_path, '/',schema_tables_rivers$table_name[i],'_xy.rds'))
  
}



