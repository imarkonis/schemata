
source('code/source/libs.R')
source('code/source/functions.R')
source('code/source/geo_utils.R')
source('code/source/database.R')
source('code/source/geo_functions.R')
source('code/source/experiments/exp_05.R')

library(ggplot2)

regions <- c("af", "as", "na", "au", "eu", "sa_n", "sa_s")

basin_atlas_feats <- readRDS("data/experiments/exp03/basin_atlas_feats.rds")
basin_atlas_feats_qq <- readRDS("data/experiments/exp03/basin_atlas_feats_qq.rds")

for(i in 1:length(regions)){
  river_NCI <- readRDS(paste0(data_path, '/',regions[i],'_NCI_sel.rds'))
  if(i == 1){
    basin_atlas_feats <- merge(basin_atlas_feats, river_NCI, by = "pfaf_id", all.x = TRUE)
    basin_atlas_feats_qq <- merge(basin_atlas_feats_qq, river_NCI, by = "pfaf_id", all.x = TRUE)
  }else{
    basin_atlas_feats <- merge(basin_atlas_feats, river_NCI, by = names(river_NCI), all.x = TRUE)
    basin_atlas_feats_qq <- merge(basin_atlas_feats_qq, river_NCI, by = names(river_NCI), all.x = TRUE)
  }
}

ggplot(basin_atlas_feats[is.na(type)])+
  geom_histogram(aes(x = level))+
  theme_bw()
  
na_type <- basin_atlas_feats[is.na(type)]

basin_sel <- basin_atlas_feats[!is.na(NCI)]

ggplot(na_type)+
  geom_histogram(aes(x = level))+
  theme_bw()