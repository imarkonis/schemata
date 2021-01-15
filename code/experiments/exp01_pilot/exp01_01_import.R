#Define study area and basin size for experiment 01: Pilot study 
#Lon 42-47E, Lat 25-65N, Basin Area: 100 - 200 km2
#Import and preprocess data

source('code/source/libs.R')
source('code/source/pilot.R')

basins_sf_raw <- st_read(filename)
basins_sf <- basins_sf_raw[basins_sf_raw$SUB_AREA > AREA_MIN & 
                             basins_sf_raw$SUB_AREA < AREA_MAX,]

basins_sf <- st_buffer(basins_sf, dist = 0)
basins_sf <- st_crop(basins_sf, c(xmin = LON_MIN, 
                                    ymin = LAT_MIN, 
                                    xmax = LON_MAX, 
                                    ymax = LAT_MAX))
basins_ids <- basins_sf$HYBAS_ID
basins_sf <- basins_sf_raw[basins_sf_raw$HYBAS_ID %in% basins_ids, ]

saveRDS(basins_sf, "./data/experiments/exp01/basins_pilot.rds")

## Plots for validation
hist(basins_sf$SUB_AREA, breaks = 100)

plot(st_geometry(basins_sf), col = sf.colors(12, categorical = TRUE), 
     border = NA, axes = TRUE)

