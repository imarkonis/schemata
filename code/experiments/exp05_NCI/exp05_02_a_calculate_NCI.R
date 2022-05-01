source('code/source/libs.R')
source('code/source/functions.R')
source('code/source/geo_utils.R')
source('code/source/database.R')
source('code/source/geo_functions.R')
source('code/source/experiments/exp_05.R')

library(data.table)
options(scipen = 20)
regions <- c("af", "as", "na", "au", "eu", "sa_n", "sa_s")

for(i in 1:length(regions)){
  river_xyz <- readRDS(paste0(data_path,'/',regions[i], '_rivers_xyz_pfaf.rds'))
  river_dt<- as.data.table(river_xyz)
  rm(river_xyz)
  gc()
  # think about this?
  pfaf_level <- 12
  river_dt[, z_av := mean(z, na.rm = T), .(hyriv_id)]
  river_xyz_av <- river_dt[!(duplicated(hyriv_id)),]
  river_xyz_av[, segments_count := nrow(.SD), .(main_riv)]
  print(regions[i])
  print(river_xyz_av[,length(unique(pfaf_id))])
  river_xyz_av <- river_xyz_av[segments_count > 1]
  river_xyz_av <- river_xyz_av[coast != 1]
  river_xyz_av[,coast := NULL]
  river_xyz_av[, OK := FALSE]
  river_xyz_av[, zerotest := FALSE]
  river_xyz_av[as.integer(substr(pfaf_id, pfaf_level, pfaf_level)) == 0, zerotest := TRUE]
  river_xyz_av[((pfaf_id%%2) == 0) &  (!zerotest) , OK:= TRUE ]
  river_xyz_av[, lowest_ord_clas := min(ord_clas), .(pfaf_id)]
  # zmin is where min z of next_down == 0

  river_xyz_av[(ord_clas == lowest_ord_clas) & OK, zmin := min(z_av[which.min(next_down)]), .(pfaf_id)]
  # zmax is where z where max(dist_up_km)
  river_xyz_av[(ord_clas == lowest_ord_clas) & OK, zmax := max(z_av[which.max(dist_dn_km)]), .(pfaf_id)]
  # l is max(dist_up_km)
  river_xyz_av[(ord_clas == lowest_ord_clas) & OK, l_max := max(dist_up_km)-min(dist_up_km), .(pfaf_id)]
  river_xyz_av[(ord_clas == lowest_ord_clas) & OK, l := dist_up_km-min(dist_up_km), .(pfaf_id)]
  river_xyz_av[(ord_clas == lowest_ord_clas) & OK, m := m_straight(zmin, zmax, l_max)]
  river_xyz_av[(ord_clas == lowest_ord_clas) & OK, z_s := z_straight(l, m, zmax)]
  river_xyz_av[(ord_clas == lowest_ord_clas) & OK, v_dev := vert_deviation(z_s, z_av, zmin, zmax)]
  river_xyz_av[(ord_clas == lowest_ord_clas) & OK, NCI := median(v_dev), .(pfaf_id)]
  river_xyz_av[,pfaf_id_level_12:= pfaf_id]
  old_names <- c("lowest_ord_clas", "zmin", "zmax", "l_max", "l", "m", "z_s", "v_dev", "NCI","OK", "zerotest")
  new_names <- paste0(old_names, "_", pfaf_level)
  setnames(river_xyz_av, old_names, new_names)
  river_xyz_av[,main_riv_level := 0]
  river_xyz_av[,main_riv_pfaf_id := 0]
  river_xyz_av[,most_sub_basin_level := nchar(sub("0+$", "", pfaf_id))]
  river_xyz_av[,diff_levels := most_sub_basin_level -main_riv_level]
  for(pfaf_level in 11:3){
      print(pfaf_level)
      river_xyz_av[,pfaf_id_level:=  as.numeric(substr(pfaf_id, 1, pfaf_level))]
      river_xyz_av[, OK := FALSE]
      river_xyz_av[, zerotest := FALSE]
      river_xyz_av[,  last_pi_digit := substr(pfaf_id, pfaf_level, pfaf_level)]
      river_xyz_av[ last_pi_digit == "0", zerotest := TRUE]
      river_xyz_av[((pfaf_id_level%%2) == 0) &  (!zerotest) , OK:= TRUE ]
      if(pfaf_level == 3){
        river_xyz_av[, OK:= TRUE]
      }
      river_xyz_av[, lowest_ord_clas := min(ord_clas), .(pfaf_id_level)]
      river_xyz_av[(ord_clas == lowest_ord_clas) & OK, zmin := min(z_av[which.min(next_down)]), .(pfaf_id_level)]
      # zmax is where z where max(dist_up_km)
      river_xyz_av[(ord_clas == lowest_ord_clas) & OK, zmax := max(z_av[which.max(dist_dn_km)]), .(pfaf_id_level)]
      # l is max(dist_up_km)
      river_xyz_av[(ord_clas == lowest_ord_clas) & OK, l_max := max(dist_up_km)-min(dist_up_km), .(pfaf_id_level)]
      river_xyz_av[(ord_clas == lowest_ord_clas) & OK, l := dist_up_km-min(dist_up_km), .(pfaf_id_level)]
      river_xyz_av[(ord_clas == lowest_ord_clas) & OK, m := m_straight(zmin, zmax, l_max)]
      river_xyz_av[(ord_clas == lowest_ord_clas) & OK, z_s := z_straight(l, m, zmax)]
      river_xyz_av[(ord_clas == lowest_ord_clas) & OK, v_dev := vert_deviation(z_s, z_av, zmin, zmax)]
      river_xyz_av[(ord_clas == lowest_ord_clas) & OK, NCI := median(v_dev), .(pfaf_id_level)]
      river_xyz_av[,main_num := length(unique(main_riv)),  .(pfaf_id_level)]
      river_xyz_av[main_num == 1 ,main_test := TRUE,  .(pfaf_id_level)]
      river_xyz_av[main_test == TRUE, main_riv_level := pfaf_level]
      river_xyz_av[main_test == TRUE, main_riv_pfaf_id := pfaf_id_level]
      old_names <- c("pfaf_id_level","lowest_ord_clas", "zmin", "zmax", "l_max", "l", "m", "z_s", "v_dev", "NCI", "OK", "zerotest", "last_pi_digit", "main_num", "main_test")
      new_names <- paste0(old_names, "_", pfaf_level)
      setnames(river_xyz_av, old_names, new_names)
  }
  river_xyz_av[,most_sub_basin_level := nchar(sub("0+$", "", pfaf_id))]
  river_xyz_av[,diff_levels := most_sub_basin_level -main_riv_level]
  saveRDS(river_xyz_av, paste0(data_path, '/',regions[i],'_NCI.rds'))
  saveRDS(river_xyz_av[diff_levels < 0], paste0(data_path, '/',regions[i],'_NCI_pfaf_ids_wrong_pfaf_id_l12.rds'))
}


