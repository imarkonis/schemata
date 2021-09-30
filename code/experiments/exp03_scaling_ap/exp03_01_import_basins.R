source('code/source/libs.R')
source('code/source/functions.R')
source('code/source/experiments/exp_03.R')

library(RPostgres)
library(sf)
library(dbplyr)
library(dplyr)

min_bas_level <- 4
max_bas_level <- 11
bas_levels <- c(min_bas_level, max_bas_level)
dir.create(paste0('./data/experiments/', experiment, '/basins/level_', min_bas_level))
basin_tables <- vector()

con <- dbConnect(Postgres(), dbname = db_name, host = host_ip, port = port_n,     
                 user = rstudioapi::askForPassword("Database user"),      
                 password = rstudioapi::askForPassword("Database password"))

basins_all <- db_import_bas_borders(con, regions_all, bas_levels)
write_sf(basins_all, con, Id(schema = db_schema, table = 'basins_all_regions_4_11'))

basins_min_level <- basins_all %>% 
  filter(nchar(pfaf_id) == min_bas_level) 
basin_ids <- basins_min_level$pfaf_id
basins_n <- length(basin_ids)

basins_all <- basins_all %>% 
  mutate(main_basin_id = factor(substr(pfaf_id, 1, min_bas_level))) %>% 
  mutate(short_pfaf_id = factor(sub("(0+)$", "", pfaf_id))) 

foreach(basin_count = 1:basins_n, .packages = 'dplyr') %dopar% {
  basin <- basins_all %>% filter(main_basin_id %in% basin_ids[basin_count]) %>%
    select(main_basin_id, short_pfaf_id, region)
  saveRDS(basin, paste0(data_path, 'basins/level_', min_bas_level, '/basin_', basin_ids[basin_count], '.rds'))
}

# Validation plots
plot(basins_all)

ggplot(basin) +
  geom_sf(aes(fill = log(sub_area))) +
  theme_light()
