#Exploratory data analysis of basins with fractals below 0.1 and above 0.9 quantile
source('code/source/libs.R')
source('code/source/graphics.R')
source('code/source/experiments/exp_03.R')
library(gtools)

basins <- readRDS(paste0(data_path, 'basin_atlas_feats.rds'))

basins[, area_quant := ordered(quantcut(area, 10), labels = seq(0.1, 1, 0.1))]
basins[, prcp_quant := ordered(quantcut(prcp, 10), labels = seq(0.1, 1, 0.1)), by = 'area_quant']
basins[, fractal_quant := ordered(quantcut(fractal, 10), labels = seq(0.1, 1, 0.1))]

basins[fractal_quant > 0.9, median(prcp)] #Long
basins[fractal_quant < 0.2, median(prcp)] #Round
basins[, median(prcp)]
basins[, sd(prcp)]
basins[, quantile(prcp, seq(0,1, 0.1))]

basins_long_round <- basins[fractal_quant >= 1 | fractal_quant <= 0.1] 
basins_long_round[fractal_quant >= 1, shape := factor('long')]
basins_long_round[fractal_quant <= 0.1, shape := factor('round')]
pfaf_long_round <- basins_long_round$pfaf_id

con <- dbConnect(Postgres(), dbname = db_name, host = host_ip, port = port_n,        
                 user = "yannis",      
                 password = rstudioapi::askForPassword("Database password"))

pfaf_long_round_string <- paste("'", pfaf_long_round, "'", sep = "", collapse = ", ")
basins_long_round_sf <- st_read(con, query = paste0("SELECT * FROM ", db_schema, ".basins_all_regions_4_11 
                                         WHERE pfaf_id IN (", pfaf_long_round_string, ")"))

basins_long_round_sf <- basins_long_round_sf %>% 
#  filter(as.numeric(pfaf_id) > 10^10) %>% 
  left_join(basins, by = 'pfaf_id')

basins_long_round[shape == 'long', median(prcp)]

climate_diffs_long <- merge(basins_long_round[shape == 'long', .N, climate],
  basins[, .N, climate], by = "climate")
climate_diffs_long[, climate_ratio := N.x/N.y, climate]

climate_diffs_round <- merge(basins_long_round[shape == 'round', .N, climate],
  basins[, .N, climate], by = "climate")
climate_diffs_round[, climate_ratio := N.x/N.y, climate]

lithology_diffs_long <- merge(basins_long_round[shape == 'long', .N, lithology],
  basins[, .N, lithology], by = "lithology")
lithology_diffs_long[, litho_ratio := N.x/N.y, lithology]

lithology_diffs_round <- merge(basins_long_round[shape == 'round', .N, lithology],
  basins[, .N, lithology], by = "lithology")
lithology_diffs_round[, litho_ratio := N.x/N.y, lithology]

prcp_diffs_long <- merge(basins_long_round[shape == 'long', .N, prcp_quant],
                              basins[, .N, prcp_quant], by = "prcp_quant")
prcp_diffs_long[, prcp_ratio := N.x/N.y, prcp_quant]

prcp_diffs_round <- merge(basins_long_round[shape == 'round', .N, prcp_quant],
                         basins[, .N, prcp_quant], by = "prcp_quant")
prcp_diffs_round[, prcp_ratio := N.x/N.y, prcp_quant]

basins_117 <- basins[fractal < 1.17, .N, lithology]
basins_117[, N := N/sum(basins_117$N)]
basins_120 <- basins[fractal > 1.20, .N, lithology]
basins_120[, N := N/sum(basins_120$N)]
basins_all <- basins[, .N, lithology]
basins_all[, N := N/sum(basins_all$N)]

basins_lithology <- merge(basins_117,
                          basins_120, 
                          by = 'lithology')
basins_lithology <- merge(basins_lithology,
                          basins_all,
                          by = 'lithology')
colnames(basins_lithology)[2:4] <- c('1.17', '1.20', 'all')

basins_lithology[, `1.17`/`1.20`, lithology]
basins_lithology$`1.20`/basins_lithology$all
basins_lithology$`1.17`/basins_lithology$all

basins[fractal > 1.20 & level == 5, median(area, na.rm = T)]
basins[fractal < 1.17 & level == 5, median(area, na.rm = T)]
basins[level == 5, median(area, na.rm = T)]

basins[, area_quant := ordered(quantcut(area, 5), labels = seq(0.2, 1, 0.2))]
basins[, prcp_quant := ordered(quantcut(prcp, 5), labels = seq(0.2, 1, 0.2)), by = 'area_quant']
basins[, elev_quant := ordered(quantcut(elevation, 5), labels = seq(0.2, 1, 0.2))]

lith_prcp <- basins[, .(fractal, lithology, prcp, prcp_quant, area_quant, elev_quant)]

lith_prcp[, median(prcp), lithology]
lith_prcp[, median(fractal), lithology]
lith_prcp[, median(fractal), prcp_quant]
lith_prcp[, median(prcp), area_quant]
lith_prcp[, median(prcp), elev_quant]
lith_prcp[lithology == 'mt', .N, .(prcp_quant, lithology)]
lith_prcp[lithology == 'mt', .N, .(elev_quant, prcp_quant)]
lith_prcp[lithology == 'py', .N, .(elev_quant, prcp_quant)]
lith_prcp[lithology == 'py', .N, .(elev_quant, lithology)]

to_plot <- lith_prcp[, .N, .(, lithology, prcp_quant)]
to_plot <- to_plot[complete.cases(to_plot)]

ggplot(to_plot, aes(x = prcp_quant, y = N, col = lithology, group = lithology)) + 
  geom_point() +
  geom_line() +
  facet_wrap(~elev_quant) + 
theme_light()
  
  ggplot(to_plot[variable == 'prcp'], aes(x = fractal, col = area_quant)) +
  geom_density() +
  xlim(1.14, 1.25) +
  scale_color_manual(values = palette_RdBu(10)) +
  facet_wrap(~elev_quant) + 
  theme_light()


to_plot <- melt(basins[coast == 0, c(-1:-2)], id.vars = c('fractal', 'gc', 'vegetation', 'bas_type', 'climate', 'level',
                                                          'lithology', 'prcp_quant', 'elevation', 'area_quant'))






