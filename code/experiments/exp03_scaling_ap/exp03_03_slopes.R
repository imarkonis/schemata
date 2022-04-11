source('code/source/libs.R')
source('code/source/geo_functions.R')
source('code/source/experiments/exp_03.R')

basin_feats <- readRDS(paste0(data_path, 'basin_atlas_feats.rds'))

ggplot(basin_feats[coast == 0], aes(log(area), log(perimeter))) +
  geom_point(size = 0.1, alpha = 0.2) + 
  geom_smooth(method = 'lm', se = F) +
  facet_wrap(~climate) +
  theme_light()

ggplot(basin_feats[coast == 0], aes(log(area), log(prcp))) +
  geom_point(size = 0.1, alpha = 0.2) + 
  geom_smooth(method = 'lm', se = F) +
  facet_wrap(~climate) +
  theme_light()

lm_fit <- lm(log(area) ~ log(perimeter), data = basin_feats)
lm_coefs <- basin_feats_qq[, as.list(coef(lm(log(perimeter) ~ log(area)))), .(area_quant)]

