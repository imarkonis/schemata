# Paths

results_path <- paste0('./results/database/')
data_path <- paste0('./data/database/')
basin_dem_path <- "./data/raw/hydrosheds/hydrosheds_dem/dem_15s_grid/eu_dem_15s/"
basin_shp_path <- "./data/raw/hydrosheds/hydrobasins/"
river_shp_path <- "./data/raw/hydrosheds/hydroatlas/RiverATLAS_Data_v10_shp/"

if(!dir.exists(results_path)) {dir.create(paste0('./results/database/'))}
if(!dir.exists(data_path)) {dir.create(paste0('./data/database/'))}

# Database

db_name <- 'earth'
db_schema <- 'basin_boundaries'
host_ip <- '127.0.0.1' 
port_n <- '5432'

con <- dbConnect(Postgres(), dbname = db_name, host = host_ip, port = port_n,        
                 user = rstudioapi::askForPassword("Database user"),      
                 password = rstudioapi::askForPassword("Database password"))

# Parallel computing

cores_n <- detectCores()
registerDoParallel(cores = cores_n - 4)

# Constants

regions_all <- list.dirs(basin_shp_path, full.names = FALSE)[-1]
basin_levels <- 3:11 # Levels 1 and 2 correspond to continents/country borders/Level 12 is almost identical to level 11
