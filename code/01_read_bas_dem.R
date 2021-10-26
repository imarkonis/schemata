source('code/source/libs.R')
library(rgdal)

usern <- rstudioapi::askForPassword("Database user")
passwordn <- rstudioapi::askForPassword("Database password")

dsn <- paste0("PG:dbname='earth' host=localhost user=", usern," password=",passwordn," port=5432 schema='basin_dem' table='eu_dem_15s_grid' mode=2")
ras <- readGDAL(dsn) # Get your file as SpatialGridDataFrame
ras2 <- raster(ras,1) # Convert the first Band to Raster
plot(ras2)
