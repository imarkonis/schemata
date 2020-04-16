## Read hydroshed DEM data
# downloaded from https://www.dropbox.com/sh/hmpwobbz9qixxpe/AAAI_jasMJPZl_6wX6d3vEOla?dl=0

# libraries needed
library(raster)
library(data.table)

# define files
data_loc <- "./data/raw/hydrosheds/hydrosheds_dem/"
product <- "dem_15s_grid/"
region <- "eu_dem_15s/"

filename <- paste0(data_loc, product, region,  "w001001.adf")
test_raster <- raster(filename)
plot(test_raster)

cellStats(test_raster, stat = max)

# to convert to xyz table
data_point <- as.data.table(rasterToPoints(test_raster))
# Note, don't use as.data.frame, memory exceeds capacity