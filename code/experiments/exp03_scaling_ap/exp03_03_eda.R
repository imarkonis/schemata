source('code/source/libs.R')
source('code/source/geo_functions.R')
source('code/source/experiments/exp_03.R')

library(RPostgres)
library(sf)
library(dbplyr)
library(dplyr)

basin_level <- 6
lm_coefs <- readRDS(paste0(results_path, 'pa_lm_coefs_', basin_level, '.rds'))
basin_feats <- readRDS(paste0(data_path, 'basin_feats_', basin_level, '.rds'))
con <- dbConnect(Postgres(), dbname = db_name,       
                 user = rstudioapi::askForPassword("Database user"),      
                 password = rstudioapi::askForPassword("Database password"))

basins <- st_read(con, query = paste0("SELECT * FROM ", db_schema, ".eu_", basin_level))

basins <- basins %>% 
#  filter(sub_area > 10^4) %>%
  select(pfaf_id) 

basins <- merge(basins, lm_coefs, by = 'pfaf_id')

plot(basins["slope"])
summary(lm_coefs)
hist(lm_coefs$slope, breaks = 25)

basins_2 <- basins %>% 
  filter(slope < 2)
plot(basins_2["slope"])

basin_feats[, gc := gc_estimate(perimeter, area)]
basins_more <- merge(lm_coefs, basin_feats, by = 'pfaf_id')
basins_more <- basins_more[complete.cases(basins_more)]

to_plot <- basins_more[, .(area = max(area)), pfaf_id]
to_plot <- unique(basins_more[to_plot, on = c('area', 'pfaf_id')])

ggplot(to_plot[gc < 5 & slope < 2.2], aes(gc, slope)) +
  geom_point() +
  theme_light()




