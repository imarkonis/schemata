source('code/source/libs.R')
source('code/source/experiments/exp_05.R')
source('code/source/graphics.R')

library(gtools)
library(ggplot2)

regions <- c("af", "as", "na", "au", "eu", "sa_n", "sa_s", "si")

basin_atlas_feats <- readRDS("~/shared/projects/schemata/data/basin_atlas_feats.rds")
basin_atlas_feats_qq <- readRDS("~/shared/projects/schemata/data/basin_atlas_feats_qq.rds")

basin_atlas_feats[, pfaf_id:= as.numeric(pfaf_id)]
basin_atlas_feats_qq[, pfaf_id:= as.numeric(pfaf_id)]

river_NCI <- readRDS("~/shared/projects/schemata/data/exp05/NCI_global.rds")
river_NCI <- readRDS(paste0(data_path, "/NCI_global.rds"))

river_NCI_mean_pfaf <- subset(river_NCI, select = c("pfaf_id_level", "NCI"))
river_NCI_mean_pfaf <- unique(river_NCI_mean_pfaf)

NCI_atlas <- merge(basin_atlas_feats, river_NCI_mean_pfaf, by.x = "pfaf_id", by.y = "pfaf_id_level") 
NCI_atlas_qq <- merge(basin_atlas_feats_qq, river_NCI_mean_pfaf, by.x = "pfaf_id", by.y = "pfaf_id_level") 

to_plot <- melt(NCI_atlas_qq[,c(-1:-2)], id.vars = c('NCI','fractal', 'gc', 'level'))
to_plot <- to_plot[complete.cases(to_plot)]

ggplot(to_plot, aes(x = NCI, col = value)) +
  geom_density() +
  facet_wrap(~variable) + 
  xlim(-1.0, 0.5) +
  scale_color_manual(values = palette_RdBu(10)) +
  geom_vline(xintercept = 0, col = "gray40")+
  theme_light()
ggsave()


to_plot <- melt(NCI_atlas_qq[pfaf_id %in% NCI_atlas[bas_type == 'sub-basin', pfaf_id], c(-1:-2)], id.vars = c("NCI",'fractal', 'gc', 'level'))
to_plot <- to_plot[complete.cases(to_plot)]

ggplot(to_plot, aes(x = NCI, col = value)) +
  geom_density() +
  facet_wrap(~variable) + 
  xlim(-1.0, 0.5) +
  scale_color_manual(values = palette_RdBu(10)) +
  theme_light()

ggplot(to_plot[variable == 'prcp'], aes(x = NCI, col = value)) +
  geom_density() +
  facet_wrap(~level, scales = 'free') + 
  xlim(-1.0, 0.5) +
  scale_color_manual(values = palette_RdBu(10)) +
  theme_light()

NCI_atlas[, area_quant := ordered(quantcut(area, 10), labels = seq(0.1, 1, 0.1)), by = 'level']

to_plot <- melt(NCI_atlas[, c(-1:-2)], id.vars = c('level','NCI','fractal', 'gc', 'vegetation', 'bas_type', 'climate', 
                                                      'lithology', 'area_quant', 'elevation'))
to_plot <- to_plot[complete.cases(to_plot)]

ggplot(to_plot[variable == 'prcp'], aes(x = NCI, col = value)) +
  geom_density() +
  xlim(-1.0, 0.5) +
  scale_color_manual(values = palette_RdBu(10)) +
  facet_wrap(~bas_type) + 
  theme_light()

ggplot(to_plot[variable == 'prcp'], aes(x = NCI, col = value)) +
  geom_density() +
  xlim(-1.0, 0.5) +
  scale_color_manual(values = palette_RdBu(10)) +
  facet_wrap(~lithology) + 
  theme_light()

ggplot(to_plot[variable == 'prcp'], aes(x = NCI, col = value)) +
  geom_density() +
  xlim(-1.0, 0.5) +  
  scale_color_manual(values = palette_RdBu(10)) +
  facet_wrap(~area_quant) + 
  theme_light()


