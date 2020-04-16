## Read hydroshed Basin Shape files
# downloaded from https://www.dropbox.com/sh/hmpwobbz9qixxpe/AAAI_jasMJPZl_6wX6d3vEOla?dl=0

# libraries needed
library(sf)

data_loc <- "data/HydroSHED/"
product <- "HydroBASINS/standard/"
region <- "eu/"
where <- "hybas_eu_lev01-12_v1c/"
filename <- paste0(data_loc,product,region, where, "hybas_eu_lev06_v1c.shp")
test_shape <- st_read(filename)


# plot test_shape
plot(st_geometry(test_shape), col = sf.colors(12, categorical = TRUE), border = NA, 
     axes = TRUE)

