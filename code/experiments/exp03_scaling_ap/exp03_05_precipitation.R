source('code/source/libs.R')
source('code/source/graphics.R')
source('code/source/experiments/exp_03.R')

basins <- readRDS(paste0(data_path, 'basin_atlas_feats_11.rds'))
basins_qq <- readRDS(paste0(data_path, 'basin_atlas_feats_qq_11.rds'))

basins_tidy <- melt(basins[, c(-1:-4)], id.vars = c('fractal', 'gc', 'vegetation', 'lithology'))
basins_tidy <- basins_tidy[complete.cases(basins_tidy)]
basins_tidy[variable == 'prcp', median(value), .(lithology)]
basins_tidy[variable == 'prcp', median(value), .(lithology)]

basins_qq_tidy <- melt(basins_qq[, c(-1:-4)], id.vars = c('fractal', 'gc', 'vegetation', 'lithology'))
basins_qq_tidy <- basins_qq_tidy[complete.cases(basins_qq_tidy)]
basins_qq_tidy[variable == 'prcp', median(fractal), .(value)]
