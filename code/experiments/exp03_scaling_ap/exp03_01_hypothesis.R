source('code/source/libs.R')
source('code/source/graphics.R')
source('code/source/experiments/exp_03.R')
library(gtools)

#Research hypothesis: Precipitation affects the basin shape

basins <- readRDS(paste0(data_path, 'basin_atlas_feats.rds'))
basins_qq <- readRDS(paste0(data_path, 'basin_atlas_feats_qq.rds'))


#Assumptions:
# 1. Fractal dimension describes the basin shape. To test this we show how a fractal dim of 1.15 compares to 1.18?

con <- dbConnect(Postgres(), dbname = db_name, host = host_ip, port = port_n,        
                 user = "yannis",      
                 password = rstudioapi::askForPassword("Database password"))


id_basin_117 <- basins[fractal > 1.14 & fractal < 1.15 & level == 7 & coast == 0 & bas_type == "sub-basin", pfaf_id][200]
id_basin_120 <- basins[fractal > 1.18 & fractal < 1.19 & level == 7 & coast == 0 & bas_type == "sub-basin", pfaf_id][200]

basin_117  <- st_read(con, query = paste0("SELECT * FROM ", db_schema, ".basins_all_regions_4_11 
                                         WHERE pfaf_id = '", id_basin_117, "'"))
basin_120 <- st_read(con, query = paste0("SELECT * FROM ", db_schema, ".basins_all_regions_4_11 
                                         WHERE pfaf_id = '", id_basin_120, "'"))
plot(basin_117)
plot(basin_120)
#Note that the number of polygons (esp. in higher lvls) affects the estimation of fractal dimension

#To verify the research hypothesis, we decompose precipitation in 10 quantiles and plot their empirical prob. density functions

basins[, prcp_quant := ordered(quantcut(prcp, 10), labels = seq(0.1, 1, 0.1)), by = 'level']

to_plot <- melt(basins[coast == 0, c(-1:-2)], id.vars = c('fractal', 'gc', 'vegetation', 'bas_type', 'climate', 'level',
                                                          'lithology', 'prcp_quant', 'elevation'))
to_plot <- to_plot[complete.cases(to_plot)]

ggplot(to_plot[variable == 'prcp'], aes(x = fractal, col = prcp_quant)) +
  geom_density() +
  xlim(1.14, 1.3) +
  scale_color_manual(values = palette_RdBu(10)) +
  theme_light()

#We can also use GRanger as an alternative:
ggplot(to_plot[variable == 'prcp'], aes(x = gc, col = prcp_quant)) +
  geom_density() +
  xlim(1, 2.5) +
  scale_color_manual(values = palette_RdBu(10)) +
  theme_light()


#To see if the area of the basin plays a role we further split the catchments at levels with areas of 100, 1000, and 10000 km2 
basin_main_levels <- c(5, 7, 11)

ggplot(to_plot[variable == 'prcp' & level %in% basin_main_levels], aes(x = fractal, col = prcp_quant)) +
  geom_density() +
  xlim(1.14, 1.25) +
  scale_color_manual(values = palette_RdBu(10)) +
  facet_wrap(~level) + 
  theme_light()

#The main alternative hypothesis is that lithology relates to basin shape. See: https://agupubs.onlinelibrary.wiley.com/doi/10.1029/2012GC004370
ggplot(to_plot[variable == 'prcp' & level %in% basin_main_levels], aes(x = fractal, col = lithology)) +
  geom_density() +
  xlim(1.14, 1.25) +
  scale_color_manual(values = palette_RdBu(15)) +
  facet_wrap(~level) + 
  theme_light()


#############################

ggplot(to_plot[variable == 'prcp' & level == 11], aes(x = fractal, col = prcp_quant)) +
  geom_density() +
  xlim(1.14, 1.25) +
  scale_color_manual(values = palette_RdBu(10)) +
  facet_wrap(~lithology, scales = 'free') + 
  theme_light()

ggplot(to_plot[variable == 'prcp' & level == 11], aes(x = fractal, col = prcp_quant)) +
  geom_density() +
  xlim(1.14, 1.25) +
  scale_color_manual(values = palette_RdBu(10)) +
  facet_wrap(~lithology, scales = 'free') + 
  theme_light()

ggplot(to_plot[variable == 'prcp'], aes(x = fractal, col = area_quant)) +
  geom_density() +
  xlim(1.14, 1.3) +
  scale_color_manual(values = palette_RdBu(10)) +
  facet_wrap(~vegetation) + 
  theme_light()

ggplot(to_plot[variable == 'prcp'], aes(x = fractal, col = area_quant)) +
  geom_density() +
  xlim(1.14, 1.3) +
  scale_color_manual(values = palette_RdBu(10)) +
  facet_wrap(~lithology) + 
  theme_light()

ggplot(to_plot[variable == 'prcp'], aes(x = fractal, col = area_quant)) +
  geom_density() +
  xlim(1.14, 1.3) +
  scale_color_manual(values = palette_RdBu(10)) +
  theme_light()

ggplot(to_plot[variable == 'prcp'], aes(x = gc, col = area_quant)) +
  geom_density() +
  xlim(1, 2.5) +
  scale_color_manual(values = palette_RdBu(10)) +
  facet_wrap(~bas_type) + 
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
