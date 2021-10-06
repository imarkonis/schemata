experiment <- 'exp02'

# Constants

#Define study area and basin size for experiment 02
LON_MIN <- 40 
LAT_MIN <- 50 

###############################################################################################

# Paths
data_loc <- "./data/raw/hydrosheds/"
product <- "hydrosheds_dem/dem_3s_grid/"
region <- paste0("n", LAT_MIN, "e0", LON_MIN)
rasterfile_dem <- paste0(data_loc, product, region, "_con_grid/", region, "_con/", region, "_con/w001001.adf")

dir.create(paste0('./results/experiments/', experiment))
dir.create(paste0('./data/experiments/', experiment))
