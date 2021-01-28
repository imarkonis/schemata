experiment <- 'exp01'

# Constants

#Define study area and basin size for experiment 01: Pilot study 
#Lon 42-47E, Lat 25-65N, Basin Area: 100 - 200 km2

AREA_MIN <- 100
AREA_MAX <- 200
LON_MIN <- 42 
LON_MAX <- 45 
LAT_MIN <- 52 
LAT_MAX <- 55 

###############################################################################################

# Paths
dir.create(paste0('./results/experiments/', experiment))
dir.create(paste0('./data/experiments/', experiment))

###############################################################################################

# Parallel
cores_n <- detectCores()
cs <- makeCluster(cores_n - 1)
