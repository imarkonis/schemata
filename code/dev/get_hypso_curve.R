# hydrological functions that can be applied in hydrosheds
library(raster)
library(sf)

source("code/dev/calculate_rel_hypsometric_curve.R")
source('code/source/geo_utils.R')

data_loc <- "data/raw/hydrosheds/"
product <- "hydrobasins/standard/"
region <- "eu/"
where <- "hybas_eu_lev01-12_v1c/"
filename <- paste0(data_loc,product,region, where, "hybas_eu_lev06_v1c.shp")
test_shape <- st_read(filename)

HYBAS_IDs <- test_shape$HYBAS_ID
HYBAS_ID_select <- HYBAS_IDs[29]
shape <- subset(test_shape, HYBAS_ID == HYBAS_ID_select)

data_loc <- "data/raw/hydrosheds/"
product <- "hydrosheds_dem/dem_15s_grid/"
region <- "eu_dem_15s/"
filename <- paste0(data_loc,product, region, "w0010001.adf")
test_dem <- raster(filename)
cropped_basin_dem <- crop_basin(shape, test_dem, asSpatialGridDataFrame = T)
hyps_rel <- hypso_rel(cropped_basin_dem)