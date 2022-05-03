# 1. Read a basin from database by river/basin id or point coordinates that contains basin border, river network and dem
# 2. Plot basin border, river network and dem
# 3. Plot subbasins with labels
# 4. Plot features of subbasins

source('code/source/libs.R')
source('code/source/geo_functions.R')
source('code/source/experiments/exp_03.R')

library(RPostgres)
library(sf)
library(rgdal)

con <- dbConnect(Postgres(), dbname = db_name, host = host_ip, port = port_n,         
                 user = rstudioapi::askForPassword("Database user"),      
                 password = rstudioapi::askForPassword("Database password"))

sample_region <- regions_all[5] # Sample region is Europe
sample_pfaf_id <- 222
  
bas_borders <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.", 
                                           sample_region, "_all WHERE pfaf_id = '", sample_pfaf_id,"'"))
riv_network <- 


#Code that gets river network and basin borders and have some code for 3s dem rasters

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

raster_test <- 111
raster_lat <- as.numeric(substr(all_rasters_n_e[raster_test], 2, 3))
raster_lon <- as.numeric(substr(all_rasters_n_e[raster_test], 5, 7))

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



#Johanna's code for reading 15s raster dem

source('code/source/libs.R')
library(rgdal)

sample_region <- 'eu'
dsn <- paste0("PG:dbname='earth' host=localhost user=", rstudioapi::askForPassword("Database user"), 
              " password=", rstudioapi::askForPassword("Database password"), 
              paste0(" port=5432 schema='basin_dem' table='", sample_region, "_dem_15s_grid' mode=2"))
ras <- readGDAL(dsn) # Get your file as SpatialGridDataFrame
ras2 <- raster(ras, 1) # Convert the first Band to Raster
plot(ras2)


#Older code: Merges basins, rivers and DEMs
  
source('code/source/libs.R')
source('code/source/functions.R')
source('code/source/geo_utils.R')
source('code/source/experiments/exp_01.R')

shapefile_rivers <- paste0("./data/experiments/", experiment, "/rivers_pilot.shp")
shapefile_basins <- paste0("./data/experiments/", experiment, "/basins_pilot.shp")
raster_dem <- paste0("./data/experiments/", experiment, "/dem_pilot.tif")

rivers_sf <- st_read(shapefile_rivers)
basins_sf <- st_read(shapefile_basins)
dem_raster <- raster(raster_dem)

riv_bas_sf <- st_intersection(basins_sf[1], rivers_sf)
riv_bas_ids <- data.table(cbind(HYBAS_ID = riv_bas_sf$HYBAS_ID,
                                GOID = riv_bas_sf$GOID))
saveRDS(riv_bas_ids, paste0("./data/experiments/", experiment, "/riv_bas_id.rds"))
st_write(riv_bas_sf, paste0("./data/experiments/", experiment, "/riv_bas_pilot.shp"), append = FALSE)

riv_bas_sf <- st_read(paste0("./data/experiments/", experiment, "/riv_bas_pilot.shp"))

catchments_pilot <- import_hydrosheds_catchments(shapefile_basins, shapefile_rivers, raster_dem)
names(catchments_pilot) <- basins_sf$HYBAS_ID
saveRDS(catchments_pilot, paste0("./data/experiments/", experiment, "/catchments.rds"))

hybas_id <- 2101105040 
single_catchment <- new_hydrosheds_catchment(hybas_id, basins_sf, rivers_sf, dem_raster)
all_catchments <- catchment(basins_sf, rivers_sf, dem_raster)

#Validation plots
plot(catchments_pilot[[271]])
plot(catchments_pilot$`2101105040`)
plot(single_catchment)
