source('code/source/libs.R')
source('code/source/functions.R')
source('code/source/geo_utils.R')
source('code/source/database.R')
source('code/source/geo_functions.R')
source('code/source/experiments/exp_05.R')

options(scipen = 15)
regions <- c("af", "as", "na", "au", "eu", "sa_n", "sa_s", "si")

# add basin, sub-basin, interbasin, closed, region, 
for(i in 1:length(regions)){
  river_xyz <- readRDS(paste0(data_path,'/',regions[i], '_rivers_xyz_pfaf_distance.rds'))
  river_xyz <- as.data.table(river_xyz)
  pfaf_level <- 12
  river_xyz[, segments_count := length(unique(hyriv_id)), .(main_riv)]
  river_xyz <- river_xyz[segments_count > 1]
  river_xyz <- river_xyz[coast != 1]
  river_xyz[, coast := NULL]
  river_xyz[, OK := FALSE]
  river_xyz[, zerotest := FALSE]
  river_xyz[as.integer(substr(pfaf_id, pfaf_level, pfaf_level)) == 0, zerotest := TRUE]
  river_xyz[((pfaf_id%%2) == 0) &  (!zerotest) , OK:= TRUE ]
  river_xyz[(pfaf_id%%2) == 0, basin:= "sub-basin"]
  river_xyz[(pfaf_id%%2) == 1, basin:= "inter-basin"]
  river_xyz[zerotest == TRUE, basin:= "closed"]
  river_xyz[, lowest_ord_clas := min(ord_clas), .(pfaf_id)]
  river_xyz[ord_clas == lowest_ord_clas, pt_count := nrow(.SD), .(pfaf_id)]
  river_xyz[ord_clas == lowest_ord_clas & pt_count < 30, OK := FALSE, .(pfaf_id)]
  river_xyz[(ord_clas == lowest_ord_clas) & OK, zend := min(z[which.min(dist_dn_km)]), .(pfaf_id)]
  river_xyz[(ord_clas == lowest_ord_clas) & OK, zbeg := max(z[which.max(dist_dn_km)]), .(pfaf_id)]

  river_xyz[(ord_clas == lowest_ord_clas) & OK, l_max := max(dist_up_km_detailed)-min(dist_up_km_detailed), .(pfaf_id)]
  river_xyz[(ord_clas == lowest_ord_clas) & OK, l := dist_up_km_detailed-min(dist_up_km_detailed), .(pfaf_id)]
  river_xyz[(ord_clas == lowest_ord_clas) & OK, m := m_straight(zend, zbeg, l_max)]
  river_xyz[(ord_clas == lowest_ord_clas) & OK, z_s := z_straight(l, m, zbeg)]
  river_xyz[(ord_clas == lowest_ord_clas) & OK, v_dev := vert_deviation(z_s, z, zend, zbeg)]
  river_xyz[(ord_clas == lowest_ord_clas) & OK, NCI := median(v_dev), .(pfaf_id)]
  river_xyz[,pfaf_id_level_12:= pfaf_id]
  old_names <- c("lowest_ord_clas", "zbeg", "zend", "l_max", "l", "m", "z_s", "v_dev", "NCI","OK", "zerotest", "basin")
  new_names <- paste0(old_names, "_", pfaf_level)
  setnames(river_xyz, old_names, new_names)
  river_xyz[,main_riv_level := 12]
  river_xyz[,main_riv_pfaf_id := pfaf_level]
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
    river_xyz[ord_clas == lowest_ord_clas, pt_count := nrow(.SD), .(pfaf_id_level)]
    river_xyz[ord_clas == lowest_ord_clas & pt_count < 30, OK := FALSE, .(pfaf_id_level)]
    river_xyz[(ord_clas == lowest_ord_clas) & OK, zbeg := max(z[which.max(dist_dn_km)]), .(pfaf_id_level)]
    river_xyz[(ord_clas == lowest_ord_clas) & OK, zend := min(z[which.min(dist_dn_km)]), .(pfaf_id_level)]
    # l is max(dist_up_km)
    river_xyz[(ord_clas == lowest_ord_clas) & OK, l_max := max(dist_up_km_detailed)-min(dist_up_km_detailed), .(pfaf_id_level)]
    river_xyz[(ord_clas == lowest_ord_clas) & OK, l := dist_up_km_detailed-min(dist_up_km_detailed), .(pfaf_id_level)]
    river_xyz[(ord_clas == lowest_ord_clas) & OK, m := m_straight(zend, zbeg, l_max)]
    river_xyz[(ord_clas == lowest_ord_clas) & OK, z_s := z_straight(l, m, zbeg)]
    river_xyz[(ord_clas == lowest_ord_clas) & OK, v_dev := vert_deviation(z_s, z, zend, zbeg)]
    river_xyz[(ord_clas == lowest_ord_clas) & OK, NCI := median(v_dev), .(pfaf_id_level)]
    river_xyz[lowest_ord_clas == 1, main_num := length(unique(pfaf_id_level)),  .(main_riv)]
    #river_xyz[,main_num := length(unique(main_riv)),  .(pfaf_id_level)]
    river_xyz[main_num == 1 ,main_test := TRUE,  .(pfaf_id_level)]
    river_xyz[main_test == TRUE, main_riv_level := pfaf_level]
    river_xyz[main_test == TRUE, main_riv_pfaf_id := pfaf_id_level]
    old_names <- c("pfaf_id_level","lowest_ord_clas", "zbeg", "zend", "l_max", "l", "m", "z_s", "v_dev", "NCI", "OK", "zerotest", "last_pi_digit", "main_num", "main_test", "basin")
    new_names <- paste0(old_names, "_", pfaf_level)
    setnames(river_xyz, old_names, new_names)
  }
  river_xyz[,most_sub_basin_level := nchar(sub("0+$", "", pfaf_id))]
  river_xyz[,diff_levels := most_sub_basin_level -main_riv_level]
  saveRDS(river_xyz, paste0(data_path, '/',regions[i],'_NCI_dist.rds'))
  print(regions[i])
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

ggplot(river_xyz[main_riv == 50765407 & pfaf_id < 565580001635 ])+
  geom_point(aes(x = X, y = Y, pch = as.factor(ord_clas), col = as.factor(pfaf_id)))

ggplot(river_xyz[pfaf_id == 565580001632])+
  geom_point(aes(x = X, y = Y, col = as.factor(ord_clas), pch = as.factor(pfaf_id)))

ggplot(river_xyz[pfaf_id == 531593360432 & ord_clas == 2])+
  geom_point(aes(x = X, y = Y, col = as.factor(ord_clas), pch = as.factor(pfaf_id)))

ggplot(river_xyz[pfaf_id == 531593360432 & ord_clas == 2])+
  geom_point(aes(x = l, y = z, col = "z"))+
  geom_point(aes(x = l, y = z_s, col = "z_s"))+
  geom_point(aes(x = l, y = zbeg, col = "z_beg"))+
  geom_point(aes(x = l, y = zend, col = "z_end"))
  


