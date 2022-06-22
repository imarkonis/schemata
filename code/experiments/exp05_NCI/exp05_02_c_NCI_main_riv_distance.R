source('code/source/libs.R')
source('code/source/functions.R')
source('code/source/geo_utils.R')
source('code/source/database.R')
source('code/source/geo_functions.R')
source('code/source/experiments/exp_05.R')

options(scipen = 20)
regions <- c("af", "as", "na", "au", "eu", "sa_n", "sa_s", "si")

for(i in 1:length(regions)){
  river_NCI <- readRDS(paste0(data_path, '/',regions[i],'_NCI_dist.rds'))
  river_NCI_sel <- subset(river_NCI, select = c(pfaf_id_level_12, 
                                                pfaf_id_level_11, 
                                                pfaf_id_level_10,
                                                pfaf_id_level_9,
                                                pfaf_id_level_8,
                                                pfaf_id_level_7,
                                                pfaf_id_level_6,
                                                pfaf_id_level_5,
                                                pfaf_id_level_4,
                                                pfaf_id_level_3, 
                                                next_down,
                                                main_riv_pfaf_id, 
                                                main_riv_level,
                                                length_km, 
                                                dist_dn_km,
                                                dist_up_km,
                                                dist_dn_km_detailed,
                                                dist_up_km_detailed,
                                                ord_clas,
                                                z,
                                                X,
                                                Y)
  )
  rm(river_NCI)
  gc()
  river_NCI_long <- melt(data = river_NCI_sel, measure.vars = c("pfaf_id_level_12", 
                                                                "pfaf_id_level_11", 
                                                                "pfaf_id_level_12",
                                                                "pfaf_id_level_10",
                                                                "pfaf_id_level_9",
                                                                "pfaf_id_level_8",
                                                                "pfaf_id_level_7",
                                                                "pfaf_id_level_6",
                                                                "pfaf_id_level_5",
                                                                "pfaf_id_level_4",
                                                                "pfaf_id_level_3"), variable.name = "level", value.name = "pfaf_id")
  rm(river_NCI_sel)
  gc()
  river_NCI_filter <- river_NCI_long[main_riv_pfaf_id == pfaf_id]
  rm(river_NCI_long)
  gc()
  river_NCI_filter[, lowest_ord_clas := min(ord_clas), .(pfaf_id)]
  river_NCI_filter[, level_num := substr(level, start = 15, stop = 17), ]
  river_NCI_filter[, level_num := as.numeric(level_num), ]
  river_NCI_filter <- river_NCI_filter[ord_clas == lowest_ord_clas ]
  gc()
  river_NCI_filter[, zend := min(z[which.min(dist_dn_km)]), .(pfaf_id)]
  # zbeg is where z where max(dist_up_km)
  river_NCI_filter[, zbeg := max(z[which.max(dist_dn_km)]), .(pfaf_id)]
  # l is max(dist_up_km)
  river_NCI_filter[, l_max := max(dist_up_km_detailed)-min(dist_up_km_detailed), .(pfaf_id)]
  river_NCI_filter[, l := dist_up_km_detailed-min(dist_up_km_detailed), .(pfaf_id)]
  river_NCI_filter[, m := m_straight(zend, zbeg, l_max)]
  river_NCI_filter[, z_s := z_straight(l, m, zbeg)]
  river_NCI_filter[, v_dev := vert_deviation(z_s, z, zend, zbeg)]
  river_NCI_filter[, NCI := median(v_dev), .(pfaf_id)]
  saveRDS(river_NCI_filter, paste0(data_path, '/',regions[i],'_NCI_main_rivers_distance.rds'))
}

library(ggplot2)
source('code/source/graphics.R')

ggplot(river_NCI_filter, aes(x = NCI))+
  geom_density() +
  facet_wrap(~level_num) + 
  xlim(-1.0, 0.5) +
  theme_light()

ggplot(river_NCI_filter, aes(x = NCI, col = as.factor(level_num)))+
  geom_density() +
  xlim(-1.0, 0.5) +
  scale_color_manual(values = palette_RdBu(length(unique(river_NCI_filter$level_num)))) +
  theme_light()

river_NCI_filter[,length(unique(pfaf_id)), level_num]
