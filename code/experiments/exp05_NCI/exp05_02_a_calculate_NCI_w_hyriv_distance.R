source('code/source/libs.R')
source('code/source/functions.R')
source('code/source/geo_utils.R')
source('code/source/database.R')
source('code/source/geo_functions.R')
source('code/source/experiments/exp_05.R')

library(data.table)
options(scipen = 15)
regions <- c("af", "as", "na", "au", "eu", "sa_n", "sa_s")

# add basin, sub-basin, interbasin, closed, region, 
for(i in 1:length(regions)){
  river_xyz <- readRDS(paste0(data_path,'/',regions[i], '_rivers_xyz_pfaf.rds'))
  river_xyz$geom = NULL
  river_xyz <- as.data.table(river_xyz)
  # think about this?
  pfaf_level <- 12
  #river_xyz[, segments_count := nrow(.SD), .(pfaf_id)]
  #river_xyz <- river_xyz[segments_count > 1]
  #river_xyz[, count_main_hybas12:= length(unique(main_riv)), .(hybas_id)]
  #river_xyz <- river_xyz[count_main_hybas12 == 1]
  river_xyz[, segments_count := nrow(.SD), .(main_riv)]
  river_xyz <- river_xyz[segments_count > 1]
  river_xyz <- river_xyz[coast != 1]
  river_xyz[,coast := NULL]
  # zmin is where min z of next_down == 0
  river_xyz[, OK := FALSE]
  river_xyz[, zerotest := FALSE]
  river_xyz[as.integer(substr(pfaf_id, pfaf_level, pfaf_level)) == 0, zerotest := TRUE]
  river_xyz[((pfaf_id%%2) == 0) &  (!zerotest) , OK:= TRUE ]
  river_xyz[(pfaf_id%%2) == 0, basin:= "sub-basin"]
  river_xyz[(pfaf_id%%2) == 1, basin:= "inter-basin"]
  river_xyz[zerotest == TRUE, basin:= "closed"]
  river_xyz[, lowest_ord_clas := min(ord_clas), .(pfaf_id)]
  river_xyz[(ord_clas == lowest_ord_clas) & OK, zmin := min(z[which.min(next_down)]), .(pfaf_id)]
  # zmax is where z where max(dist_up_km)
  river_xyz[(ord_clas == lowest_ord_clas) & OK, zmax := max(z[which.max(dist_dn_km)]), .(pfaf_id)]
  # l is max(dist_up_km)
  river_xyz[(ord_clas == lowest_ord_clas) & OK, l_max := max(dist_dn_km_detailed)-min(dist_dn_km_detailed), .(pfaf_id)]
  river_xyz[(ord_clas == lowest_ord_clas) & OK, l := dist_dn_km_detailed-min(dist_dn_km_detailed), .(pfaf_id)]
  river_xyz[(ord_clas == lowest_ord_clas) & OK, m := m_straight(zmin, zmax, l_max)]
  river_xyz[(ord_clas == lowest_ord_clas) & OK, z_s := z_straight(l, m, zmax)]
  river_xyz[(ord_clas == lowest_ord_clas) & OK, v_dev := vert_deviation(z_s, z, zmin, zmax)]
  river_xyz[(ord_clas == lowest_ord_clas) & OK, NCI := median(v_dev), .(pfaf_id)]
  river_xyz[,pfaf_id_level_12:= pfaf_id]
  old_names <- c("lowest_ord_clas", "zmin", "zmax", "l_max", "l", "m", "z_s", "v_dev", "NCI","OK", "zerotest", "basin")
  new_names <- paste0(old_names, "_", pfaf_level)
  setnames(river_xyz, old_names, new_names)
  river_xyz[,main_riv_level := 0]
  river_xyz[,main_riv_pfaf_id := 0]
  river_xyz[,most_sub_basin_level := nchar(sub("0+$", "", pfaf_id))]
  river_xyz[,diff_levels := most_sub_basin_level -main_riv_level]
  for(pfaf_level in 11:3){
    river_xyz[,pfaf_id_level:=  as.numeric(substr(pfaf_id, 1, pfaf_level))]
    river_xyz[, OK := FALSE]
    river_xyz[, zerotest := FALSE]
    river_xyz[,  last_pi_digit := substr(pfaf_id, pfaf_level, pfaf_level)]
    river_xyz[ last_pi_digit == "0", zerotest := TRUE]
    river_xyz[((pfaf_id_level%%2) == 0) &  (!zerotest) , OK:= TRUE ]
    river_xyz[(pfaf_id%%2) == 0, basin:= "sub-basin"]
    river_xyz[(pfaf_id%%2) == 1, basin:= "inter-basin"]
    river_xyz[zerotest == TRUE, basin:= "closed"]
    if(pfaf_level == 3){
      river_xyz[, OK:= TRUE]
    }
    
    river_xyz[, lowest_ord_clas := min(ord_clas), .(pfaf_id_level)]
    river_xyz[(ord_clas == lowest_ord_clas) & OK, zmin := min(z[which.min(next_down)]), .(pfaf_id_level)]
    # zmax is where z where max(dist_up_km)
    river_xyz[(ord_clas == lowest_ord_clas) & OK, zmax := max(z[which.max(dist_dn_km)]), .(pfaf_id_level)]
    # l is max(dist_up_km)
    river_xyz[(ord_clas == lowest_ord_clas) & OK, l_max := max(dist_dn_km_detailed)-min(dist_dn_km_detailed), .(pfaf_id_level)]
    river_xyz[(ord_clas == lowest_ord_clas) & OK, l := dist_dn_km_detailed-min(dist_dn_km_detailed), .(pfaf_id_level)]
    river_xyz[(ord_clas == lowest_ord_clas) & OK, m := m_straight(zmin, zmax, l_max)]
    river_xyz[(ord_clas == lowest_ord_clas) & OK, z_s := z_straight(l, m, zmax)]
    river_xyz[(ord_clas == lowest_ord_clas) & OK, v_dev := vert_deviation(z_s, z, zmin, zmax)]
    river_xyz[(ord_clas == lowest_ord_clas) & OK, NCI := median(v_dev), .(pfaf_id_level)]
    river_xyz[,main_num := length(unique(main_riv)),  .(pfaf_id_level)]
    river_xyz[main_num == 1 ,main_test := TRUE,  .(pfaf_id_level)]
    river_xyz[main_test == TRUE, main_riv_level := pfaf_level]
    river_xyz[main_test == TRUE, main_riv_pfaf_id := pfaf_id_level]
    #river_xyz[lowest_ord_clas == 1 & OK & main_riv_level == 0, main_riv_level := pfaf_level, ]
    #river_xyz[lowest_ord_clas == 1 & OK & main_riv_pfaf_id == 0, main_riv_pfaf_id := pfaf_id_level, ]
    old_names <- c("pfaf_id_level","lowest_ord_clas", "zmin", "zmax", "l_max", "l", "m", "z_s", "v_dev", "NCI", "OK", "zerotest", "last_pi_digit", "main_num", "main_test", "basin")
    new_names <- paste0(old_names, "_", pfaf_level)
    setnames(river_xyz, old_names, new_names)
  }
  river_xyz[,most_sub_basin_level := nchar(sub("0+$", "", pfaf_id))]
  river_xyz[,diff_levels := most_sub_basin_level -main_riv_level]
  saveRDS(river_xyz, paste0(results_path, '/',regions[i],'_NCI_pfaf_ids.rds'))
  print(regions[i])
  print(river_xyz[diff_levels < 0,length(unique(main_riv))])
  saveRDS(river_xyz[diff_levels < 0], paste0(data_path, '/',regions[i],'_NCI_pfaf_ids_wrong_pfaf_id_l12.rds'))
}


