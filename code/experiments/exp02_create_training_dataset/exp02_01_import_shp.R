source('code/source/libs.R')
source('code/source/experiments/exp_02.R')
source('code/source/graphics.R')

library(RPostgres)

con <- dbConnect(Postgres(), dbname = db_name, host = host_ip, port = port_n,        
                 user = rstudioapi::askForPassword("Database user"),      
                 password = rstudioapi::askForPassword("Database password"))

all_rasters <- list.dirs(paste0(data_loc, product), full.names = F)
all_rasters <- unique(substr(all_rasters, 1, 7))
all_rasters <- all_rasters[-1]
rasters_n <- length(all_rasters)

all_rasters_n_e <- all_rasters[which(substr(all_rasters, 1, 1) == 'n' & substr(all_rasters, 4, 4) == 'e')]

raster_count <- 111
raster_lat <- as.numeric(substr(all_rasters_n_e[raster_count], 2, 3))
raster_lon <- as.numeric(substr(all_rasters_n_e[raster_count], 5, 7))

raster_coords <- paste0(raster_lon, " ", raster_lat, ",",
      raster_lon + 5, " ", raster_lat, ",",
      raster_lon + 5, " ", raster_lat + 5, ",",
      raster_lon, " ", raster_lat + 5, ",",
      raster_lon, " ", raster_lat)
coords_in_text <- paste0("('POLYGON((", raster_coords, "))',4326)")

# Crop basins and rivers in the region
#query_bas_crop <- "WITH region AS (SELECT * FROM (VALUES(1,ST_GeomFromText('POLYGON((40 50,45 50,45 55,40 55,40 50))',4326))) region (id, geom)) SELECT ST_Intersection(region.geom, st_makevalid(eu_basins.geom)) FROM region JOIN basin_boundaries.eu_basins ON ST_Intersects(region.geom, eu_basins.geom)"
query_riv_crop <- paste0("WITH region AS (SELECT * FROM (VALUES(1,ST_GeomFromText", coords_in_text, ")) region (id, geom)) SELECT ST_Intersection(region.geom, st_makevalid(eu_rivers.geom)) FROM region JOIN river_atlas.eu_rivers ON ST_Intersects(region.geom, eu_rivers.geom)")

# Get all basins that overlap the region
#query_bas_overlap <- "SELECT geom FROM hs_basins.eu_basins WHERE ST_Intersects(st_makevalid(eu_basins.geom), ST_GeomFromText('POLYGON((43 52,45 52,45 55,43 55,43 52))',4326))"
# Get basins within the region
#query_bas_within <- "SELECT * FROM hs_basins.eu_basins WHERE ST_Within(st_makevalid(eu_basins.geom), ST_GeomFromText('POLYGON((43 52,45 52,45 55,43 55,43 52))',4326))"

#region_bas <- st_read(con, query = query_bas_crop)
region_riv <- st_read(con, query = query_riv_crop)

#plot(region_bas)
plot(region_riv)

st_write(region_riv, paste0("./data/experiments/", experiment, "/riv_", region, ".shp"))
