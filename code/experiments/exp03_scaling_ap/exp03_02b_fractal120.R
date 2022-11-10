#Exploratory data analysis of basins with fractals below 1.17 and above 1.20

basins <- readRDS(paste0(data_path, 'basin_atlas_feats.rds'))

basins[fractal > 1.20, median(prcp)]
basins[fractal < 1.17, median(prcp)]
basins[, median(prcp)]

basins_117 <- basins[fractal < 1.17, .N, lithology]
basins_117[, N := N/sum(basins_117$N)]
basins_120 <- basins[fractal > 1.20, .N, lithology]
basins_120[, N := N/sum(basins_120$N)]
basins_all <- basins[, .N, lithology]
basins_all[, N := N/sum(basins_all$N)]

basins_lithology <- merge(basins_117,
                          basins_120, 
                          by = 'lithology')
basins_lithology <- merge(basins_lithology,
                          basins_all,
                          by = 'lithology')
colnames(basins_lithology)[2:4] <- c('1.17', '1.20', 'all')

basins_lithology$`1.17`/basins_lithology$`1.20`
basins_lithology$`1.20`/basins_lithology$all
basins_lithology$`1.17`/basins_lithology$all

