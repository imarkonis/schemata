
source('code/source/libs.R')
source('code/source/functions.R')
source('code/source/geo_utils.R')
source('code/source/database.R')
source('code/source/geo_functions.R')
source('code/source/experiments/exp_05.R')

library(rgdal)
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
  #saveRDS(region_rivall, paste0(data_path, '/',schema_tables_rivers$table_name[i],'_xyz.rds'))
  
  region_ord_class_sel <- region_rivall[region_rivall$ord_clas == 1,]
  coords <- st_coordinates(region_ord_class_sel)
  print("got coords")
  test <- merge(region_ord_class_sel, coords, by.x = "gid", by.y = "L2", all.y = T)
  print("saving")
  saveRDS(test, paste0(data_path, '/',schema_tables_rivers$table_name[i],'_xy.rds'))
  
}




