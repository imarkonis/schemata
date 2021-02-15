source('code/source/libs.R')
source('code/source/experiments/exp_03.R')

library(RPostgres)
library(sf)
library(dbplyr)
library(dplyr)

dir.create(paste0('./data/experiments/', experiment, '/basins'))
basin_tables <- vector()
min_bas_level <- 4
max_bas_level <- 12

con <- dbConnect(Postgres(), dbname = db_name,       
                 user = rstudioapi::askForPassword("Database user"),      
                 password = rstudioapi::askForPassword("Database password"))

basin_tables_all <- st_read(con, query = paste0("SELECT * FROM ", db_schema, ".eu_all"))

basins_all <- basin_tables_all %>% 
  filter(nchar(pfaf_id) == min_bas_level & sub_area > 10^4) %>%
  select(pfaf_id)
plot(basins_all)

ids <- basins_all$pfaf_id
basins_tot <- length(ids)

foreach(basin_n = 1:basins_tot, .packages = 'dplyr') %dopar% {
  print(paste0(basin_n, ' / ', basins_tot))
  basin <- basin_tables_all %>% 
   mutate(short_pfaf_id = substr(pfaf_id, 1, min_bas_level)) %>% 
   filter(short_pfaf_id %in% ids[basin_n])
   saveRDS(basin, paste0(data_path, 'basins/basin_', ids[basin_n], '.rds'))
}
# Gives: Error in { : task 1 failed - "Can't slice a scalar"

# Validation plots

ggplot(basin) +
  geom_sf(aes(fill = log(sub_area))) +
  theme_light()
