# hydrological functions that can be applied in hydrosheds
library(hydroTSM)
library(raster)
library(ggplot2)
library(maptools)
library(OasisR)
library(lwgeom)
library(smoothr)
library(data.table)

source("code/dev/calculate_hypsometric_curve.R")

data_loc <- "data/raw/hydrosheds/"
product <- "hydrobasins/standard/"
region <- "eu/"
where <- "hybas_eu_lev01-12_v1c/"
filename <- paste0(data_loc,product,region, where, "hybas_eu_lev06_v1c.shp")
test_shape <- st_read(filename)

HYBAS_IDs <- test_shape$HYBAS_ID
HYBAS_ID_select <- HYBAS_IDs[29]
sel_shape_sub <- subset(test_shape, HYBAS_ID == HYBAS_ID_select)

shape_extent <- extent(sel_shape_sub)

data_loc <- "data/raw/hydrosheds/"
product <- "hydrosheds_dem/dem_15s_grid/"
region <- "eu_dem_15s/"
filename <- paste0(data_loc,product, region, "w0010001.adf")
test_dem <- raster(filename)

crop_dem <- crop(test_dem, shape_extent)
mask_dem <- mask(crop_dem, sel_shape_sub)
dem_to_grid <- as(mask_dem, 'SpatialGridDataFrame')
dem_to_grid@data$COUNT <- mask_dem@data@values

plot(dem_to_grid)
hyps_dem <- hypsometric(dem_to_grid)
hyps_rel <- my_hypso_rel(dem_to_grid, figname = "test.pdf", fname = "test.csv", main = HYBAS_ID_select)

r <- mask_dem > -Inf
plot(mask_dem)
dem_to_shape <- rasterToPolygons(r, dissolve = T)
dem_to_shape_sm <- smooth(dem_to_shape, method = "ksmooth", smoothness = 1.5)

perimeter_dem_sm <- perimeter(dem_to_shape_sm)
area_dem_sm <- area(dem_to_shape_sm)
C_dem_sm <- 4*pi*area_dem_sm/perimeter_dem_sm/perimeter_dem_sm

min_eval <- min(mask_dem@data@values, na.rm = T)
max_eval <- max(mask_dem@data@values, na.rm = T)
mask_dem_norm <- mask_dem
mask_dem_norm@data@values <- (mask_dem@data@values-min_eval)/(max_eval-min_eval)

el_zones <- seq(0.05, 1, 0.05)

C_data <- data.table(Z = el_zones, Circ = 0)

for(z in el_zones){
  print(z)
  tmp <- mask_dem_norm
  tmp@data@values[tmp@data@values > z] <- NA
  r <- tmp > -Inf
  dem_to_shape <- rasterToPolygons(r, dissolve = T)
  area_thresh <- units::set_units(0.5, km^2)
  dem_to_shape_dropped <- drop_crumbs(dem_to_shape, area_thresh)
  dem_to_shape_filled<- fill_holes(dem_to_shape_dropped, area_thresh*3)
  dem_to_shape_sm <- smooth(dem_to_shape_filled, method = "ksmooth", smoothness = 1.5)
  perimeter_dem_sm <- perimeter(dem_to_shape_sm)
  area_dem_sm <- area(dem_to_shape_sm)
  C_dem_sm <- 4*pi*area_dem_sm/perimeter_dem_sm/perimeter_dem_sm
  print(C_dem_sm)
  C_data[Z == z, Circ := C_dem_sm,]
}
