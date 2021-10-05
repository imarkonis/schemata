source('code/source/libs.R')
source('code/source/functions.R')
source('code/source/geo_utils.R')
source('code/source/database.R')

library(RPostgres)

rasterfile_dem <- paste0(basin_dem_path, "w001001.adf") #DEMs cannot be imported in database yet
dem_raster <- raster(rasterfile_dem)

con <- dbConnect(Postgres(), dbname = db_name, host = host_ip, port = port_n,        
                 user = rstudioapi::askForPassword("Database user"),      
                 password = rstudioapi::askForPassword("Database password"))

# Crop basins and rivers in the region
query_bas_crop <- "WITH region AS (SELECT * FROM (VALUES(1,ST_GeomFromText('POLYGON((19 35,28 35,28 42,19 42,19 35))',4326))) Region (id, geom)) SELECT ST_Intersection(region.geom, st_makevalid(eu_basins.geom)) FROM region JOIN basin_boundaries.eu_basins ON ST_Intersects(region.geom, eu_basins.geom)"
query_riv_crop <- "WITH region AS (SELECT * FROM (VALUES(1,ST_GeomFromText('POLYGON((19 35,28 35,28 42,19 42,19 35))',4326))) Region (hyriv_id, geom)) SELECT ST_Intersection(region.geom, st_makevalid(eu_rivers.geom)) FROM region JOIN river_atlas.eu_rivers ON ST_Intersects(region.geom, eu_rivers.geom)"

# Get all basins that overlap the region
query_bas_overlap <- "SELECT geom FROM hs_basins.eu_basins WHERE ST_Intersects(st_makevalid(eu_basins.geom), ST_GeomFromText('POLYGON((43 52,45 52,45 55,43 55,43 52))',4326))"
# Get basins within the region
query_bas_within <- "SELECT * FROM hs_basins.eu_basins WHERE ST_Within(st_makevalid(eu_basins.geom), ST_GeomFromText('POLYGON((43 52,45 52,45 55,43 55,43 52))',4326))"

region_bas <- st_read(con, query = query_bas_crop)
region_riv <- st_read(con, query = query_riv_crop)

plot(region_bas)
plot(region_riv)
plot(crop_basin(region_bas, dem_raster))
