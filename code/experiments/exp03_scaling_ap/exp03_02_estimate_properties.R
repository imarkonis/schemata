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

bas_borders <- st_read(con, query = "SELECT * FROM basin_boundaries.basins_all_regions_4_11")


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
saveRDS(basins, paste0(data_path, 'basin_feats_', basin_level, '.rds'))

basins[, log_area := log(area)]
basins[, log_perimeter := log(perimeter)]
lm_coefs <- basins[, as.list(coef(lm(log_area ~ log_perimeter))), .(pfaf_id, region)]
lm_coefs <- unique(lm_coefs[complete.cases(lm_coefs)])
colnames(lm_coefs)[3:4] <- c('intercept', 'slope')
saveRDS(lm_coefs, paste0(results_path, 'pa_lm_coefs_', basin_level, '.rds'))
