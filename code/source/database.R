# Paths

results_path <- paste0('./results/database/')
data_path <- paste0('./data/database/')

if(!dir.exists(results_path)) {dir.create(paste0('./results/database/'))}
if(!dir.exists(data_path)) {dir.create(paste0('./data/database/'))}

# Database

db_name <- 'earth'
db_schema <- 'hs_basins'

# Parallel computing

cores_n <- detectCores()
registerDoParallel(cores = cores_n - 1)

# Constants

#Area coordinates and basin size for testing  
#Lon 42-47E, Lat 25-65N, Basin Area: 100 - 200 km2

AREA_MIN <- 100
AREA_MAX <- 200
LON_MIN <- 42 
LON_MAX <- 45 
LAT_MIN <- 52 
LAT_MAX <- 55 