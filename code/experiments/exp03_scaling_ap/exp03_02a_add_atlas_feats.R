source('code/source/libs.R')
source('code/source/geo_functions.R')
source('code/source/experiments/exp_03.R')

library(RPostgres)
library(sf)
library(gtools)

basin_levels <- 3:11 # Levels 1 and 2 correspond to continents/country borders/Level 12 is identical to level 11

con <- dbConnect(Postgres(), dbname = db_name, host = host_ip, port = port_n,         
                 user = rstudioapi::askForPassword("Database user"),      
                 password = rstudioapi::askForPassword("Database password"))

basin_ids <- foreach(region_count = 1:length(regions_all), .packages = c('data.table', 'sf', 'RPostgres' ), 
                  .combine = 'rbind') %do% {
                  data.table(st_read(con, query = paste0("SELECT pfaf_id, hybas_id FROM basin_boundaries.", regions_all[region_count], "_all")))
                  }                    

basin_feats <- readRDS(paste0(data_path, 'basin_feats.rds'))
basin_feats <- merge(basin_ids, basin_feats, by = 'pfaf_id')

cols <- c('elevation', 'slope', 'stream_grad', 
          'prcp', 'aridity', 'clay_pc', 'silt_pc', 
          'sand_pc', 'erosion')

basin_atlas <- data.table()
for(basin_level in basin_levels){

basin_atlas_temp <- 
  data.table(st_read(
    con, query = paste0("SELECT hybas_id, 
                        coast,
                        ele_mt_sav,
                        slp_dg_sav,
                        sgr_dk_sav,
                        clz_cl_smj,
                        pre_mm_syr,
                        ari_ix_sav,
                        glc_cl_smj,
                        cly_pc_sav,
                        slt_pc_sav,
                        snd_pc_sav,
                        ero_kh_sav,
                        lit_cl_smj
                        FROM basin_atlas.basins_", basin_level)
    ))
colnames(basin_atlas_temp) <- c('hybas_id', 'coast', 'elevation', 'slope', 'stream_grad', 
                           'climate', 'prcp', 'aridity', 'veg_class_all', 'clay_pc', 'silt_pc', 
                           'sand_pc', 'erosion', 'lithology')

basin_atlas <- rbind(basin_atlas, basin_atlas_temp)
print(basin_level)
}

basin_atlas[veg_class_all <= 8, vegetation := factor('tree')] 
basin_atlas[veg_class_all %in% c(9, 17, 18), vegetation := factor('mosaic')] 
basin_atlas[veg_class_all %in% 11:15, vegetation := factor('schrub')] 
basin_atlas[veg_class_all %in% 11:15, vegetation := factor('schrub')] 
basin_atlas[veg_class_all == 16, vegetation := factor('cultivated')] 
basin_atlas[veg_class_all == 19, vegetation := factor('bare')] 
basin_atlas[veg_class_all == 21, vegetation := factor('ice')] 

basin_atlas[, lithology := factor(lithology, labels = c('su', 'vb', 'ss', 'pb', 'sm', 'sc', 'va', 'mt', 
                                                           'pa', 'vi', 'wb', 'py', 'pi', 'ev', 'nd', 'ig'))]
basin_atlas[, climate := factor(climate, labels = c('ar1', 'ar2', 'cm', 'cw', 'ecw1', 'ecw2', 'ecm', 'ctd',
                                                    'ctx', 'ctm', 'wtm', 'wtx', 'hm', 'hd', 'ha', 'eha', 
                                                    'ehx', 'ehm'))]

basin_atlas[elevation < 0, elevation := 0]
basin_atlas[slope == -999, slope := NA ]
basin_atlas[stream_grad == -999, stream_grad := NA ]
basin_atlas[clay_pc == -999, clay_pc := NA ]
basin_atlas[silt_pc == -999, silt_pc := NA ]
basin_atlas[sand_pc == -999, sand_pc := NA ]
basin_atlas[lithology == 'nd', lithology := NA] 


basins_atlas_feats <- merge(basin_feats, basin_atlas, by = 'hybas_id')

basin_atlas <- merge(basin_feats[, .(hybas_id, level)], basin_atlas, by = 'hybas_id')
basin_atlas_quant <- basin_atlas[ , lapply(.SD, quantcut, 10), .SDcols = cols, by = 'level']
basin_atlas_quant <- basin_atlas_quant[ , lapply(.SD, factor, labels = seq(0.1, 1, 0.1)), .SDcols = cols, by = 'level']
basin_atlas_factors <- cbind(basin_atlas[, c(1, 3, 7, 15, 16)], basin_atlas_quant)

basins_atlas_quant_feats <- merge(basin_feats, basin_atlas_factors, by = c('hybas_id', 'level'))
basins_atlas_quant_feats[, area_quant := ordered(quantcut(area, 10), labels = seq(0.1, 1, 0.1)), by = 'level']

saveRDS(basins_atlas_quant_feats, paste0(data_path, 'basin_atlas_feats_qq.rds'))
saveRDS(basins_atlas_feats, paste0(data_path, 'basin_atlas_feats.rds'))
