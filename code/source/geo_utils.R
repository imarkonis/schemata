#Crops basin from dem according to shape and standardizes to 0-1 elevation if needed

crop_basin <- function(shape, dem, standardize = F, asSpatialGridDataFrame = F){
  if(!"raster" %in% .packages()){
    library(raster)
  }
  
  if(!"sf" %in% .packages()){
    library(sf)
  }
  shape_extent <- extent(shape)
  crop_dem <- crop(dem, shape_extent)
  mask_dem <- mask(crop_dem, shape)
  
  if(asSpatialGridDataFrame){
    dem_to_grid <- as(mask_dem, 'SpatialGridDataFrame')
    dem_to_grid@data$COUNT <- mask_dem@data@values
    return(dem_to_grid)
  }

  if(standardize == T){
    min_eval <- min(mask_dem@data@values, na.rm = T)
    max_eval <- max(mask_dem@data@values, na.rm = T)
    mask_dem@data@values <- (mask_dem@data@values-min_eval)/(max_eval-min_eval)
  }
  return(mask_dem)
}

circ_ratio <- function(shape){
  if(!"OasisR" %in% .packages()){
    library(OasisR)
  }
  perimeter_sh <- perimeter(shape)
  area_sh <- area(shape)
  C_dem_sm <- 4*pi*area_sh/perimeter_sh/perimeter_sh
  return(C_dem_sm)
}
