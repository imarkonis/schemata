source('code/source/libs.R')
source('code/source/experiments/exp_01.R')

library(RPostgres)
library(dplyr)
library(dbplyr)

basin_tables <- vector()
max_bas_level <- 12

con <- dbConnect(Postgres(), dbname = 'schemata',       
                 user = rstudioapi::askForPassword("Database user"),      
                 password = rstudioapi::askForPassword("Database password"))

for(basin_level in 3:max_bas_level){
  basin_tables[basin_level - 2] <- paste0("hybas_eu_lev", 
                                          formatC(basin_level, width = 2, format = "d", flag = "0"), 
                                          "_v1c")
}

basin_tables_all <- st_read(con, basin_tables[1])
for(count in 2:length(basin_tables)){
  basin_tables_all <- bind_rows(basin_tables_all, st_read(con, basin_tables[count]))
}

write_sf(basin_tables_all, con)


#Validation plots

single_pfaf_id <- 225190431120
string_length <- stringr::str_length(single_pfaf_id)

upscale_pfaf_ids <- vector()
for(i in string_length:3){
  upscale_pfaf_ids[i - 2] <- substr(single_pfaf_id, start = 1, stop = i)
}

single_basin <- basin_tables_all %>% filter(pfaf_id %in% upscale_pfaf_ids)

ggplot(single_basin) +
  geom_sf(aes(fill = log(sub_area))) +
  theme_light()
