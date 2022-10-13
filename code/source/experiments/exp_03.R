experiment <- 'exp03'

# Paths

results_path <- paste0('./results/experiments/', experiment, '/')
data_path <- paste0('./data/database/')

if(!dir.exists(results_path)) {dir.create(paste0('./results/experiments/', experiment))}

# Database

db_name <- 'earth'
db_schema <- 'basin_boundaries'
host_ip <- '10.152.183.146' 
port_n <- '5432'

# Parallel computing

cores_n <- detectCores()
registerDoParallel(cores = cores_n - 2)

# Constants

regions_all <- c('af', 'ar', 'as', 'au', 'eu', 'gr', 'na', 'sa', 'si')
basin_levels <- 3:11 # Levels 1 and 2 correspond to continents/country borders/Level 12 is almost identical to level 11