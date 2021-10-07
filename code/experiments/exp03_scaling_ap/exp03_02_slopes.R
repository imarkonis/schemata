source('code/source/libs.R')
source('code/source/geo_functions.R')
source('code/source/experiments/exp_03.R')

basin_feats <- foreach(basin_count = 1:length(regions_all), .packages = c('data.table'), 
                        .combine = 'rbind') %do% {
                          readRDS(paste0(data_path, 'basin_feats_', regions_all[basin_count], '.rds'))
                        }

ggplot(basin_feats, aes(log(area), log(area), group = level, col = level)) +
#  geom_density_2d(bins = 100) +
  geom_smooth(method = 'lm', se = F) +
  theme_light()

lm_fit <- lm(log(area) ~ log(perimeter), data = basin_feats)
lm_coefs <- basin_feats[, as.list(coef(lm(log(area) ~ log(perimeter)))), .(level)]

saveRDS(basin_feats, paste0(data_path, 'basin_feats.rds'))
