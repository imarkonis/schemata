source('code/source/libs.R')
source('code/source/functions.R')
source('code/source/geo_utils.R')
source('code/source/database.R')

library(RPostgres)

rasterfile_dem <- paste0(basin_dem_path, "w001001.adf")
dem_raster <- raster(rasterfile_dem)
riverfile_shp <- paste0(river_shp_path, "RiverATLAS_v10_eu.shp")
rivers_sf <- st_read(riverfile_shp)

con <- dbConnect(Postgres(), dbname = db_name,       
                 user = rstudioapi::askForPassword("Database user"),      
                 password = rstudioapi::askForPassword("Database password"))

# Crop basins in the region
query_crop <- "WITH region AS (SELECT * FROM (VALUES(1,ST_GeomFromText('POLYGON((19 35,28 35,28 42,19 42,19 35))',4326))) Region (id, geom)) SELECT ST_Intersection(region.geom, st_makevalid(eu_basins.geom)) FROM region JOIN hs_basins.eu_basins ON ST_Intersects(region.geom, eu_basins.geom)"
# Get all basins that overlap the region
query_overlap <- "SELECT geom FROM hs_basins.eu_basins WHERE ST_Intersects(st_makevalid(eu_basins.geom), ST_GeomFromText('POLYGON((43 52,45 52,45 55,43 55,43 52))',4326))"
# Get basins within the region
query_within <- "SELECT * FROM hs_basins.eu_basins WHERE ST_Within(st_makevalid(eu_basins.geom), ST_GeomFromText('POLYGON((43 52,45 52,45 55,43 55,43 52))',4326))"

region <- st_read(con, query = query_crop)
plot(crop_basin(region, dem_raster))
