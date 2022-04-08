source('code/source/libs.R')
source('code/source/graphics.R')
source('code/source/experiments/exp_03.R')

basins <- readRDS(paste0(data_path, 'basin_atlas_feats.rds'))
basins_qq <- readRDS(paste0(data_path, 'basin_atlas_feats_qq.rds'))

to_plot <- melt(basins_qq[, c(-1:-4, -7:-8)], id.vars = c('fractal', 'gc'))
to_plot <- to_plot[complete.cases(to_plot)]

ggplot(to_plot, aes(x = fractal, col = value)) +
  geom_density() +
  facet_wrap(~variable) + 
  xlim(1.14, 1.3) +
  scale_color_manual(values = palette_RdBu(10)) +
  theme_light()
ggsave()

ggplot(to_plot, aes(x = gc, col = value)) +
  geom_density() +
  facet_wrap(~variable) + 
  xlim(1.14, 1.3) +
  scale_color_manual(values = palette_RdBu(10)) +
  theme_light()

to_plot <- melt(basins_qq[, c(6, 7)], id.vars = 'fractal')
to_plot <- to_plot[complete.cases(to_plot)]
ggplot(to_plot[1:10,], aes(x = fractal, col = value)) +
  geom_density() +
  xlim(1.14, 1.3) +
  scale_color_manual(values = palette_RdBu(16)) +
  theme_light()

to_plot <- melt(basins_qq[, c(6, 8)], id.vars = 'fractal')
to_plot <- to_plot[complete.cases(to_plot)]
ggplot(to_plot, aes(x = fractal, col = value)) +
  geom_density() +
  xlim(1.14, 1.3) +
  scale_color_manual(values = palette_RdBu(6)) +
  theme_light()

basins[, area_quant := ordered(quantcut(area, 10), labels = seq(0.1, 1, 0.1)), by = 'level']

to_plot <- melt(basins[, c(-1:-4)], id.vars = c('fractal', 'gc', 'vegetation', 
                                                'lithology', 'area_quant', 'elevation'))
to_plot <- to_plot[complete.cases(to_plot)]

ggplot(to_plot[variable == 'prcp'], aes(x = fractal, col = value)) +
  geom_density() +
  xlim(1.14, 1.3) +
  scale_color_manual(values = palette_RdBu(10)) +
  facet_wrap(~vegetation) + 
  theme_light()

ggplot(to_plot[variable == 'prcp'], aes(x = fractal, col = value)) +
  geom_density() +
  xlim(1.14, 1.3) +
  scale_color_manual(values = palette_RdBu(10)) +
  facet_wrap(~lithology) + 
  theme_light()

ggplot(to_plot[variable == 'prcp'], aes(x = fractal, col = value)) +
  geom_density() +
  xlim(1.14, 1.3) +
  scale_color_manual(values = palette_RdBu(10)) +
  facet_wrap(~area_quant) + 
  theme_light()

ggplot(to_plot[variable == 'prcp'], aes(x = gc, col = value)) +
  geom_density() +
  xlim(1, 2.5) +
  scale_color_manual(values = palette_RdBu(10)) +
  facet_wrap(~area_quant) + 
  theme_light()

ggplot(to_plot[variable == 'slope'], aes(x = fractal, col = value)) +
  geom_density() +
  xlim(1.14, 1.3) +
  scale_color_manual(values = palette_RdBu(10)) +
  facet_wrap(~elevation) + 
  theme_light()

to_plot <- melt(basins[, c(-1:-4)], id.vars = c('fractal', 'gc', 'prcp', 'area_quant'))
to_plot <- to_plot[complete.cases(to_plot)]

ggplot(to_plot[variable == 'slope'], aes(x = fractal, col = value)) +
  geom_density() +
  xlim(1.14, 1.3) +
  scale_color_manual(values = palette_RdBu(10)) +
  theme_light()

ggplot(basins, aes(log(area), log(perimeter), group = prcp_class, col = prcp_class)) +
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
