source('code/source/libs.R')
source('code/source/geo_functions.R')
source('code/source/experiments/exp_03.R')

library(RPostgres)
library(sf)

con <- dbConnect(Postgres(), dbname = db_name, host = host_ip, port = port_n,         
                 user = rstudioapi::askForPassword("Database user"),      
                 password = rstudioapi::askForPassword("Database password"))

basin_ids <- foreach(region_count = 1:length(regions_all), .packages = c('data.table', 'sf', 'RPostgres' ), 
                  .combine = 'rbind') %do% {
                  data.table(st_read(con, query = paste0("SELECT pfaf_id, hybas_id FROM basin_boundaries.", regions_all[region_count], "_all")))
                  }                    

basin_feats <- readRDS(paste0(data_path, 'basin_feats.rds'))
basin_feats <- merge(basin_ids, basin_feats, by = 'pfaf_id')
basin_atlas_11 <- data.table(st_read(con, query = paste0("SELECT hybas_id, ele_mt_sav, pre_mm_syr FROM basin_atlas.basins_11")))
colnames(basin_atlas_11) <- c('hybas_id', 'elevation', 'prcp')
basin_feats <- merge(basin_feats[level == 11], basin_atlas_11, by = 'hybas_id')
basin_feats[elevation < 100, elev_class := factor('low')]
basin_feats[elevation > 2000, elev_class := factor('high')]
basin_feats[prcp < 50, prcp_class := factor('dry')]
basin_feats[prcp > 2000, prcp_class := factor('wet')]
            

ggplot(basin_feats, aes(log(area), log(perimeter), group = prcp_class, col = prcp_class)) +
  #  geom_density_2d(bins = 100) +
  geom_smooth(method = 'lm', se = F) +
  theme_light()

ggplot(basin_feats, aes(log(area), log(perimeter), group = elev_class, col = elev_class)) +
  #  geom_density_2d(bins = 100) +
  geom_smooth(method = 'lm', se = F) +
  theme_light()

lm_coefs_low <- basin_feats[elevation < 100, as.list(coef(lm(log(area) ~ log(perimeter))))]
lm_coefs_high <- basin_feats[elevation > 2000, as.list(coef(lm(log(area) ~ log(perimeter))))]

ggplot(basin_feats, aes(area, elevation, col = fractal)) +
  geom_point() +
  theme_light()

lm_coefs_dry <- basin_feats[prcp < 30, as.list(coef(lm(log(area) ~ log(perimeter))))]
lm_coefs_wet <- basin_feats[prcp > 2000, as.list(coef(lm(log(area) ~ log(perimeter))))]

basin_feats[prcp < 40, median(fractal)]
basin_feats[prcp > 2000, median(fractal)]

basin_feats[elevation < 100, median(fractal)]
basin_feats[elevation > 2000, median(fractal)]

ggplot(basin_feats[elevation > 2000], aes(log(area), log(perimeter), group = level, col = level)) +
  #  geom_density_2d(bins = 100) +
  geom_smooth(method = 'lm', se = F) +
  theme_light()
