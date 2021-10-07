source('code/source/libs.R')
source('code/source/geo_functions.R')
source('code/source/experiments/exp_03.R')

basin_level <- 6
data_files <- list.files(paste0(data_path, '/basins/level_', basin_level))
basin_ids <- substr(data_files, 7, nchar(data_files[1]) - 4) 
basins_n <- length(data_files)

basins_225 <- st_make_valid(basins_225)
basins_225_line <- st_cast(basins_225, "MULTILINESTRING")

basins <- foreach(basin_count = 1:basins_n, .packages = c('data.table', 'sf'), 
                  .combine = 'rbind') %dopar% {
                    basin <- readRDS(paste0(data_path, 'basins/level_', basin_level, '/', data_files[basin_count]))
                    basin <- st_make_valid(basin)
                    basin_line <- st_cast(basin, "MULTILINESTRING")
                    data.table(pfaf_id = factor(basin_ids[basin_count]),
                               region = basin$region,
                               area = as.numeric(st_area(basin)),
                               perimeter = as.numeric(st_length(basin_line)))
                  }
basins <- unique(basins[complete.cases(basins)])
saveRDS(basins, paste0(data_path, 'basin_feats_', basin_level, '.rds'))

basins[, log_area := log(area)]
basins[, log_perimeter := log(perimeter)]
lm_coefs <- basins[, as.list(coef(lm(log_area ~ log_perimeter))), .(pfaf_id, region)]
lm_coefs <- unique(lm_coefs[complete.cases(lm_coefs)])
colnames(lm_coefs)[3:4] <- c('intercept', 'slope')
saveRDS(lm_coefs, paste0(results_path, 'pa_lm_coefs_', basin_level, '.rds'))
