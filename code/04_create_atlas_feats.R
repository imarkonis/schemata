source('code/source/libs.R')
source('code/source/database.R')
source('code/source/geo_functions.R')

library(gtools)

basin_ids <- readRDS(paste0(data_path, 'db_ids.rds'))
basin_feats <- readRDS(paste0(data_path, 'basin_feats.rds'))
basin_feats <- merge(basin_ids, basin_feats, by = 'pfaf_id')

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

basin_atlas_feats <- merge(basin_feats, basin_atlas, by = 'hybas_id')
basin_atlas_feats[, level := ordered(level)]
#basin_atlas <- merge(basin_feats[, .(hybas_id, level)], basin_atlas, by = 'hybas_id')

cols <- c('elevation', 'slope', 'stream_grad', 
          'prcp', 'aridity', 'clay_pc', 'silt_pc', 
          'sand_pc', 'erosion')

basin_atlas_quant <- data.table()
for(level_count in basin_levels){
  basin_atlas_temp <- basin_atlas_feats[level == level_count, 
                                        lapply(.SD, quantcut, 10), 
                                        .SDcols = cols]
  basin_atlas_temp <- basin_atlas_temp[, lapply(.SD, factor, labels = seq(0.1, 1, 0.1)), 
                                        .SDcols = cols]
  basin_atlas_temp <- cbind(basin_atlas_feats[level == level_count, 2], basin_atlas_temp)
  basin_atlas_quant <- rbind(basin_atlas_quant, basin_atlas_temp)
}

basins_atlas_quant_feats <- merge(basin_atlas_feats[, c('pfaf_id', 'hybas_id', 'level', 'fractal', 'gc'), ], 
                                  basin_atlas_quant, by = c('pfaf_id'))

saveRDS(basins_atlas_quant_feats, paste0(data_path, 'basin_atlas_feats_qq.rds'))
saveRDS(basins_atlas_feats, paste0(data_path, 'basin_atlas_feats.rds'))
