
source('code/source/libs.R')
source('code/source/functions.R')
source('code/source/geo_utils.R')
source('code/source/database.R')
source('code/source/geo_functions.R')
source('code/source/experiments/exp_05.R')

library(ggplot2)
options(scipen = 20)

regions <- c("af", "as", "na", "au", "eu", "sa_n", "sa_s", "si")

basin_atlas_feats <- readRDS("data/experiments/exp03/basin_atlas_feats.rds")
basin_atlas_feats_qq <- readRDS("data/experiments/exp03/basin_atlas_feats_qq.rds")

for(i in 1:length(regions)){
  river_NCI <- readRDS(paste0(data_path, '/',regions[i],'_NCI_sel.rds'))
  if(i == 1){
    basin_atlas_feats <- merge(basin_atlas_feats, river_NCI, by = "pfaf_id", all = TRUE)
    basin_atlas_feats_qq <- merge(basin_atlas_feats_qq, river_NCI, by = "pfaf_id", all = TRUE)
  }else{
    basin_atlas_feats <- merge(basin_atlas_feats, river_NCI, by = names(river_NCI), all = TRUE)
    basin_atlas_feats_qq <- merge(basin_atlas_feats_qq, river_NCI, by = names(river_NCI), all = TRUE)
  }
}

basin_qq <- basin_atlas_feats_qq[type !="region"]
basin <- basin_atlas_feats[type !="region"]

to_plot <- melt(basin_qq[,c(-1:-2, -4, -5, -6, -7)], id.vars = c('NCI','fractal', 'gc', 'level'))
to_plot <- to_plot[complete.cases(to_plot)]

ggplot(to_plot, aes(x = NCI, col = value)) +
  geom_density() +
  facet_wrap(~variable) + 
  xlim(-1.0, 0.5) +
  scale_color_manual(values = palette_RdBu(10)) +
  theme_light()
ggsave()


to_plot <- melt(basin_qq[pfaf_id %in% basin[bas_type == 'sub-basin', pfaf_id], c(-1:-2, -4, -5, -6, -7)], id.vars = c("NCI",'fractal', 'gc', 'level'))
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

basin[level > 3 & level < 12, area_quant := ordered(quantcut(area, 10), labels = seq(0.1, 1, 0.1)), by = 'level']

to_plot <- melt(basin[, c(-1:-2, -4:-9)], id.vars = c('NCI','fractal', 'gc', 'vegetation', 'bas_type',
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