library(ggplot2)
river_sel <- river_xyz[,.(main_riv_level= min(main_riv_level), sub_riv_level = max(most_sub_basin_level)), main_riv]

river_sel[, diff:= sub_riv_level - main_riv_level]
#river_sel$main_riv_level<- factor(river_sel$main_riv_level, levels = 3:11)
#river_sel$sub_riv_level<- factor(river_sel$sub_riv_level, levels = 3:11)

cols <- c("main" = "darkblue", "sub" = "lightblue")

ggplot(data = river_sel)+
  geom_histogram(aes(x = main_riv_level, fill = "main"), stat = "count")+
  geom_histogram(aes(x = sub_riv_level, fill = "sub"), stat = "count")+
  scale_fill_manual(values = cols)+
  labs(x = "pfafstetter level")+
  theme_bw() 

ggplot(data = river_sel[diff != 0 ])+
  geom_histogram(aes(x = main_riv_level, fill = "main"), stat = "count")+
  geom_histogram(aes(x = sub_riv_level, fill = "sub", color = "sub"), stat = "count", alpha = 0.5)+
  scale_fill_manual(values = cols)+
  scale_color_manual(values = cols)+
  labs(x = "pfafstetter level")+
  theme_bw()  

river_xyz[ord_clas == 1,norm_dist := dist_dn_km_detailed/max(dist_dn_km_detailed), pfaf_id]
river_xyz[ord_clas == 1,norm_z := z/max(z), pfaf_id]

river_xyz_pi <- unique(river_xyz$pfaf_id)
sel <- sample(river_xyz_pi, 1000)

ggplot(data = river_xyz[ord_clas == 1 & pfaf_id %in% sel])+
  geom_point(aes(x = dist_dn_km_detailed, y = z, col = pfaf_id))+
  #geom_point(aes(x = dist_dn_km_detailed/max(dist_dn_km_detailed), y = z_s))+
  theme_bw()

