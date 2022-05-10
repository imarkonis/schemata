source('code/source/libs.R')
source('code/source/database.R')


library(dplyr)
library(dbplyr)

basin_tables <- vector()
min_bas_level <- min(basin_levels)
max_bas_level <- max(basin_levels)
regions_n <- length(regions_all)
  
for(region_count in 1:regions_n){
  for(basin_level in min_bas_level:max_bas_level){
    basin_tables[basin_level - 2] <- paste0(regions_all[region_count], "_", basin_level)
  }
  region_all <- st_read(con, query = paste0("SELECT * FROM ", db_schema, ".", basin_tables[1]))
  region_all$pfaf_id <- as.character(region_all$pfaf_id)
  for(bas_count in 1:length(basin_tables)){
    region <- st_read(con, query = paste0("SELECT * FROM ", db_schema, ".", basin_tables[bas_count]))
    region$pfaf_id <- as.character(region$pfaf_id)
    region_all <- bind_rows(region_all, region)
    print(basin_tables[bas_count])
  }
    table_name <- paste0(regions_all[region_count], '_all')
  write_sf(region_all, con, Id(schema = db_schema, table = table_name))
  table_name <- paste0(regions_all[region_count], '_basins')
  write_sf(region_all["pfaf_id"], con, Id(schema = db_schema, table = table_name))
}
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
