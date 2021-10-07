experiment <- 'exp03'
regions_all <- list.dirs('./data/raw/hydrosheds/hydrobasins', full.names = FALSE)[-1]

# Paths

results_path <- paste0('./results/experiments/', experiment, '/')
data_path <- paste0('./data/experiments/', experiment, '/')

if(!dir.exists(results_path)) {dir.create(paste0('./results/experiments/', experiment))}
if(!dir.exists(data_path)) {dir.create(paste0('./data/experiments/', experiment))}

# Database

db_name <- 'earth'
db_schema <- 'basin_boundaries'
host_ip <- '127.0.0.1' 
port_n <- '5432'

# Parallel computing

cores_n <- detectCores()
registerDoParallel(cores = cores_n - 4)
