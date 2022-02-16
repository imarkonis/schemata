
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

con <- dbConnect(Postgres(), dbname = db_name, host = host_ip, port = port_n,        
                 user = rstudioapi::askForPassword("Database user"),      
                 password = rstudioapi::askForPassword("Database password"))


#con <- dbConnect(Postgres(), dbname = db_name, host = host_ip, port = port_n,        
#                 user = usern,      
#                 password = passwordn)


schema_tables_dem <- dbGetQuery(con, "SELECT table_name FROM information_schema.tables WHERE table_schema = 'basin_dem'") 
schema_tables_rivers <- dbGetQuery(con, "SELECT table_name FROM information_schema.tables WHERE table_schema = 'river_atlas'") 

for(i in 1:length(schema_tables_rivers$table_name)){
#for(i in 5){
  query_riv_allinfo <- paste0("SELECT * FROM river_atlas.", schema_tables_rivers$table_name[i])
  region_rivall <- st_read(con, query = query_riv_allinfo)
  
  if(schema_tables_rivers$table_name[i] == "na_rivers"){
    dem_select <- c("na_dem_15s_grid", "ca_dem_15s_grid", "sa_dem_15s_grid")
  }
  if(schema_tables_rivers$table_name[i] == "af_rivers"){
    dem_select <- c("af_dem_15s_grid", "eu_dem_15s_grid")
  }
  if(schema_tables_rivers$table_name[i] == "as_rivers"){
    dem_select <- c("as_dem_15s_grid", "eu_dem_15s_grid")
  }
  if(schema_tables_rivers$table_name[i] == "au_rivers"){
    dem_select <- c("au_dem_15s_grid", "as_dem_15s_grid")
  }
  if(schema_tables_rivers$table_name[i] == "eu_rivers"){
    dem_select <- c("eu_dem_15s_grid", "af_dem_15s_grid", "as_dem_15s_grid")
  }
  if(schema_tables_rivers$table_name[i] == "sa_n_rivers"){
    dem_select <- c("sa_dem_15s_grid", "ca_dem_15s_grid")
  }
  if(schema_tables_rivers$table_name[i] == "sa_s_rivers"){
    dem_select <- c("sa_dem_15s_grid", "ca_dem_15s_grid")
  }
  if(schema_tables_rivers$table_name[i] == "si_rivers"){
    dem_select <- c("as_dem_15s_grid", "eu_dem_15s_grid")
  }
  dt <- data.table(region_rivall)
  dt_oc <- dt[ord_clas == 1]
  st <- subset(dt_oc, select = c(gid, hyriv_id, next_down, main_riv, length_km, dist_dn_km, dist_up_km, ord_clas, hybas_l12))
  st[, segments_count := nrow(.SD), main_riv]
  st_sel <- st[segments_count > 100]
  
  for(dem_id in 1:length(dem_select)){
    dsn <- paste0("PG:dbname='earth' host=localhost user=", usern," password=",passwordn," port=5432 schema='basin_dem' table='",dem_select[dem_id],"' mode=2")
    rasterfile_dem <- readGDAL(dsn) # Get your file as SpatialGridDataFrame
    dem_raster <- raster(rasterfile_dem)
    
    if(dem_id == 1){
      hyriv_ids <- st_sel$hyriv_id 
      hyriv_ids_n <- length(hyriv_ids)
      hyriv_ids_seq <- c(seq(1, hyriv_ids_n, 10000), hyriv_ids_n)
      for(ids in 1:(length(hyriv_ids_seq)-1)){
        if(.Platform$OS.type == "unix") { 
          river_xyz <- mclapply(hyriv_ids[hyriv_ids_seq[ids]:hyriv_ids_seq[ids+1]], FUN = get_xyz, mc.cores = cores_n-2)
        } else {
          river_xyz <- mclapply(hyriv_ids[hyriv_ids_seq[ids]:hyriv_ids_seq[ids+1]], FUN = get_xyz, mc.cores = 1)
        }
        river_xyz_temp<- as.data.table(do.call(rbind, river_xyz))
        
        if(ids == 1){
          river_xyz_dt <- river_xyz_temp
        }else{
          river_xyz_dt <- rbind(river_xyz_dt, river_xyz_temp)
        }
      }
    }else{
      hyriv_ids <- river_xyz_dt[is.na(z)]$hyriv_id 
      hyriv_ids_n <- length(hyriv_ids)
      hyriv_ids_seq <- c(seq(1, hyriv_ids_n, 10000), hyriv_ids_n)
      for(ids in 1:(length(hyriv_ids_seq)-1)){
        if(.Platform$OS.type == "unix") { 
          river_xyz <- mclapply(hyriv_ids[hyriv_ids_seq[ids]:hyriv_ids_seq[ids+1]], FUN = get_xyz, mc.cores = cores_n-2)
        } else {
          river_xyz <- mclapply(hyriv_ids[hyriv_ids_seq[ids]:hyriv_ids_seq[ids+1]], FUN = get_xyz, mc.cores = 1)
        }
        river_xyz_temp<- as.data.table(do.call(rbind, river_xyz))
        river_xyz_dt <- rbind(river_xyz_dt, river_xyz_temp)
      }
    }
  }
  
  river_xyz_dt <- river_xyz_dt[!is.na(z)]
  
  saveRDS(river_xyz_dt, paste0(data_path, '/',schema_tables_rivers$table_name[i],'_xyz.rds'))
}

