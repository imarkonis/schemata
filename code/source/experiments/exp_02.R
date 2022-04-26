library(doParallel)

experiment <- 'exp02'

# Database

db_name <- 'earth'
db_schema <- 'basin_boundaries'
host_ip <- '127.0.0.1' 
port_n <- '5432'

# Paths
data_loc <- "./data/raw/hydrosheds/"
product <- "hydrosheds_dem/dem_3s_grid/"

dir.create(paste0('./results/experiments/', experiment))
dir.create(paste0('./data/experiments/', experiment))

# Parallel computing
cores_n <- detectCores()
registerDoParallel(cores = cores_n - 4)