
source('code/source/libs.R')
source('code/source/database.R')
source('code/source/experiments/exp_05.R')

regions <- c("af", "as", "na", "au", "eu", "sa_n", "sa_s", "si")

for(i in 1:length(regions)){
  query_riv_allinfo <- paste0("SELECT gid, hybas_l12, hyriv_id, main_riv, next_down, length_km, dist_dn_km, dist_up_km, ord_clas, geom FROM river_atlas.", regions[i],"_rivers")
  rivers <- st_read(con, query = query_riv_allinfo)
  name_merge <- paste0(data_path,'/',regions[i], '_rivers_pfaf.rds')
  if( i %in% c(6,7)){
    regions[i] = "sa"
  }
  bas_borders <- st_read(con, query = paste0("SELECT hybas_id, pfaf_id, coast FROM basin_boundaries.",regions[i],"_12"))
  merged <- merge(bas_borders, rivers, by.x = 'hybas_id', by.y = "hybas_l12")
  merged_no_coast <- merged[which(merged$coast == 0),]
  merged_to_save <- subset(merged_no_coast, select = -coast)
  saveRDS(merged_to_save, name_merge)
}
