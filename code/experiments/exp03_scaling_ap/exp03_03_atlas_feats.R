source('code/source/libs.R')
source('code/source/geo_functions.R')
source('code/source/experiments/exp_03.R')

library(RPostgres)
library(sf)
library(gtools)
library(ggridges)

con <- dbConnect(Postgres(), dbname = db_name, host = host_ip, port = port_n,         
                 user = rstudioapi::askForPassword("Database user"),      
                 password = rstudioapi::askForPassword("Database password"))

basin_ids <- foreach(region_count = 1:length(regions_all), .packages = c('data.table', 'sf', 'RPostgres' ), 
                  .combine = 'rbind') %do% {
                  data.table(st_read(con, query = paste0("SELECT pfaf_id, hybas_id FROM basin_boundaries.", regions_all[region_count], "_all")))
                  }                    

basin_feats <- readRDS(paste0(data_path, 'basin_feats.rds'))
basin_feats <- merge(basin_ids, basin_feats, by = 'pfaf_id')
basin_atlas_11 <- 
  data.table(st_read(
    con, query = paste0("SELECT hybas_id, 
                        coast,
                        ele_mt_sav,
                        slp_dg_sav,
                        sgr_dk_sav,
                        pre_mm_syr,
                        ari_ix_sav,
                        glc_cl_smj,
                        cly_pc_sav,
                        slt_pc_sav,
                        snd_pc_sav,
                        ero_kh_sav,
                        lit_cl_smj
                        FROM basin_atlas.basins_11")
    ))
basin_atlas_11 <- basin_atlas_11[coast == 0]
basin_atlas_11[, coast := NULL]

colnames(basin_atlas_11) <- c('hybas_id', 'elevation', 'slope', 'stream_grad', 
                              'prcp', 'aridity', 'veg_class_all', 'clay_pc', 'silt_pc', 
                              'sand_pc', 'erosion', 'lith_class')
basin_atlas_11[, veg_class := factor('NA')] 
basin_atlas_11[veg_class_all <= 8, veg_class := factor('tree')] 
basin_atlas_11[veg_class_all %in% c(9, 17, 18), veg_class := factor('mosaic')] 
basin_atlas_11[veg_class_all %in% 11:15, veg_class := factor('schrub')] 
basin_atlas_11[veg_class_all %in% 11:15, veg_class := factor('schrub')] 
basin_atlas_11[veg_class_all == 16, veg_class := factor('cultivated')] 
basin_atlas_11[veg_class_all == 19, veg_class := factor('bare')] 
basin_atlas_11[veg_class_all == 21, veg_class := factor('ice')] 

basin_atlas_11[, lith_class := factor(lith_class, labels = c('su', 'vb', 'ss', 'pb', 'sm', 'sc', 'va', 'mt', 
                                      'pa', 'vi', 'wb', 'py', 'pi', 'ev', 'nd', 'ig'))]

basin_atlas_11[elevation < 0, elevation := 0]
basin_atlas_11[slope == -999, slope := NA ]
basin_atlas_11[stream_grad == -999, stream_grad := NA ]
basin_atlas_11[clay_pc == -999, clay_pc := NA ]
basin_atlas_11[silt_pc == -999, silt_pc := NA ]
basin_atlas_11[sand_pc == -999, sand_pc := NA ]

cols <- c('elevation', 'slope', 'stream_grad', 
          'prcp', 'aridity', 'clay_pc', 'silt_pc', 
          'sand_pc', 'erosion')

basin_atlas_11_quant <- basin_atlas_11[ , lapply(.SD, quantcut, 10), .SDcols = cols]
basin_atlas_11_quant <- basin_atlas_11_quant[ , lapply(.SD, factor, labels = seq(0.1, 1, 0.1)), .SDcols = cols]
basin_atlas_11_factors <- cbind(basin_atlas_11[, c(1, 12, 13)], basin_atlas_11_quant)
basins <- merge(basin_feats[level == 11], basin_atlas_11_factors, by = 'hybas_id')
basins[, level := NULL]

saveRDS(basins, paste0(data_path, 'basin_feats_11.rds'))
