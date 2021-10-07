source('code/source/libs.R')
source('code/source/geo_functions.R')
source('code/source/experiments/exp_03.R')

library(RPostgres)
library(sf)
library(dbplyr)
library(dplyr)

con <- dbConnect(Postgres(), dbname = db_name, host = host_ip, port = port_n,         
                 user = rstudioapi::askForPassword("Database user"),      
                 password = rstudioapi::askForPassword("Database password"))

for(region_count in 3:length(regions_all)){
  print(regions_all[region_count])
  
bas_borders <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.", regions_all[region_count], "_all"))

basins_n <- length(bas_borders$pfaf_id)
basins <- foreach(basin_count = 1:basins_n, .packages = c('data.table', 'sf'), 
                  .combine = 'rbind') %dopar% {
                    basin <- st_make_valid(bas_borders[basin_count, ])
                    basin_line <- st_cast(basin, "MULTILINESTRING")
                    data.table(pfaf_id = basin$pfaf_id,
                               level = nchar(basin$pfaf_id),
                               area = as.numeric(st_area(basin)),
                               perimeter = as.numeric(st_length(basin_line)))
                  }

basins <- unique(basins[complete.cases(basins)])
saveRDS(basins, paste0(data_path, 'basin_feats_', regions_all[region_count], '.rds'))
rm(basins); gc()
}

