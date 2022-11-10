
source('code/source/libs.R')
source('code/source/database.R')
source('code/source/experiments/exp_05.R')
source('code/source/graphics.R')

library(gtools)

options(scipen = 20)

regions <- c("af", "as", "na", "au", "eu", "sa_n", "sa_s", "si")
for(i in 1:length(regions)){
  print(regions[i])
  if(i == 1){
    river_NCI <- readRDS(paste0(data_path,"/",regions[i],'_NCI_hybas.rds'))
    pfaf_paste <- paste(as.character(river_NCI$pfaf_id_level), collapse = "', '")
    query_sel_boundaries <- paste0("SELECT pfaf_id, geom FROM basin_boundaries.",regions[i],"_all WHERE pfaf_id IN ( '", pfaf_paste, "')")
    boundaries <- st_read(con, query = query_sel_boundaries)
    
  }else{
    river_tmp <- readRDS(paste0(data_path,"/",regions[i],'_NCI_hybas.rds'))
    river_NCI <- rbind(river_NCI, river_tmp)
    pfaf_paste <- paste(as.character(river_tmp$pfaf_id_level), collapse = "', '")
    if(i %in% c(6,7)){
      regions[i] <- "sa"
    }
    query_sel_boundaries <- paste0("SELECT pfaf_id, geom FROM basin_boundaries.",regions[i],"_all WHERE pfaf_id IN ( '", pfaf_paste, "')")
    boundaries_tmp <- st_read(con, query = query_sel_boundaries)
    boundaries <- rbind(boundaries, boundaries_tmp)
  }
}

river_NCI_main <- river_NCI[main_test == TRUE]
# 
# pfaf_paste <- paste(as.character(river_NCI_main$pfaf_id_level), collapse = "', '")
# query_sel_boundaries <- paste0("SELECT pfaf_id, geom FROM basin_boundaries.basins_all_regions_4_11 WHERE pfaf_id IN ( '", pfaf_paste, "')")
# query_sel_boundaries <- paste0("SELECT pfaf_id, geom FROM basin_boundaries.sa_all WHERE pfaf_id IN ( '", pfaf_paste, "')")
# 
# boundaries <- st_read(con, query = query_sel_boundaries)

data_to_plot <- merge(boundaries, river_NCI, by.x = "pfaf_id", by.y = "pfaf_id_level",all.x = TRUE)
saveRDS(data_to_plot, paste0(results_path, '/global_map_NCI.rds'))

data_to_plot <- readRDS(paste0(results_path, '/global_map_NCI.rds'))

data_to_plot_dt <- data.table(data_to_plot)

data_to_plot_dt[, level := nchar(pfaf_id)]
data_to_plot_dt[, NCI_cut := cut(NCI, breaks = c(-100, seq(-1,1,0.2), 100))]

data_to_plot_dt[, NCI_cut_2 := cut(NCI, breaks = c(-100, seq(-0.3,0.3,0.1), 100))]

ggplot(data_to_plot_dt)+
  geom_sf(aes(geometry = geometry, fill = NCI_cut), col = NA)+
  #scale_color_manual(values = palette_RdBu(10)) +
  scale_fill_manual(values = palette_RdBu(12)) +
  theme_bw()
ggsave("results/experiments/exp05/mapNCI.png")

ggplot(data_to_plot_dt)+
  geom_sf(aes(geometry = geometry, fill = NCI_cut_2), col = NA)+
  #scale_color_manual(values = palette_RdBu(10)) +
  scale_fill_manual(values = palette_RdBu(8)) +
  theme_bw()
ggsave("results/experiments/exp05/mapNCI_2.png")

ggplot(data_to_plot_dt)+
  geom_sf(aes(geometry = geometry))+
  theme_bw()

ggsave("results/experiments/exp05/mapNCI_main_river.png")
