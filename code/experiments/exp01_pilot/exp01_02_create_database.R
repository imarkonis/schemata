source('code/source/libs.R')
source('code/source/experiments/exp_01.R')

library(RPostgres)
library(dplyr)
library(dbplyr)

basin_tables <- vector()
max_bas_level <- 12

con <- dbConnect(Postgres(), dbname = db_name,       
                 user = rstudioapi::askForPassword("Database user"),      
                 password = rstudioapi::askForPassword("Database password"))

for(basin_level in 3:max_bas_level){
  basin_tables[basin_level - 2] <- paste0("eu_", basin_level)
}

eu_all <- st_read(con, query = paste0("SELECT * FROM ", db_schema, ".", basin_tables[1]))

for(bas_count in 2:length(basin_tables)){
  eu_all <- bind_rows(eu_all, st_read(con, query = paste0("SELECT * FROM ", db_schema, ".", basin_tables[bas_count])))
}

write_sf(eu_all, con, Id(schema = db_schema, table = 'eu_all'))

#Validation plots

single_pfaf_id <- 225190431120
string_length <- stringr::str_length(single_pfaf_id)

upscale_pfaf_ids <- vector()
for(i in string_length:3){
  upscale_pfaf_ids[i - 2] <- substr(single_pfaf_id, start = 1, stop = i)
}

basin_all <- st_read(con, basin_tables_all)
single_basin <- basin_tables_all %>% filter(pfaf_id %in% upscale_pfaf_ids)

ggplot(single_basin) +
  geom_sf(aes(fill = log(sub_area))) +
  theme_light()
