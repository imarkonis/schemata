source('code/source/libs.R')
source('code/source/geo_functions.R')
source('code/source/experiments/exp_03.R')

basin_level <- 4
data_files <- list.files(paste0(data_path, '/basins/level_', basin_level))
basin_ids <- substr(data_files, 7, nchar(data_files[1]) - 4) 
basins_tot <- length(data_files)

basins <- foreach(basin_n = 1:basins_tot, .packages = c('data.table', 'sf'), 
                  .combine = 'rbind') %dopar% {
  basin <- readRDS(paste0(data_path, 'basins/level_', basin_level, '/', data_files[basin_n]))
  data.table(pfaf_id = factor(basin_ids[basin_n]),
                                area = as.numeric(st_area(basin)),
                                perimeter = as.numeric(st_length(basin)))
}
basins <- basins[complete.cases(basins)]
saveRDS(basins, paste0(data_path, 'basin_feats_', basin_level, '.rds'))

basins[, log_area := log(area)]
basins[, log_perimeter := log(perimeter)]
lm_coefs <- basins[, as.list(coef(lm(log_area ~ log_perimeter))), pfaf_id]
colnames(lm_coefs)[2:3] <- c('intercept', 'slope')
saveRDS(lm_coefs, paste0(results_path, 'pa_lm_coefs_', basin_level, '.rds'))