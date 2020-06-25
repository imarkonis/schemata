## Read hydroshed River Shape files
# downloaded from Google earth engine: WWF/HydroSHEDS/v1/FreeFlowingRivers
# 
library(rgee)

# Initialize GEE session
ee_Initialize()

data_gee_id <- "WWF/HydroSHEDS/v1/FreeFlowingRivers"

# define filter box
filter_box <- ee$Geometry$Rectangle(20, 36, 25, 40)
pilot_rivers <- ee$FeatureCollection(data_gee_id)$filterBounds(filter_box)

task <- ee_table_to_drive(
  pilot_rivers,
  description = 'exportTable',
  folder = 'RGEE',
  fileFormat = 'SHP'
)
task$start()
ee_drive_to_local(task = task,
                  dsn = 'data/raw/hydrosheds/GEE/river_pilot',
                  quiet = F)

