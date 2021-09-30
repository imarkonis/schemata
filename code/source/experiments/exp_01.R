experiment <- 'exp01'

# Paths

results_path <- paste0('./results/experiments/', experiment)
data_path <- paste0('./data/experiments/', experiment)

if(!dir.exists(results_path)) {dir.create(paste0('./results/experiments/', experiment))}
if(!dir.exists(data_path)) {dir.create(paste0('./data/experiments/', experiment))}

# Database

db_name <- 'earth'
db_schema <- 'hs_basins'
host_ip <- '127.0.0.1' 
port_n <- '5432'

# Parallel computing

cores_n <- detectCores()
registerDoParallel(cores = cores_n - 1)

# Constants

#Define study area and basin size for experiment 01: Pilot study 
#Lon 42-47E, Lat 25-65N, Basin Area: 100 - 200 km2

AREA_MIN <- 100
AREA_MAX <- 200
LON_MIN <- 42 
LON_MAX <- 45 
LAT_MIN <- 52 
LAT_MAX <- 55 