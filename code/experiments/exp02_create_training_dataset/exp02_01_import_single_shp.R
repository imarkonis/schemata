source('code/source/libs.R')
source('code/source/experiments/exp_02.R')
source('code/source/graphics.R')

library(RPostgres)

con <- dbConnect(Postgres(), dbname = db_name, host = host_ip, port = port_n,        
                 user = rstudioapi::askForPassword("Database user"),      
                 password = rstudioapi::askForPassword("Database password"))

# Crop basins and rivers in the region
query_bas_crop <- "WITH region AS (SELECT * FROM (VALUES(1,ST_GeomFromText('POLYGON((40 50,45 50,45 55,40 55,40 50))',4326))) region (id, geom)) SELECT ST_Intersection(region.geom, st_makevalid(eu_basins.geom)) FROM region JOIN basin_boundaries.eu_basins ON ST_Intersects(region.geom, eu_basins.geom)"
query_riv_crop <- "WITH region AS (SELECT * FROM (VALUES(1,ST_GeomFromText('POLYGON((40 50,45 50,45 55,40 55,40 50))',4326))) region (id, geom)) SELECT ST_Intersection(region.geom, st_makevalid(eu_rivers.geom)) FROM region JOIN river_atlas.eu_rivers ON ST_Intersects(region.geom, eu_rivers.geom)"

# Get all basins that overlap the region
query_bas_overlap <- "SELECT geom FROM hs_basins.eu_basins WHERE ST_Intersects(st_makevalid(eu_basins.geom), ST_GeomFromText('POLYGON((43 52,45 52,45 55,43 55,43 52))',4326))"
# Get basins within the region
query_bas_within <- "SELECT * FROM hs_basins.eu_basins WHERE ST_Within(st_makevalid(eu_basins.geom), ST_GeomFromText('POLYGON((43 52,45 52,45 55,43 55,43 52))',4326))"

region_bas <- st_read(con, query = query_bas_crop)
region_riv <- st_read(con, query = query_riv_crop)

plot(region_bas)
plot(region_riv)

st_write(region_riv, paste0("./data/experiments/", experiment, "/riv_", region, ".shp"))
