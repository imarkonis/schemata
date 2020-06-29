# get property table (metadata)
library(rgee)

# Initialize GEE session
ee_Initialize(drive = T)

data_gee_id <- "WWF/HydroSHEDS/v1/FreeFlowingRivers"
info_data <- ee$FeatureCollection(data_gee_id)$first()$getInfo()
property_names <- names(info_data$properties)
