#Estimate basin features 

source('code/source/libs.R')
source('code/source/functions.R')
source('code/source/geo_utils.R')
source('code/source/geo_functions.R')
source('code/source/experiments/exp_01.R')

catchments <- readRDS(paste0(data_path, "/catchments.rds"))

catchments[[1]]



# Validation plots

plot(gc~tot_riv_length, data = basin_feats)
