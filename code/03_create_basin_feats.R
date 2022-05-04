source('code/source/libs.R')
source('code/source/database.R')
source('code/source/geo_functions.R')


library(sf)

con <- dbConnect(Postgres(), dbname = db_name, host = host_ip, port = port_n,         
                 user = rstudioapi::askForPassword("Database user"),      
                 password = rstudioapi::askForPassword("Database password"))

regions_n <- length(regions_all)

for(region_count in 1:regions_n){
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
  basins[, gc := gc_coef(perimeter, area)]
  basins[, fractal := fractal_dim(perimeter, area)]
  basins[, bas_type := factor("closed")] 
  basins[as.numeric(pfaf_id) %% 2 == 0 & substr(as.numeric(pfaf_id), 
                                                     nchar(as.numeric(pfaf_id)), 
                                                     nchar(as.numeric(pfaf_id))) != 0, bas_type := factor("sub-basin")] 
  basins[as.numeric(pfaf_id) %% 2 == 1, bas_type := factor("interbasin")] 
  basins <- unique(basins[complete.cases(basins)])
  saveRDS(basins, paste0(data_path, 'basin_feats_', regions_all[region_count], '.rds'))
  rm(basins); gc()
}

basin_feats <- foreach(basin_count = 1:regions_n, .packages = c('data.table'), 
                       .combine = 'rbind') %do% {
                         readRDS(paste0(data_path, 'basin_feats_', regions_all[basin_count], '.rds'))
                       }

saveRDS(basin_feats, paste0(data_path, 'basin_feats.rds'))

# Validate
basin_feats <- readRDS(paste0(data_path, 'basin_feats.rds'))
