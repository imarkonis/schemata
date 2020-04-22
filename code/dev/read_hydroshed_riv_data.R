## Read hydroshed River Shape files
# downloaded from https://www.dropbox.com/sh/hmpwobbz9qixxpe/AAAI_jasMJPZl_6wX6d3vEOla?dl=0

library(sf)

data_loc <- "./data/HydroSHED/"
product <- "HydroSHEDS_RIV/"
resolution <- "RIV_30s/"
region <- "eu_riv_30s/"
filename <- paste0(data_loc, product, resolution, region, "eu_riv_30s.shp")
test_shape <- st_read(filename)  

# test shape is large and extremely detailed
# UP_CELLS: = Number of cells connecting a river
min_cells <- 5000
test_filt <- test_shape[test_shape$UP_CELLS > min_cells,]
plot(test_filt$geometry, axes = T, col = "royalblue4")
