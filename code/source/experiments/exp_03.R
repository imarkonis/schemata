experiment <- 'exp03'

# Paths

results_path <- paste0('./results/experiments/', experiment, '/')
data_path <- paste0('./data/experiments/', experiment, '/')

if(!dir.exists(results_path)) {dir.create(paste0('./results/experiments/', experiment))}
if(!dir.exists(data_path)) {dir.create(paste0('./data/experiments/', experiment))}

# Database

db_name <- 'earth'
db_schema <- 'hs_basins'

# Parallel computing

cores_n <- detectCores()
registerDoParallel(cores = cores_n - 1)
