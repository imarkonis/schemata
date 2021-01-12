# hydrological functions that can be applied in hydrosheds
library(data.table)
library(raster)
library(sf)
library(OasisR)
library(lwgeom)
library(smoothr)

source('./')
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

circ_rat <- function(basin, area_thresh_unit = 0.5, z_step = 0.05){
  el_zones <- seq(z_step, 1, z_step)
  C_data <- data.table(Z = el_zones, Circ = 0)
  
  for(z in el_zones){
    print(paste('elevation zone', z))
    tmp <- basin
    basin@data@values[tmp@data@values > z] <- NA
    r <- tmp > -Inf
    dem_to_shape <- rasterToPolygons(r, dissolve = T)
    area_thresh <- units::set_units(area_thresh_unit, km^2)
    dem_to_shape_dropped <- drop_crumbs(dem_to_shape, area_thresh)
    dem_to_shape_filled <- fill_holes(dem_to_shape_dropped, area_thresh*3)
    dem_to_shape_sm <- smooth(dem_to_shape_filled, method = "ksmooth", smoothness = 1.5)
    perimeter_dem_sm <- perimeter(dem_to_shape_sm)
    area_dem_sm <- area(dem_to_shape_sm)
    C_dem_sm <- 4*pi*area_dem_sm/perimeter_dem_sm/perimeter_dem_sm
    C_data[Z == z, Circ := C_dem_sm,]
  }
  return(C_data)
}

basin <- crop_basin(shape, test_dem, norm = T)
circ_ratio <- circ_rat(basin, 0.5, 0.05)

