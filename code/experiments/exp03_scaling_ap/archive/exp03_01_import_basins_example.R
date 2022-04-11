source('code/source/libs.R')
source('code/source/experiments/exp_03.R')

library(RPostgres)
library(sf)
library(dbplyr)
library(dplyr)

basin_tables <- vector()
max_bas_level <- 11

con <- dbConnect(Postgres(), dbname = db_name, host = host_ip, port = port_n,         
                 user = rstudioapi::askForPassword("Database user"),      
                 password = rstudioapi::askForPassword("Database password"))
basin_tables_all <- read_sf(con, Id(schema = "basin_boundaries", table = "basins_all_regions_4_11"))
                            
single_pfaf_id <- 225190431120
string_length <- stringr::str_length(single_pfaf_id)

upscale_pfaf_ids <- vector()
for(i in string_length:3){
  upscale_pfaf_ids[i - 2] <- substr(single_pfaf_id, start = 1, stop = i)
}

single_basin <- basin_tables_all %>% filter(pfaf_id %in% upscale_pfaf_ids)
saveRDS(single_basin, paste0('./data/experiments/', experiment, '/basins/single_basin.rds'))

sample_region <- regions_all[5] # Sample region is Europe
sample_pfaf_id <- 22

basin_22 <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.", 
                            sample_region, "_all WHERE pfaf_id like '", sample_pfaf_id, "%'"))


basin_222 <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.", 
                      sample_region, "_all WHERE pfaf_id like '", sample_pfaf_id,"%'"))
saveRDS(basin_222, paste0('./data/experiments/', experiment, '/basins/basins_222.rds'))

single_pfaf_id <- '222'
multi_basins <- basin_tables_all %>% 
  mutate(short_pfaf_id = substr(pfaf_id, 1, 3)) %>% 
  filter(short_pfaf_id %in% single_pfaf_id)
saveRDS(multi_basins, paste0('./data/experiments/', experiment, '/basins/basins_222.rds'))

single_pfaf_id <- '271'
multi_basins <- basin_tables_all %>% 
  mutate(short_pfaf_id = substr(pfaf_id, 1, 3)) %>% 
  filter(short_pfaf_id %in% single_pfaf_id)
saveRDS(multi_basins, paste0('./data/experiments/', experiment, '/basins/basins_271.rds'))

ids <- basin_tables_all %>% 
  filter(nchar(pfaf_id) == 3)

# Validation plots

ggplot(single_basin) +
  geom_sf() +
  theme_light()

ggplot(basin_222) +
  geom_sf() +
  theme_light()
