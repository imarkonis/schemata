source('code/source/libs.R')
source('code/source/geo_functions.R')
source('code/source/experiments/exp_03.R')

library(RPostgres)
library(sf)
library(dbplyr)
library(dplyr)

lm_coefs <- readRDS(paste0(results_path, 'pa_lm_coefs.rds'))

con <- dbConnect(Postgres(), dbname = 'schemata',       
                 user = rstudioapi::askForPassword("Database user"),      
                 password = rstudioapi::askForPassword("Database password"))
basins <- read_sf(con, 'hybas_eu_lev04_v1c')

basins <- basins %>% 
  filter(sub_area > 10^4) %>%
  select(pfaf_id) 

basins <- merge(basins, lm_coefs, by = 'pfaf_id')

plot(basins["slope"])
summary(lm_coefs)
hist(lm_coefs$log_area, breaks = 25)










