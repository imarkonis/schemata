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

basins_eu <- st_read(con, query = paste0("SELECT * FROM ", db_schema, ".eu_basins"))
basins_eu$region <- factor("eu")
basins_au <- st_read(con, query = paste0("SELECT * FROM ", db_schema, ".au_basins"))
basins_au$region <- factor("au")

basins_all <- bind_rows(basins_au, basins_eu)

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
