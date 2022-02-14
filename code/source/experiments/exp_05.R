
experiment <- 'exp05'


results_path <- paste0('./results/experiments/', experiment)
data_path <- paste0('./data/experiments/', experiment)

# database
db_name <- 'earth'
db_schema <- 'basin_boundaries'
host_ip <- '127.0.0.1' 
port_n <- '5432'


# Parallel computing

cores_n <- detectCores()
registerDoParallel(cores = cores_n - 2)

# Constants

