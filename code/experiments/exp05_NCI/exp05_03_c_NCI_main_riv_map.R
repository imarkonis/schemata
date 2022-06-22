
source('code/source/libs.R')
source('code/source/experiments/exp_05.R')
source('code/source/graphics.R')

library(gtools)

options(scipen = 20)

regions <- c("af", "as", "na", "au", "eu", "sa_n", "sa_s", "si")
for(i in 1:length(regions)){
  if(i == 1){
    river_NCI <- readRDS(paste0(data_path, '/',regions[i],'_NCI_main_rivers_distance.rds'))
  }else{
    river_tmp<- readRDS(paste0(data_path, '/',regions[i],'_NCI_main_rivers_distance.rds'))
    river_NCI <- rbind(river_NCI, river_tmp)
  }
}

river_NCI_sel <- river_NCI[, .(NCI = unique(NCI)), pfaf_id]

pfaf_paste <- paste(as.character(river_NCI_sel$pfaf_id), collapse = "', '")
query_sel_boundaries <- paste0("SELECT pfaf_id, geom FROM basin_boundaries.basins_all_regions_4_11 WHERE pfaf_id IN ( '", pfaf_paste, "')")
boundaries <- st_read(con, query = query_sel_boundaries)

data_to_plot <- merge(boundaries, river_NCI_sel, by = "pfaf_id", all.x = TRUE)
saveRDS(data_to_plot, paste0(results_path, '/global_map_NCI_main_rivers.rds'))

data_to_plot_dt <- data.table(data_to_plot)

data_to_plot_dt[, level := nchar(pfaf_id)]
data_to_plot_dt[, NCI_cut := cut(NCI, breaks = c(-100, seq(-1,1,0.2), 100))]

ggplot(data_to_plot_dt)+
  geom_sf(aes(geometry = geometry, fill = NCI_cut), col = NA)+
  #scale_color_manual(values = palette_RdBu(10)) +
  scale_fill_manual(values = palette_RdBu(12)) +
  theme_bw()

ggplot(data_to_plot_dt)+
  geom_sf(aes(geometry = geometry))+
  theme_bw()

ggsave("results/experiments/exp05/mapNCI_main_river.png")
