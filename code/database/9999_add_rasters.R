#Following guidelines 
# https://www.r-bloggers.com/2019/04/interact-with-postgis-from-r/
# https://cmhh.github.io/post/rpostgis/

source('code/source/libs.R')
source('code/source/functions.R')
source('code/source/database.R')

library(RPostgres)
library(rpostgis)
library(dplyr)
library(dbplyr)

con <- dbConnect(Postgres(), dbname = db_name,       
                 user = rstudioapi::askForPassword("Database user"),      
                 password = rstudioapi::askForPassword("Database password"))

r <- raster::raster(
  nrows = 180, ncols = 360, xmn = -180, xmx = 180,
  ymn = -90, ymx = 90, vals = 1
)

# Write Raster in the database
pgWriteRast(con, name = "test", raster = r)
pgWriteRast(con, c("hs_basins", "test"), raster = r,
            bit.depth = "2BUI", append = TRUE)

#files <- dir("/home/yannis/research/schemata/data/raw/hydrosheds/hydrosheds_dem/dem_15s_grid/eu_dem_15s", full.names = TRUE)
files <- dir("/home/yannis/research/schemata/data/raw/hydrosheds/hydrosheds_dem/dem_3s_grid/hydrosheds-57cb5ce2e4b40651d1df/n50e020_con_grid/n50e020_con/n50e020_con/", full.names = TRUE)
files <- files[grepl("w001001.adf", files)]
pgWriteRast(
    con, 
    c("hs_basins", "pilot"), 
    raster(files), 
    overwrite = TRUE
  )

les <- pgGetRast(con, c("hs_basins", "pilot"), rast = 'rast', boundary = c(53, 51, 23, 21))
plot(les)
les <- pgGetRast(con, c("hs_basins", "pilot"), rast = 'rast')
plot(les)

les <- pgGetRast(con, c("hs_basins", "test"), rast = 'rast', boundary = as_Spatial(test_basins))
library(gdalUtils)

gdalwarp(
  srcfile = "
    PG: dbname='earth' host=127.0.0.1 port=5432 
    user='yannis' password='f5821229' mode=2 
    schema='hs_basins' column='rast' 
    table='testtea'
  ",
  dstfile = "test_crop.tif",
  s_src = "EPSG:2193", 
  t_srs = "EPSG:2193",
  multi = TRUE,
  cutline = "
    PG:dbname='earth' host=127.0.0.1 port=5432 
    user='yannis' password='f5821229'
  ",
  csql = "
    select geom 
    from eu_4 
    where pfaf_id = '2251'
  ",
  crop_to_cutline = TRUE,
  dstnodata = "nodata"
)
