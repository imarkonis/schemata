# 1. Read a basin from database by river/basin id or point coordinates that contains basin border, river network and dem
# 2. Plot basin border, river network and dem
# 3. Plot subbasins with labels
# 4. Plot features of subbasins

source('code/source/libs.R')
source('code/source/geo_functions.R')
source('code/source/experiments/exp_03.R')

library(RPostgres)
library(sf)
library(rgdal)

con <- dbConnect(Postgres(), dbname = db_name, host = host_ip, port = port_n,         
                 user = rstudioapi::askForPassword("Database user"),      
                 password = rstudioapi::askForPassword("Database password"))

sample_region <- regions_all[5] # Sample region is Europe
sample_pfaf_id <- 222
  
bas_borders <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.", 
                                           sample_region, "_all WHERE pfaf_id = '", sample_pfaf_id,"'"))
riv_network <- 

#bas_dem <- st_read(con, query = paste0("SELECT * FROM basin_dem.", 
#                                           sample_region, "_dem_15s_grid"))
