## Read hydroshed DEM data
# downloaded from https://www.dropbox.com/sh/hmpwobbz9qixxpe/AAAI_jasMJPZl_6wX6d3vEOla?dl=0

# libraries needed
library(raster)
library(data.table)

# define files
data_loc <- "data/HydroSHED/"
product <- "DEM_30s_GRID/"
region <- "eu_dem_30s_grid/eu_dem_30s/"
where <- "eu_dem_30s/"


filename <- paste0(data_loc,product,region, where, "w001001.adf")
test_raster <- raster(filename)
plot(test_raster)

cellStats(test_raster, stat = max)

# to convert to xyz table
data_point <- as.data.table(rasterToPoints(test_raster))
# Note, don't use as.data.frame, memory exceeds capacity