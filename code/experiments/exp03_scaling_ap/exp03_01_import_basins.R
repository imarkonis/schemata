source('code/source/libs.R')
source('code/source/experiments/exp_03.R')

library(RPostgres)
library(sf)
library(dbplyr)
library(dplyr)

basin_tables <- vector()
min_bas_level <- 4
max_bas_level <- 12


con <- dbConnect(Postgres(), dbname = 'schemata',       
                 user = rstudioapi::askForPassword("Database user"),      
                 password = rstudioapi::askForPassword("Database password"))
basin_tables_all <- read_sf(con, 'basin_tables_all')

upscale_pfaf_ids <- vector()
for(i in string_length:min_bas_level){
  upscale_pfaf_ids[i - 2] <- substr(single_pfaf_id, start = 1, stop = i)
}

basins_all <- basin_tables_all %>% 
  filter(nchar(pfaf_id) == min_bas_level & sub_area > 10^4) %>%
  select(pfaf_id)
plot(basins_all)

ids <- basins_all$pfaf_id
basins_tot <- length(ids)

for(basin_n in 1:basins_tot) {
  print(paste0(basin_n, ' / ', basins_tot))
  basin <- basin_tables_all %>% 
    mutate(short_pfaf_id = substr(pfaf_id, 1, min_bas_level)) %>% 
    filter(short_pfaf_id %in% ids[basin_n])
  saveRDS(basin, paste0(data_path, 'basins/basin_', ids[basin_n], '.rds'))
}

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
