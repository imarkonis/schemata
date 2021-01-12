# hydrological functions that can be applied in hydrosheds
library(raster)
library(sf)

source("code/dev/calculate_rel_hypsometric_curve.R")

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
shape_extent <- extent(shape)
crop_dem <- crop(test_dem, shape_extent)
mask_dem <- mask(crop_dem, shape)
dem_to_grid <- as(mask_dem, 'SpatialGridDataFrame')
dem_to_grid@data$COUNT <- mask_dem@data@values
hyps_rel <- hypso_rel(dem_to_grid)
  
