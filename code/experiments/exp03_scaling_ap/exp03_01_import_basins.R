source('code/source/libs.R')
source('code/source/experiments/exp_03.R')

library(RPostgres)
library(sf)
library(dbplyr)
library(dplyr)

min_bas_level <- 6
max_bas_level <- 12
dir.create(paste0('./data/experiments/', experiment, '/basins/level_', min_bas_level))
basin_tables <- vector()

con <- dbConnect(Postgres(), dbname = db_name,       
                 user = rstudioapi::askForPassword("Database user"),      
                 password = rstudioapi::askForPassword("Database password"))

basin_tables_all <- st_read(con, query = paste0("SELECT * FROM ", db_schema, ".eu_all"))

basins_all <- basin_tables_all %>% 
  filter(nchar(pfaf_id) == min_bas_level) %>%
  select(pfaf_id)

ids <- basins_all$pfaf_id
basins_tot <- length(ids)

foreach(basin_n = 1:basins_tot, .packages = 'dplyr') %dopar% {
  basin <- basin_tables_all %>% select(pfaf_id) %>%
    mutate(short_pfaf_id = substr(pfaf_id, 1, min_bas_level)) %>% 
    mutate(pfaf_id = sub("(0+)$", "", pfaf_id)) %>%
    filter(short_pfaf_id %in% ids[basin_n]) 
  basin <- unique(basin)
  saveRDS(basin, paste0(data_path, 'basins/level_', min_bas_level, '/basin_', ids[basin_n], '.rds'))
}

# Validation plots
plot(basins_all)

ggplot(basin) +
  geom_sf(aes(fill = log(sub_area))) +
  theme_light()
