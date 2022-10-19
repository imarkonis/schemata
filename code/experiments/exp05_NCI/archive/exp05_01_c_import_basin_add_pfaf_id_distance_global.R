
source('code/source/libs.R')
source('code/source/functions.R')
source('code/source/geo_utils.R')
source('code/source/database.R')
source('code/source/geo_functions.R')
source('code/source/experiments/exp_05.R')

regions <- c("af", "as", "na", "au", "eu", "si", "sa_n", "sa_s")

for(i in 1:length(regions)){
  river_xyz <- readRDS(paste0(data_path,'/z_',regions[i], '_rivers_xy_dist.rds'))
  name_merge <- paste0(data_path,'/',regions[i], '_rivers_xyz_pfaf_distance.rds')
  
  if( i %in% c(7,8)){
    regions[i] = "sa"
  }
  bas_borders <- st_read(con, query = paste0("SELECT hybas_id, pfaf_id, coast FROM basin_boundaries.",regions[i],"_12"))
  merged <- merge(bas_borders , river_xyz, by.x = 'hybas_id', by.y = "hybas_l12")
  saveRDS(merged, name_merge)
}
