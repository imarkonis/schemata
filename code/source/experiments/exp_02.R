library(doParallel)

experiment <- 'exp02'

# Paths
data_loc <- "./data/raw/hydrosheds/"
product <- "hydrosheds_dem/dem_3s_grid/"

dir.create(paste0('./results/experiments/', experiment))
dir.create(paste0('./data/experiments/', experiment))

# Parallel computing
cores_n <- detectCores()
registerDoParallel(cores = cores_n - 4)