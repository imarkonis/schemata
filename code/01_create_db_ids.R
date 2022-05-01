#Stores all ids in a single data table and saves it in db_ids.rds

source('code/source/libs.R')
source('code/source/database.R')
library(RPostgres)

con <- dbConnect(Postgres(), dbname = db_name, host = host_ip, port = port_n,         
                 user = rstudioapi::askForPassword("Database user"),      
                 password = rstudioapi::askForPassword("Database password"))

basin_ids <- foreach(region_count = 1:length(regions_all), .packages = c('data.table', 'sf', 'RPostgres' ), 
                     .combine = 'rbind') %do% {
                       data.table(st_read(con, query = paste0("SELECT pfaf_id, hybas_id FROM basin_boundaries.", regions_all[region_count], "_all")))
                     }     

saveRDS(basin_ids, paste0(data_path, 'db_ids.rds'))
