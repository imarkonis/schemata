#Import and preprocess basin data

source('code/source/libs.R')
source('code/source/graphics.R')
source('code/source/experiments/exp_01.R')

data_loc <- "./data/raw/hydrosheds/"
product <- "hydrobasins/standard/"
region <- "eu/"
where <- "hybas_eu_lev01-12_v1c/"

shapefile_basins_01 <- paste0(data_loc, product, region, where, "hybas_eu_lev06_v1c.shp")
shapefile_basins_02 <- paste0(data_loc, product, region, where, "hybas_eu_lev12_v1c.shp")

basins_01 <- st_read(shapefile_basins_01)
basins_02 <- st_read(shapefile_basins_02)

region_coords <- c(xmin = LON_MIN, 
                   ymin = LAT_MIN, 
                   xmax = LON_MAX, 
                   ymax = LAT_MAX)

basins_01 <- st_crop(st_make_valid(basins_01), region_coords)
basins_02 <- st_crop(st_make_valid(basins_02), region_coords)

basin_ids_01 <- data.table(cbind(HYBAS_ID_01 = basins_01$HYBAS_ID, 
                                 PFAF_ID = as.character(basins_01$PFAF_ID)))
basin_ids_02 <- data.table(cbind(HYBAS_ID_02 = basins_02$HYBAS_ID, 
                                 PFAF_ID = substr(as.character(basins_02$PFAF_ID), 1, 6)))

basin_ids <- basin_ids_02[basin_ids_01, on = 'PFAF_ID']

basin_06_id <- '2060320430'
basin_06 <- basins_01[basins_01$HYBAS_ID == basin_06_id, ]
basin_inters <- st_intersection(basin_06, basins_02)

plot(st_geometry(basins_01[basins_01$HYBAS_ID == basin_06_id, ]), col = sf.colors(12, categorical = TRUE), 
     border = NA, axes = TRUE)
plot(st_geometry(basin_inters), col = sf.colors(12, categorical = TRUE), 
     border = NA, axes = TRUE)

table(basin_ids_02$PFAF_ID)

# This example illustrates that if you start at level 12 you can find all the sub-basins
# using PFAF_ID. For instance 223609091200 -> 22360909120 -> 2236090912 -> 2236090912 etc.)

basin_ids_02[basin_ids_01, on = 'id']
basin_ids_01[basin_ids_02, on = 'id']


substr(basins_01$HYBAS_ID, 5, 10)

## Validation plots

hist(basins_01$SUB_AREA, breaks = 100)
hist(basins_02$SUB_AREA, breaks = 100)

plot(st_geometry(basins_01), col = sf.colors(12, categorical = TRUE), 
     border = NA, axes = TRUE)
plot(st_geometry(basins_02), col = sf.colors(12, categorical = TRUE), 
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
