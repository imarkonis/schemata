experiment <- 'exp04'

# Constants

#Define study area and basin size for experiment 04: Create database
#Lon 42-47E, Lat 25-65N

LON_MIN <- 42 
LON_MAX <- 45 
LAT_MIN <- 52 
LAT_MAX <- 55 

# Paths

results_path <- paste0('./results/experiments/', experiment)
data_path <- paste0('./data/experiments/', experiment)

if(!dir.exists(results_path)) {dir.create(paste0('./results/experiments/', experiment))}
if(!dir.exists(data_path)) {dir.create(paste0('./data/experiments/', experiment))}
