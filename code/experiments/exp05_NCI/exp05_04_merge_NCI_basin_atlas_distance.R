
source('code/source/libs.R')
source('code/source/experiments/exp_05.R')
source('code/source/graphics.R')

library(ggplot2)
library(gtools)

options(scipen = 20)

regions <- c("af", "as", "na", "au", "eu", "sa_n", "sa_s")

basin_atlas_feats <- readRDS("data/experiments/exp03/basin_atlas_feats.rds")
basin_atlas_feats_qq <- readRDS("data/experiments/exp03/basin_atlas_feats_qq.rds")

for(i in 1:length(regions)){
  river_NCI <- readRDS(paste0(data_path, '/',regions[i],'_NCI_sel_dist.rds'))
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

rm(basin_atlas_feats)
rm(basin_atlas_feats_qq)

basin_qq <- unique(basin_qq)
basin <- unique(basin)

to_plot <- melt(basin_qq[,c(-1:-2, -4, -5, -6, -7)], id.vars = c('NCI','fractal', 'gc', 'level'))
to_plot <- to_plot[complete.cases(to_plot)]

ggplot(to_plot, aes(x = NCI, col = value)) +
  geom_density() +
  facet_wrap(~variable) + 
  xlim(-1.0, 0.5) +
  scale_color_manual(values = palette_RdBu(10)) +
  theme_light()

ggsave("results/experiments/exp05/overview_NCI_distance.png")

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
  xlim(-1.0, 1.0) +
  scale_color_manual(values = palette_RdBu(10)) +
  theme_light()
ggsave("results/experiments/exp05/overview_precp_levelNCI_distance.png")

basin[level > 3 & level < 12, area_quant := ordered(quantcut(area, 10), labels = seq(0.1, 1, 0.1)), by = 'level']


ggplot(basin[level > 3 & level < 12], aes(x = NCI, col = area_quant))+
  geom_density()+
  xlim(-1.0, 1.0) +
  scale_color_manual(values = palette_RdBu(length(unique(basin$level)))) +
  facet_wrap(~level, scales = 'free')+
  theme_light()

ggplot(basin[level > 3 & level < 12], aes(x = NCI, col = area_quant, fill = area_quant))+
  geom_histogram()+
  xlim(-1.0, 1.0) +
  scale_color_manual(values = palette_RdBu(length(unique(basin$level)))) +
  scale_fill_manual(values = palette_RdBu(length(unique(basin$level)))) +
  facet_wrap(~level, scales = 'free')+
  theme_light()
  
ggplot(basin, aes(x = NCI))+
  geom_histogram()+
  xlim(-1.0, 1.0) +
  scale_color_manual(values = palette_RdBu(length(unique(basin$level)))) +
  facet_wrap(~level, scales = 'free')+
  theme_light()

ggplot(basin, aes(x = NCI))+
  geom_histogram()+
  xlim(-1.0, 1.0) +
  scale_color_manual(values = palette_RdBu(length(unique(basin$level)))) +
  facet_wrap(~pfaf_level, scales = 'free')+
  theme_light()

library(RPostgres)
con <- dbConnect(Postgres(), dbname = db_name, host = host_ip, port = port_n,        
                 user = rstudioapi::askForPassword("Database user"),      
                 password = rstudioapi::askForPassword("Database password"))


basin_sel <- subset(basin, select = c(NCI, pfaf_id))
basin_sel <- basin_sel[complete.cases(basin_sel)]

#query_sel_boundaries <- paste0("SELECT pfaf_id, geom FROM basin_boundaries.basins_all_regions_4_11 WHERE pfaf_id IN (", as.character(c(basin_sel$pfaf_id)), ")")

boundaries <- st_read(con, query = query_sel_boundaries)



# merge geom to basin_sel
# plot