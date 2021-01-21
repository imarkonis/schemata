#Download the river networks from GEE

library(rgee)
source('code/source/libs.R')
source('code/source/pilot.R')
source('code/source/graphics.R')

data_loc <- paste0("./data/experiments/", experiment, '/')

ee_Initialize(drive = T)
data_gee_id <- "WWF/HydroSHEDS/v1/FreeFlowingRivers"
filename_local <- 'rivers_pilot'

filter_box <- ee$Geometry$Rectangle(LON_MIN, LAT_MIN, LON_MAX, LAT_MAX)
rivers <- ee$FeatureCollection(data_gee_id)$filterBounds(filter_box)

rivers_subset <- ee_table_to_drive(
  rivers,
  description = 'exportTable',
  folder = 'RGEE',
  fileFormat = 'SHP'
)

rivers_subset$start()
ee_monitoring(rivers_subset) 
ee_drive_to_local(task = rivers_subset,
                  dsn = paste0(data_loc, filename_local),
                  quiet = F)


#Validation plot

rivers_pilot <- st_read(paste0(data_loc, filename_local, '.shp'), quiet = T)  
p_bd <- plot_rivers(rivers_pilot)
p_bd



