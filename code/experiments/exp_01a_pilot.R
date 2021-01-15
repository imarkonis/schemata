#Define study area and basin size for experiment 01a: Pilot study 
#Lon 42-47E, Lat 25-65N, Basin Area: 100 - 200 km2

source('code/source/libs.R')
source('code/source/pilot.R')

basins_sf <- st_read(filename)
basins_sf <- basins_sf[basins_sf$SUB_AREA > AREA_MIN & 
                                   basins_sf$SUB_AREA < AREA_MAX,]

basins_sf <- st_buffer(basins_sf, dist = 0)
basins_sf <- st_crop(basins_sf, c(xmin = LON_MIN, 
                                    ymin = LAT_MIN, 
                                    xmax = LON_MAX, 
                                    ymax = LAT_MAX))

## Plots for validation
hist(basins_sf$SUB_AREA, breaks = 100)

plot(st_geometry(basins_sf), col = sf.colors(12, categorical = TRUE), 
     border = NA, axes = TRUE)
