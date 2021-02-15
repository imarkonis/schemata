source('code/source/libs.R')
source('code/source/experiments/exp_03.R')

library(RPostgres)
library(sf)
library(dbplyr)
library(dplyr)

basin_tables <- vector()
max_bas_level <- 12

con <- dbConnect(Postgres(), dbname = 'schemata',       
                 user = rstudioapi::askForPassword("Database user"),      
                 password = rstudioapi::askForPassword("Database password"))
basin_tables_all <- read_sf(con, 'basin_tables_all')

single_pfaf_id <- 225190431120
string_length <- stringr::str_length(single_pfaf_id)

upscale_pfaf_ids <- vector()
for(i in string_length:3){
  upscale_pfaf_ids[i - 2] <- substr(single_pfaf_id, start = 1, stop = i)
}

single_basin <- basin_tables_all %>% filter(pfaf_id %in% upscale_pfaf_ids)
saveRDS(single_basin, paste0('./data/experiments/', experiment, '/single_basin.rds'))

single_pfaf_id <- '225'
multi_basins <- basin_tables_all %>% 
  mutate(short_pfaf_id = substr(pfaf_id, 1, 3)) %>% 
  filter(short_pfaf_id %in% single_pfaf_id)
saveRDS(multi_basins, paste0('./data/experiments/', experiment, '/basins_225.rds'))

single_pfaf_id <- '222'
multi_basins <- basin_tables_all %>% 
  mutate(short_pfaf_id = substr(pfaf_id, 1, 3)) %>% 
  filter(short_pfaf_id %in% single_pfaf_id)
saveRDS(multi_basins, paste0('./data/experiments/', experiment, '/basins_222.rds'))

single_pfaf_id <- '271'
multi_basins <- basin_tables_all %>% 
  mutate(short_pfaf_id = substr(pfaf_id, 1, 3)) %>% 
  filter(short_pfaf_id %in% single_pfaf_id)
saveRDS(multi_basins, paste0('./data/experiments/', experiment, '/basins_271.rds'))

ids <- basin_tables_all %>% 
  filter(nchar(pfaf_id) == 3)

# Validation plots

ggplot(single_basin) +
  geom_sf(aes(fill = log(sub_area))) +
  theme_light()

ggplot(multi_basins) +
  geom_sf(aes(fill = log(sub_area))) +
  theme_light()
