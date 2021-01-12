#Crops basin from dem according to shape and standardizes to 0-1 elevation if needed

crop_basin <- function(shape, dem, standardize = F){
  shape_extent <- extent(shape)
  crop_dem <- crop(dem, shape_extent)
  mask_dem <- mask(crop_dem, shape)
  dem_to_grid <- as(mask_dem, 'SpatialGridDataFrame')
  dem_to_grid@data$COUNT <- mask_dem@data@values
  
  if(standardize == T){
    min_eval <- min(mask_dem@data@values, na.rm = T)
    max_eval <- max(mask_dem@data@values, na.rm = T)
    mask_dem@data@values <- (mask_dem@data@values-min_eval)/(max_eval-min_eval)
  }
  return(mask_dem)
}