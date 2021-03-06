#Import and preprocess basin data

source('code/source/libs.R')
source('code/source/graphics.R')
source('code/source/experiments/exp_01.R')

data_loc <- "./data/raw/hydrosheds/"
product <- "hydrobasins/"
region <- "eu/"

shapefile_basins <- paste0(data_loc, product, region, "hybas_eu_lev10_v1c.shp")

basins_sf_raw <- st_read(shapefile_basins)
basins_sf <- basins_sf_raw[basins_sf_raw$SUB_AREA > AREA_MIN & 
                             basins_sf_raw$SUB_AREA < AREA_MAX,]

basins_sf <- st_crop(st_make_valid(basins_sf), c(xmin = LON_MIN, 
                                  ymin = LAT_MIN, 
                                  xmax = LON_MAX, 
                                  ymax = LAT_MAX))
basins_ids <- basins_sf$HYBAS_ID
basins_sf <- basins_sf_raw[basins_sf_raw$HYBAS_ID %in% basins_ids, ]

st_write(basins_sf, paste0("./data/experiments/", experiment, "/basins_pilot.shp"))


## Validation plots

hist(basins_sf$SUB_AREA, breaks = 100)

plot(st_geometry(basins_sf), col = sf.colors(12, categorical = TRUE), 
     border = NA, axes = TRUE)

### Better crop idea: still not working!

cropper <- st_polygon(list(matrix(c(LON_MIN, LAT_MIN), ncol = 2), 
                           matrix(c(LON_MIN, LAT_MAX), ncol = 2), 
                           matrix(c(LON_MAX, LAT_MAX), ncol = 2), 
                           matrix(c(LON_MAX, LAT_MIN), ncol = 2),
                           matrix(c(LON_MIN, LAT_MIN), ncol = 2)))
cropper <- st_sfc(cropper)
st_crs(cropper) =  4326
cropper = st_sf(data.frame(a = 1, geom = sfc))
test <- st_intersection(basins_sf, cropper)
