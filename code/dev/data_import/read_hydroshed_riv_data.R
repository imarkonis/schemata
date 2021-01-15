## Read hydroshed River Shape files
# downloaded from https://www.dropbox.com/sh/hmpwobbz9qixxpe/AAAI_jasMJPZl_6wX6d3vEOla?dl=0

library(sf)

data_loc <- "./data/raw/hydrosheds/"
product <- "hydrosheds_riv/"
region <- "RIV_30s/"
where <- "eu_riv_30s/"

filename <- paste0(data_loc, product, region, where, "eu_riv_30s.shp")
eu_rivers <- st_read(filename)  

# test shape is large and extremely detailed
# UP_CELLS: = Number of cells connecting a river
min_cells <- 5000
test_filt <- eu_rivers[eu_rivers$UP_CELLS > min_cells,]
plot(test_filt$geometry, axes = T, col = "royalblue4")

# smaller region for less computational effort
box = c(xmin = 20, ymin = 40, xmax = 25, ymax = 36)
pilot_area <- st_crop(eu_rivers$geometry, box) 
plot(pilot_area)


