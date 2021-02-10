#Post processing basin SOM

library(kohonen)
source('code/source/libs.R')
source('code/source/graphics.R')
source('code/source/experiments/exp_01.R')

path_data <- paste0("./data/experiments/", experiment, "/classify/")
path_results <- paste0("./results/experiments/", experiment, "/")
basin_feats <- readRDS(paste0("./data/experiments/", experiment, "/basin_feats.rds"))
som_fname <- 'som_pilot_3_10000.Rdata'
path_fname <- paste0(path_data, som_fname)

load(path_fname)

groups <- 9
som_hc <- cutree(hclust(dist(basin_som$codes[[1]])), groups)
plot(basin_som, type = "mapping", main = "Cluster Map", bgcol = palette_mid_qual(groups)[som_hc])
add.cluster.boundaries(basin_som, som_hc)

cls = som_hc[basin_som$unit.classif]

basin_feats$cluster <- factor(som_hc[basin_som$unit.classif])
basin_feats[, n_clusters := .N, by = cluster]

basins_sf <- st_read(paste0("./data/experiments/", experiment, "/basins_pilot.shp"))
basins_sf <- merge(basins_sf, basin_feats, by = "HYBAS_ID")

saveRDS(basins_sf, paste0(path_results, 'basin_soms_9_classes.rds'))

ggplot(basins_sf) +
  geom_sf(aes(fill = cluster)) +
  scale_fill_manual(values = palette_mid_qual(groups)) +
  labs(x = "", y = "") +
  theme_light()
ggsave(paste0(path_results, 'first_classification.png'))

#Validation plots

boxplot(gc~cluster, basin_feats)



