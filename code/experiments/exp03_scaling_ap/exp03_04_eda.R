ggplot(basin_feats, aes(log(area), log(perimeter), group = prcp_class, col = prcp_class)) +
  #  geom_density_2d(bins = 100) +
  geom_smooth(method = 'lm', se = F) +
  theme_light()

ggplot(basin_feats, aes(log(area), log(perimeter), group = elev_class, col = elev_class)) +
  #  geom_density_2d(bins = 100) +
  geom_smooth(method = 'lm', se = F) +
  theme_light()

ggplot(basin_feats, aes(area, elevation, col = fractal)) +
  geom_point() +
  theme_light()

ggplot(basin_feats, aes(prcp, elevation)) +
  geom_point() +
  theme_light()

ggplot(basin_feats, aes(x = fractal, col = prcp_class)) +
  geom_density() +
  xlim(1.14, 1.3) +
  theme_light()

ggplot(basin_feats, aes(x = fractal, col = elev_class)) +
  geom_density() +
  xlim(1.14, 1.3) +
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
