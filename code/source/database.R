# Paths

results_path <- paste0('./results/database/')
data_path <- paste0('./data/database/')
basin_dem_path <- "./data/raw/hydrosheds/hydrosheds_dem/dem_15s_grid/eu_dem_15s/"
river_shp_path <- "./data/raw/hydrosheds/hydroatlas/RiverATLAS_Data_v10_shp/"

if(!dir.exists(results_path)) {dir.create(paste0('./results/database/'))}
if(!dir.exists(data_path)) {dir.create(paste0('./data/database/'))}

# Database

db_name <- 'earth'
db_schema <- 'basin_boundaries'
host_ip <- '127.0.0.1' 
port_n <- '5432'

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