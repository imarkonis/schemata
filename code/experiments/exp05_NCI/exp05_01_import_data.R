
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
#save(dem_raster, file = "dem_raster.Rdata")
#load("dem_raster.Rdata")
rm(list=c("usern", "passwordn", "dsn", "rasterfile_dem"))


con <- dbConnect(Postgres(), dbname = db_name, host = host_ip, port = port_n,        
                 user = rstudioapi::askForPassword("Database user"),      
                 password = rstudioapi::askForPassword("Database password"))

# all available river regions
schema_tables <- dbGetQuery(con, "SELECT table_name FROM information_schema.tables WHERE table_schema = 'river_atlas'") 
query_riv_allinfo <- paste0("SELECT * FROM river_atlas.", schema_tables$table_name[5])

region_rivall <- st_read(con, query = query_riv_allinfo)
#save(region_rivall, file = "region_rivall.Rdata")
#load("region_rivall.Rdata")

dt <- data.table(region_rivall)
dt_oc <- dt[ord_clas == 1]
st <- subset(dt_oc, select = c(gid, hyriv_id, next_down, main_riv, length_km, dist_dn_km, dist_up_km, ord_clas, hybas_l12))
st[, segments_count := nrow(.SD), main_riv]
st_sel <- st[segments_count > 100]


hyriv_ids <- st_sel$hyriv_id 

if(.Platform$OS.type == "unix") { 
  river_xyz <- mclapply(hyriv_ids, FUN = get_xyz, mc.cores = cores_n)
} else {
  river_xyz <- mclapply(hyriv_ids, FUN = get_xyz, mc.cores = 1)
 }

river_xyz_dt<- as.data.table(do.call(rbind, river_xyz))

saveRDS(river_xyz_dt, paste0(data_path, '/',schema_tables$table_name[5],'_river_xyz.rds'))
