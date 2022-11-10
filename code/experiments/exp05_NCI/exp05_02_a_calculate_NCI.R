source('code/source/libs.R')
source('code/source/geo_utils.R')
source('code/source/geo_functions.R')
source('code/source/experiments/exp_05.R')

options(scipen = 15)
regions <- c("af", "as", "na", "au", "eu", "sa_n", "sa_s", "si")

# add basin, sub-basin, interbasin, closed, region, 
for(i in 1:length(regions)){
  river_xyz <- readRDS(paste0(data_path,'/z_',regions[i], '_xy.rds'))
  river_xyz <- as.data.table(river_xyz)
  river_xyz <- river_xyz[!is.na(z)]
  river_xyz[, zend := min(z[which.min(dist_dn_km)]), .(pfaf_id_level)]
  river_xyz[, zbeg := max(z[which.max(dist_dn_km)]), .(pfaf_id_level)]
  river_xyz[, l_max := max(dist_up_km_detailed)-min(dist_up_km_detailed), .(pfaf_id_level)]
  river_xyz[, l := dist_up_km_detailed-min(dist_up_km_detailed), .(pfaf_id_level)]
  river_xyz[, m := m_straight(zend, zbeg, l_max), .(pfaf_id_level)]
  river_xyz[, z_s := z_straight(l, m, zbeg), .(pfaf_id_level)]
  river_xyz[, v_dev := vert_deviation(z_s, z, zend, zbeg), .(pfaf_id_level)]
  river_xyz[, NCI := median(v_dev), .(pfaf_id_level)]
  river_xyz[,most_sub_basin_level := nchar(sub("0+$", "", pfaf_id))]
  saveRDS(river_xyz, paste0(data_path, '/',regions[i],'_NCI.rds'))
  river_xyz_main <- river_xyz[main_test == TRUE]  
  saveRDS(river_xyz, paste0(data_path, '/',regions[i],'_NCI_main.rds'))
  river_NCI_hybas <- subset(river_xyz, select = c("hybas_id", "pfaf_id_level", "pfaf_id", "main_test", "NCI"))
  river_NCI_hybas <- river_NCI_hybas[!is.na(NCI)]                        
  river_NCI_hybas <- unique(river_NCI_hybas)                        
  saveRDS(river_NCI_hybas, paste0(data_path, '/',regions[i],'_NCI_hybas.rds'))
  print(regions[i])
}
