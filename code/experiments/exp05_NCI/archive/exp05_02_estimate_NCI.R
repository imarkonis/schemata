source('code/source/libs.R')
source('code/source/functions.R')
source('code/source/geo_utils.R')
source('code/source/database.R')
source('code/source/geo_functions.R')
source('code/source/experiments/exp_05.R')

library(data.table)

regions <- c("af_rivers", "as_rivers", "na_rivers", "au_rivers", "eu_rivers", "si_rivers", "sa_n_rivers", "sa_s_rivers")

for(i in 1:length(regions)){
  river_xyz <- readRDS(paste0(data_path,'/z_',regions[i], '_xy_all_3.rds'))
  river_df <- st_drop_geometry(river_xyz)
  river_dt <- as.data.table(river_df)
  rm(river_xyz)
  rm(river_df)
  gc()
  # think about this?
  river_dt[, z_av := mean(z, na.rm = T), .(hyriv_id)]
  river_xyz_av <- river_dt[!(duplicated(hyriv_id)),]
  river_xyz_av[, segments_count := nrow(.SD), main_riv]
  river_xyz_av <- river_xyz_av[segments_count > 1]
  # zmin is where min z of next_down == 0
  river_xyz_av[, zmin := min(z_av[which.min(next_down)]), .(main_riv)]
  # zmax is where z where max(dist_up_km)
  river_xyz_av[, zmax := max(z_av[which.max(dist_dn_km)]), .(main_riv)]
  # l is max(dist_up_km)
  river_xyz_av[, l_max := max(dist_up_km)-min(dist_up_km), .(main_riv)]
  river_xyz_av[, l := dist_up_km-min(dist_up_km), .(main_riv)]
  river_xyz_av[, m := m_straight(zmin, zmax, l_max)]
  river_xyz_av[, z_s := z_straight(l, m, zmax)]
  river_xyz_av[, v_dev := vert_deviation(z_s, z_av, zmin, zmax)]
  river_xyz_av[, NCI := median(v_dev), .(main_riv)]
  saveRDS(river_xyz_av, paste0(results_path, '/',regions[i],'_xyz_NCI_all.rds'))
}
