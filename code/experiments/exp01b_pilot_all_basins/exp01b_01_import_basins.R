#Import and preprocess basin data

source('code/source/libs.R')
source('code/source/pilot_b.R')
source('code/source/graphics.R')

data_loc <- "./data/raw/hydrosheds/"
product <- "hydrobasins/standard/"
region <- "eu/"
where <- "hybas_eu_lev01-12_v1c/"
shapefile_basins <- paste0(data_loc, product, region, where, "hybas_eu_lev06_v1c.shp")

basins_sf_raw <- st_read(shapefile_basins)

basins_sf <- st_crop(basins_sf_raw, c(xmin = LON_MIN, 
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
