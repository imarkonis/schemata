source('code/source/libs.R')
source('code/source/functions.R')
source('code/source/geo_utils.R')
source('code/source/database.R')
source('code/source/geo_functions.R')
source('code/source/experiments/exp_05.R')

library(data.table)

eu_river_xyz <- readRDS(paste0(data_path, '/eu_rivers_xyz.rds'))

# zmin is where min z of next_down == 0
eu_river_xyz[, zmin := min(z[which.min(next_down)]), .(main_riv)]
# zmax is where z where max(dist_up_km)
eu_river_xyz[, zmax := max(z[which.max(dist_dn_km)]), .(main_riv)]
# l is max(dist_up_km)
eu_river_xyz[, l_max := max(dist_up_km), .(main_riv)]
eu_river_xyz[, m := m_straight(zmin, zmax, l_max)]
eu_river_xyz[, z_s := z_straight(dist_dn_km, m, zmin)]
eu_river_xyz[, NCI := NCI(z_s, z, zmin, zmax)]


test <- eu_river_xyz[main_riv == "20165518"]

ggplot(test)+
  geom_path(aes(x = dist_dn_km, y = z), col = "royalblue2")+
  geom_path(aes(x = dist_dn_km, y = z_s), col = "darkorange")+
  theme_bw()
