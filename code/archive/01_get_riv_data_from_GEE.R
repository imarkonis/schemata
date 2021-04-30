## Read hydroshed River Shape files
# downloaded from Google earth engine: WWF/HydroSHEDS/v1/FreeFlowingRivers
# 
library(rgee)

# Initialize GEE session
ee_Initialize(drive = T)
data_gee_id <- "WWF/HydroSHEDS/v1/FreeFlowingRivers"

# Define filter box for croping
min_lat <- 36
max_lat <- 42
min_lon <- 18
max_lon <- 26

filter_box <- ee$Geometry$Rectangle(min_lon, min_lat, max_lon, max_lat)

# Subset & download shapefile
pilot_rivers <- ee$FeatureCollection(data_gee_id)$filterBounds(filter_box)

subset_rivers <- ee_table_to_drive(
  pilot_rivers,
  description = 'exportTable',
  folder = 'RGEE',
  fileFormat = 'SHP'
)

subset_rivers$start()
ee_monitoring(subset_rivers) 
ee_drive_to_local(task = subset_rivers,
                  dsn = 'data/raw/hydrosheds/GEE/river_pilot',
                  quiet = F)


