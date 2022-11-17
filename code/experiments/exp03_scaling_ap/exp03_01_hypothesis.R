source('code/source/libs.R')
source('code/source/graphics.R')
source('code/source/experiments/exp_03.R')
library(gtools)

#Research hypothesis: Precipitation affects the basin shape

basins <- readRDS(paste0(data_path, 'basin_atlas_feats.rds'))

#Assumptions:
# 1. Fractal dimension describes the basin shape. To test this we show how a fractal dim of 1.15 compares to 1.18?

con <- dbConnect(Postgres(), dbname = db_name, host = host_ip, port = port_n,        
                 user = "yannis",      
                 password = rstudioapi::askForPassword("Database password"))

id_basin_117 <- basins[fractal > 1.14 & fractal < 1.15 & level == 7 & coast == 0 & bas_type == "sub-basin", pfaf_id][200] #round
id_basin_120 <- basins[fractal > 1.18 & fractal < 1.19 & level == 7 & coast == 0 & bas_type == "sub-basin", pfaf_id][200] #long

basin_117  <- st_read(con, query = paste0("SELECT * FROM ", db_schema, ".basins_all_regions_4_11 
                                         WHERE pfaf_id = '", id_basin_117, "'"))
basin_120 <- st_read(con, query = paste0("SELECT * FROM ", db_schema, ".basins_all_regions_4_11 
                                         WHERE pfaf_id = '", id_basin_120, "'"))
plot(basin_117)
plot(basin_120)
#Note that the number of polygons (esp. in higher lvls) affects the estimation of fractal dimension

#We also check the relationship between fractal dimension and concavity index for 300k catchments -> Failed!

river_NCI <- readRDS("~/shared/projects/schemata/data/exp05/NCI_global.rds")
river_NCI_mean_pfaf <- subset(river_NCI, select = c("pfaf_id_level", "NCI"))
river_NCI_mean_pfaf <- unique(river_NCI_mean_pfaf)

river_NCI_mean_pfaf[, pfaf_id_level:= as.character(pfaf_id_level)]
river_NCI_mean_pfaf[, pfaf_id_level:= as.character(pfaf_id_level)]

NCI_atlas <- merge(basins, river_NCI_mean_pfaf, by.x = "pfaf_id", by.y = "pfaf_id_level") 

ggplot(NCI_atlas, aes(x = NCI, y = fractal)) +
  geom_point() +
  xlim(-1.0, 0.5) +
  scale_color_manual(values = palette_RdBu(10)) +
  geom_vline(xintercept = 0, col = "gray40")+
  theme_light()

NCI_atlas[fractal_quant < 0.2, median(NCI, na.rm = T)]
NCI_atlas[fractal_quant > 0.9, median(NCI, na.rm = T)]

NCI_atlas[NCI < -0.41, median(prcp, na.rm = T)]
NCI_atlas[NCI > 0, median(prcp, na.rm = T)]

#To verify the research hypothesis, we decompose precipitation in 10 quantiles and plot their empirical prob. density functions

to_plot <- melt(basins[coast == 0, c(-1:-2)], id.vars = c('fractal', 'gc', 'vegetation', 'bas_type', 'climate', 'level',
                                                          'lithology', 'prcp_quant', 'elevation', 'elev_quant', 'area_class'))
to_plot <- to_plot[complete.cases(to_plot)]

ggplot(to_plot[variable == 'prcp'], aes(x = fractal, col = prcp_quant)) +
  geom_density() +
  xlim(1.14, 1.3) +
  scale_color_manual(values = palette_RdBu(5)) +
  theme_light()

#We can also use Granger as an alternative:
ggplot(to_plot[variable == 'prcp'], aes(x = gc, col = prcp_quant)) +
  geom_density() +
  xlim(1, 2.5) +
  scale_color_manual(values = palette_RdBu(10)) +
  theme_light()

#To see if the area of the basin plays a role we further split the catchments at levels with median areas of 135, 1530, and 17400 km2 
#Then we also check all the area quantiles 
basins[, median(area), level]
basin_main_levels <- c(5, 7, 11)

ggplot(to_plot[variable == 'prcp' & level %in% basin_main_levels], aes(x = fractal, col = prcp_quant)) +
  geom_density() +
  xlim(1.14, 1.25) +
  scale_color_manual(values = palette_RdBu(5)) +
  facet_wrap(~level) + 
  theme_light()

ggplot(to_plot[variable == 'prcp'], aes(x = fractal, col = prcp_quant)) +
  geom_density() +
  xlim(1.14, 1.25) +
  scale_color_manual(values = palette_RdBu(5)) +
  facet_wrap(~area_class) + 
  theme_light()

ggplot(to_plot[variable == 'prcp'], aes(x = fractal, fill = prcp_quant)) +
  geom_boxplot(outlier.shape = NA) +
  coord_flip() +
  xlim(1.14, 1.25) +
  scale_fill_manual(values = palette_RdBu(5)) +
  facet_wrap(~area_class) + 
  theme_light()

ggplot(to_plot[variable == 'prcp' & level %in% c(4, 5, 6, 7, 9, 11)], aes(x = fractal, col = prcp_quant)) + #to reduce basin overlap
  geom_density() +
  xlim(1.14, 1.25) +
  scale_color_manual(values = palette_RdBu(5)) +
  facet_wrap(~area_class) + 
  theme_light()

#The main alternative hypothesis is that lithology relates to basin shape. See: https://agupubs.onlinelibrary.wiley.com/doi/10.1029/2012GC004370
ggplot(to_plot[variable == 'prcp' & level %in% basin_main_levels], aes(x = fractal, col = lithology)) +
  geom_density() +
  xlim(1.14, 1.25) +
  facet_wrap(~area_class, scales = 'free') + 
  theme_light()

ggplot(to_plot[variable == 'prcp'], aes(x = fractal, fill = prcp_quant)) +
  geom_boxplot() +
  coord_flip() +
  xlim(1.14, 1.25) +
  scale_color_manual(values = palette_RdBu(10)) +
  facet_wrap(~lithology, scales = 'free') + 
  theme_light()

ggplot(to_plot[variable == 'prcp'], aes(x = fractal, col = prcp_quant)) +
  geom_density() +
  xlim(1.14, 1.25) +
  scale_color_manual(values = palette_RdBu(10)) +
  facet_wrap(~lithology, scales = 'free') + 
  theme_light()

ggplot(to_plot[area_quant == 0.2  & variable == 'prcp'], aes(x = fractal, col = prcp_quant)) +
  geom_density() +
  xlim(1.14, 1.25) +
  scale_color_manual(values = palette_RdBu(10)) +
  facet_wrap(~lithology, scales = 'free') + 
  theme_light()

ggplot(to_plot[area_quant == 0.9  & variable == 'prcp'], aes(x = fractal, col = prcp_quant)) +
  geom_density() +
  xlim(1.14, 1.25) +
  scale_color_manual(values = palette_RdBu(10)) +
  facet_wrap(~lithology, scales = 'free') + 
  theme_light()

ggplot(to_plot[lithology == 'vb' & variable == 'prcp'], aes(x = fractal, col = prcp_quant)) +
  geom_density() +
  xlim(1.14, 1.25) +
  scale_color_manual(values = palette_RdBu(10)) +
  facet_wrap(~area_quant) + 
  theme_light()

#As we see the difference in behaviour related to the scale, in the following scripts we will investigate some additional hypotheses.

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
