## Read hydroshed Basin Shape files
# downloaded from https://www.dropbox.com/sh/hmpwobbz9qixxpe/AAAI_jasMJPZl_6wX6d3vEOla?dl=0

library(sf)

data_loc <- "./data/raw/hydrosheds/"
product <- "hydrobasins/standard/"
region <- "eu/"
where <- "hybas_eu_lev01-12_v1c/"
filename <- paste0(data_loc, product, region, where, "hybas_eu_lev10_v1c.shp")
test_shape <- st_read(filename)

# plot test_shape
plot(st_geometry(test_shape), col = sf.colors(12, categorical = TRUE), border = NA, 
     axes = TRUE)

single_shape_id <- as.character(test_shape$HYBAS_ID[122])
plot(st_geometry(test_shape[test_shape$HYBAS_ID == single_shape_id, ]), 
     col = sf.colors(12, categorical = TRUE), border = NA, 
     axes = TRUE)



