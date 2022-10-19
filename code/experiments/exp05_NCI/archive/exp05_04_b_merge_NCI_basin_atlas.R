
source('code/source/libs.R')
source('code/source/experiments/exp_05.R')
source('code/source/graphics.R')

library(gtools)
library(ggplot2)

river_NCI <- readRDS(paste0(data_path, "/NCI_global.rds"))
basin_atlas <- readRDS(paste0(data_path, "/basin_atlas_global.rds"))
NCI_atlas_dt <- merge(basin_atlas, river_NCI, by = "hybas_id") 
NCI_atlas_dt[, pfaf_level := nchar(pfaf_id_level)]
NCI_atlas_dt[, prcp_qq := factor(quantcut(prcp, 10), labels = seq(0.1, 1, 0.1))]
NCI_atlas_dt[, arid_qq := factor(quantcut(aridity, 10), labels = seq(0.1, 1, 0.1))]


ggplot(NCI_atlas_dt) +
  geom_density(aes(x = NCI, col = prcp_qq))+
  scale_color_manual(values = palette_RdBu(10)) +
  xlim(-1.0, 0.5) +
  theme_light()


ggplot(NCI_atlas_dt) +
  geom_density(aes(x = NCI, col = arid_qq))+
  scale_color_manual(values = palette_RdBu(10)) +
  xlim(-1.0, 0.5) +
  theme_light()

ggplot(NCI_atlas_dt[pfaf_level > 5]) +
  geom_density(aes(x= NCI, col = as.factor(pfaf_level)))+
  scale_color_manual(values = palette_Bu(10)) +
  xlim(-1.0, 0.5) +
  theme_light()

ggplot(NCI_atlas_dt[pfaf_level < 4]) +
  geom_histogram(aes(x= NCI, fill = as.factor(pfaf_level)), binwidth = 0.05)+
  scale_fill_manual(values = palette_Bu(3)) +
  xlim(-1.0, 0.5) +
  theme_light()
