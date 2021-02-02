library(DBI)
library(RPostgres)
library(sf)
library(dplyr)
library(dbplyr)

con <- dbConnect(Postgres(), dbname = 'schemata',       
                 user = rstudioapi::askForPassword("Database user"),      
                 password = rstudioapi::askForPassword("Database password"))
basin_tables <- vector()
max_bas_level <- 12

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


aa <- basin_tables_all %>% filter(pfaf_id %in% upscale_pfaf_ids)

ggplot(aa) +
  geom_sf(aes(fill = log(sub_area))) +
  theme_light()







ne_world <- rnaturalearth::ne_countries(scale = 50, returnclass = "sf")
world_map_crs <- "+proj=eqearth +wktext"

ne_world %>% 
  st_transform(world_map_crs) %>% 
  ggplot() +
  geom_sf(fill = 'brown', colour = "black") +
  theme(panel.background = element_rect(fill = 'grey80'))

st_write(ne_world, dsn = con, layer = "ne_world", append = FALSE)

    


st_drivers() %>% 
  filter(grepl("Post", name))


