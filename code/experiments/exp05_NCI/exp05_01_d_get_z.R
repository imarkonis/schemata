source('code/source/libs.R')
source('code/source/experiments/exp_05.R')
source('code/source/database_dem.R')

library('rgdal')
options(scipen = 15)
regions <- c("af", "as", "na", "au", "eu", "sa_n", "sa_s", "si")

fnames <- list.files(path = data_path, pattern = "_xy.rds")
for(i in fnames){
  st <- readRDS(paste0(data_path,"/",i))
  print(paste("read", i))
  if(i == "na_xy.rds"){
    dem_select <- c("na_dem_15s_grid", "ca_dem_15s_grid")
  }
  if(i == "af_xy.rds"){
    dem_select <- c("af_dem_15s_grid")
  }
  if(i == "as_xy.rds"){
    dem_select <- c("as_dem_15s_grid", "eu_dem_15s_grid")
  }
  if(i == "au_xy.rds"){
    dem_select <- c("au_dem_15s_grid", "as_dem_15s_grid")
  }
  if(i == "eu_xy.rds"){
    dem_select <- c("eu_dem_15s_grid", "as_dem_15s_grid")
  }
  if(i == "sa_n_xy.rds"){
    dem_select <- c("sa_dem_15s_grid", "ca_dem_15s_grid")
  }
  if(i == "sa_s_xy.rds"){
    dem_select <- c("sa_dem_15s_grid", "ca_dem_15s_grid")
  }
  if(i == "si_xy.rds"){
    dem_select <- c("as_dem_15s_grid", "eu_dem_15s_grid")
  }
  
  for(dem_id in 1:length(dem_select)){
    dsn <- paste0("PG:dbname='earth' host='192.168.64.4' user=", username," password=",pn," port=5432 schema='basin_dem' table='",dem_select[dem_id],"' mode=2")
#    dsn <- paste0("PG:dbname='earth' host=localhost user=", usern," password=",pn," port=5432 schema='basin_dem' table='",dem_select[dem_id],"' mode=2")
    rasterfile_dem <- readGDAL(dsn) # Get your file as SpatialGridDataFrame
    dem_raster <- raster(rasterfile_dem)
    if(dem_id == 1){
      print("first dem")
      sp_points <-   SpatialPoints(cbind(st$X, st$Y))
      z <- extract(x = dem_raster, y = sp_points)
      st$z = z
    }else{
      print("second dem")
      points_na <- sp_points[which(is.na(st$z))]
      z_2 <- extract(x = dem_raster, y = points_na)
      st[which(is.na(st$z)),]$z = z_2
    }
  }
  print("done")
  saveRDS(st, paste0(data_path, "/z_",i))
  rm(st)
  rm(dem_raster)
  rm(rasterfile_dem)
  rm(sp_points)
  gc()
}

