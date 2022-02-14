
source('code/source/libs.R')
source('code/source/functions.R')
source('code/source/geo_utils.R')
source('code/source/database.R')
source('code/source/geo_functions.R')
source('code/source/experiments/exp_05.R')

library(rgdal)
library(RPostgres)
library(data.table)
usern <- rstudioapi::askForPassword("Database user")
passwordn <- rstudioapi::askForPassword("Database password")

dsn <- paste0("PG:dbname='earth' host=localhost user=", usern," password=",passwordn," port=5432 schema='basin_dem' table='eu_dem_15s_grid' mode=2")
rasterfile_dem <- readGDAL(dsn) # Get your file as SpatialGridDataFrame
dem_raster <- raster(rasterfile_dem)

rm(list=c("usern", "passwordn", "dsn", "rasterfile_dem"))

# Find Main River 
# Plot just one river
# get dem val at a point 

con <- dbConnect(Postgres(), dbname = db_name, host = host_ip, port = port_n,        
                 user = rstudioapi::askForPassword("Database user"),      
                 password = rstudioapi::askForPassword("Database password"))

# all available river regions
schema_tables <- dbGetQuery(con, "SELECT table_name FROM information_schema.tables WHERE table_schema = 'river_atlas'") 
query_riv_allinfo <- paste0("SELECT * FROM river_atlas.", schema_tables$table_name[5])

region_rivall <- st_read(con, query = query_riv_allinfo)


dt <- data.table(region_rivall)
dt_oc <- dt[ord_clas == 1]
st <- subset(dt_oc, select = c(gid, hyriv_id, next_down, main_riv, length_km, dist_dn_km, dist_up_km, ord_clas))
st[, segments_count := nrow(.SD), main_riv]
st_sel <- st[segments_count > 100]


get_xy <- function(hyriv_id){
  print(hyriv_id)
  ext <- extent(subset(region_rivall, hyriv_id == hyriv_id))
  x <- mean(ext[1:2])
  y <- mean(ext[3:4])
  return(c(x,y))
}

xy <- mclapply(st_sel$hyriv_id, FUN = get_xy, mc.cores = cores_n)

st_sel[, extent(subset(region_rivall, hyriv_id == hyriv_id))[1:2],hyriv_id]
st_sel[, y := mean(extent(subset(region_rivall, hyriv_id == hyriv_id))[3:4]),hyriv_id]

# make mean x, y for each segment

#st_sel[, z_val:=  ]
main_river <- unique(st_sel$main_riv)
ex_dem <- extent(dem_raster)
intersect(ex_dem, region_riv_main)

main_river_sel <- main_river[1]
region_riv_main <- subset(region_rivall, hyriv_id == main_river_sel)
dem_crop <- crop_basin(region_riv_main, dem_raster)

plot(region_riv_main$geom)
plot(dem_raster)
crop_dem <- crop_basin(region_riv_main, dem_raster)
min(!is.na(crop_dem@data@values))
max(!is.na(crop_dem@data@values))