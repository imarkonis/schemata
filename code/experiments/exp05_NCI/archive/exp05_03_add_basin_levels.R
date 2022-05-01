source('code/source/libs.R')
source('code/source/geo_functions.R')
source('code/source/experiments/exp_05.R')

library(RPostgres)
library(sf)

con <- dbConnect(Postgres(), dbname = db_name, host = host_ip, port = port_n,         
                 user = rstudioapi::askForPassword("Database user"),      
                 password = rstudioapi::askForPassword("Database password"))

  
bas_borders <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.na_all"))
saveRDS(bas_borders, paste0(data_path, 'basin_borders_na.rds'))

bas_borders <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.na_12"))
saveRDS(bas_borders, paste0(data_path, '/basin_borders_na12.rds'))

bas_borders <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.na_5"))
saveRDS(bas_borders, paste0(data_path, '/basin_borders_na5.rds'))

bas_borders <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.eu_12"))
saveRDS(bas_borders, paste0(data_path, '/basin_borders_eu12.rds'))

bas_borders <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.eu_11"))
saveRDS(bas_borders, paste0(data_path, '/basin_borders_eu11.rds'))

bas_borders <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.eu_10"))
saveRDS(bas_borders, paste0(data_path, '/basin_borders_eu10.rds'))

bas_borders <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.eu_5"))
saveRDS(bas_borders, paste0(data_path, '/basin_borders_eu5.rds'))

bas_borders <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.eu_2"))
saveRDS(bas_borders, paste0(data_path, '/basin_borders_eu2.rds'))

bas_borders <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.as_1 "))
ggplot()+
  geom_sf(data = bas_borders, aes(geometry = geom), col = "purple", lwd = 2)
bas_borders <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.eu_1 "))
bas_borders2 <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.eu_2 "))
bas_borders3 <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.eu_3 "))
bas_borders4 <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.eu_4 "))
bas_borders5 <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.eu_5 "))


ggplot()+
  geom_sf(data = bas_borders, aes(geometry = geom), col = "purple", lwd = 2)+
  geom_sf(data = bas_borders2, aes(geometry = geom, fill = as.factor(pfaf_id)), col = "darkorange", lwd = 1.5)+
  geom_sf(data = bas_borders3, aes(geometry = geom), fill = NA, col = "red", alpha = 0.2)+
  geom_sf(data = bas_borders4, aes(geometry = geom), fill = NA, col = "black", alpha = 0.2)+
  theme_void()

bas_borders3_sel <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.eu_3 WHERE pfaf_id > 226 AND pfaf_id < 228"))
bas_borders4_sel <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.eu_4 WHERE pfaf_id > 2270 AND pfaf_id < 2280"))

query_riv_allinfo <- paste0("SELECT * FROM river_atlas.eu_rivers WHERE main_riv = 20498112 AND ord_clas < 4")
region_rivall <- st_read(con, query = query_riv_allinfo)
query_riv_allinfo <- paste0("SELECT * FROM river_atlas.eu_rivers WHERE main_riv = 20498112 AND ord_clas < 3 AND ord_clas > 1")
region_rivall_ord2 <- st_read(con, query = query_riv_allinfo)
#main_riv == 20498112
ggplot()+
  geom_sf(data = bas_borders3_sel, aes(geometry = geom), fill = NA, col = "black")+
  geom_sf(data = bas_borders4_sel, aes(geometry = geom, fill = as.factor(pfaf_id)), col = "black", alpha = 0.5)+
  geom_sf(data = region_rivall_ord2, aes(geometry = geom, col = ord_clas))+
  theme_void()

bas_borders5_sel <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.eu_5 WHERE pfaf_id > 22750 AND pfaf_id < 22770"))
query_riv_allinfo <- paste0("SELECT * FROM river_atlas.eu_rivers WHERE main_riv = 20498112 AND ord_clas > 2 AND ord_clas < 4")
region_rivall_ord3 <- st_read(con, query = query_riv_allinfo)

ggplot()+
  geom_sf(data = bas_borders5_sel, aes(geometry = geom, fill = as.factor(pfaf_id)), col = "black", alpha = 0.5)+
  geom_sf(data = region_rivall_ord3, aes(geometry = geom, col = ord_clas))+
  theme_void()

query_riv_allinfo <- paste0("SELECT * FROM river_atlas.eu_rivers WHERE main_riv = 20498112 AND ord_clas > 2 AND ord_clas < 4 AND hyriv_id > 2040000 AND hyriv_id < 20490000")
region_rivall_ord3 <- st_read(con, query = query_riv_allinfo)

bas_borders5_sel <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.eu_5 WHERE pfaf_id = 22768"))

test <- st_crop(region_rivall_ord3, extent(bas_borders5_sel))
ggplot()+
  geom_sf(data = bas_borders5_sel, aes(geometry = geom, fill = as.factor(pfaf_id)), col = "black", alpha = 0.5)+
  geom_sf(data = test, aes(geometry = geom, col = hyriv_id))+
  theme_void()

bas_borders7_sel <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.eu_7 WHERE pfaf_id > 2276780 AND pfaf_id < 2276900"))
query_riv_allinfo <- paste0("SELECT * FROM river_atlas.eu_rivers WHERE main_riv = 20498112 AND ord_clas > 3 AND ord_clas < 5 AND hyriv_id > 2040000 AND hyriv_id < 20490000")
region_rivall_ord4 <- st_read(con, query = query_riv_allinfo)
test <- st_crop(region_rivall_ord4, extent(bas_borders7_sel))

ggplot()+
  geom_sf(data = bas_borders7_sel, aes(geometry = geom, fill = as.factor(pfaf_id)), col = "black", alpha = 0.5)+
  geom_sf(data = test, aes(geometry = geom, col = hyriv_id))+
  theme_void()

bas_borders8_sel <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.eu_8 WHERE pfaf_id > 22768059 AND pfaf_id < 22768070"))
query_riv_allinfo <- paste0("SELECT * FROM river_atlas.eu_rivers WHERE main_riv = 20498112 AND ord_clas > 4 AND ord_clas < 6 AND hyriv_id > 2040000 AND hyriv_id < 20490000 AND hybas_l12 = 2120458870")
region_rivall_ord5 <- st_read(con, query = query_riv_allinfo)
test <- st_crop(region_rivall_ord5, extent(bas_borders8_sel))

ggplot()+
  geom_sf(data = bas_borders8_sel, aes(geometry = geom, fill = as.factor(pfaf_id)), col = "black", alpha = 0.5)+
  geom_sf(data = test, aes(geometry = geom, col = as.factor(hyriv_id)))+
  theme_void()

bas_borders9_sel <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.eu_9 WHERE pfaf_id > 227680679 AND pfaf_id < 227680690"))
test <- st_crop(region_rivall_ord5, extent(bas_borders9_sel))

ggplot()+
  geom_sf(data = bas_borders8_sel, aes(geometry = geom, fill = as.factor(pfaf_id)), col = "black", alpha = 0.5)+
  geom_sf(data = test, aes(geometry = geom, col = as.factor(hyriv_id)))+
  theme_void()


bas_borders10_sel <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.eu_10 WHERE pfaf_id > 2276806799 AND pfaf_id < 2276806900"))
query_riv_allinfo <- paste0("SELECT * FROM river_atlas.eu_rivers WHERE main_riv = 20498112 AND ord_clas > 5 AND ord_clas < 7 AND hyriv_id > 2040000 AND hyriv_id < 20490000")
region_rivall_ord6 <- st_read(con, query = query_riv_allinfo)
test <- st_crop(region_rivall_ord6, extent(bas_borders10_sel))

ggplot()+
  geom_sf(data = bas_borders10_sel, aes(geometry = geom, fill = as.factor(pfaf_id)), col = "black", alpha = 0.5)+
  geom_sf(data = test, aes(geometry = geom, col = as.factor(hyriv_id)))+
  theme_void()

bas_borders11_sel <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.eu_11 WHERE pfaf_id > 22768067999 AND pfaf_id < 22768069000"))
bas_borders12_sel <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.eu_12 WHERE pfaf_id > 227680679999 AND pfaf_id < 227680690000"))

query_riv_allinfo <- paste0("SELECT * FROM river_atlas.eu_rivers WHERE main_riv = 20498112 AND ord_clas > 5 AND ord_clas < 7 AND hyriv_id > 2040000 AND hyriv_id < 20490000")
region_rivall_ord6 <- st_read(con, query = query_riv_allinfo)
test <- st_crop(region_rivall_ord6, extent(bas_borders10_sel))

ggplot()+
  geom_sf(data = bas_borders10_sel, aes(geometry = geom, fill = as.factor(pfaf_id)), col = "black", alpha = 0.5)+
  geom_sf(data = test, aes(geometry = geom, col = as.factor(hyriv_id)))+
  theme_void()

bas_borders4_sel <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.eu_4 WHERE pfaf_id > 2299 AND pfaf_id < 2400"))

ggplot()+
  geom_sf(data = bas_borders4_sel, aes(geometry = geom, fill = as.factor(pfaf_id)), col = "black", alpha = 0.2)+
  theme_void()


bas_borders5_sel <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.eu_5 WHERE pfaf_id > 23290 AND pfaf_id < 23310"))

ggplot()+
  geom_sf(data = bas_borders5_sel, aes(geometry = geom, fill = as.factor(pfaf_id)), col = "black", alpha = 0.2)+
  theme_void()


bas_borders5_sel <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.eu_5 WHERE pfaf_id > 23239 AND pfaf_id < 23250"))

ggplot()+
  geom_sf(data = bas_borders5_sel, aes(geometry = geom, fill = as.factor(pfaf_id)), col = "black", alpha = 0.2)+
  theme_void()
schema_tables_basins <- dbGetQuery(con, "SELECT table_name FROM information_schema.tables WHERE table_schema = 'basin_boundaries'") 


bas_borders6_sel <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.eu_6 WHERE pfaf_id > 232390 AND pfaf_id < 232500"))

ggplot()+
  geom_sf(data = bas_borders6_sel, aes(geometry = geom, fill = as.factor(pfaf_id)), col = "black", alpha = 0.2)+
  theme_void()

bas_5 <- dbGetQuery(con, paste0("SELECT COUNT(pfaf_id) FROM basin_boundaries.eu_5 WHERE hybas_id <> main_bas"))
bas_4 <- dbGetQuery(con, paste0("SELECT COUNT(pfaf_id) FROM basin_boundaries.eu_4 WHERE hybas_id <> main_bas"))
bas_3 <- dbGetQuery(con, paste0("SELECT COUNT(pfaf_id) FROM basin_boundaries.eu_3 WHERE hybas_id <> main_bas"))

schema_tables_basins <- dbGetQuery(con, "SELECT table_name FROM information_schema.tables WHERE table_schema = 'basin_boundaries'") 

regions <- c("af", "as", "na", "au", "eu", "sa", "gr", "ar")

for(i in regions){
  tmp <- dbGetQuery(con, paste0("SELECT COUNT(pfaf_id) FROM basin_boundaries.",i,"_6 WHERE hybas_id <> main_bas"))
  print(i)
  print(tmp)
}

dta <- as.data.frame(matrix(nrow = 12, ncol = 2))
names(dta) <- c("hybas_level", "basin_count")
dta_detailed <- as.data.frame(matrix(nrow = 12, ncol = 9))
names(dta_detailed) <- c("hybas_level", regions)
dta_detailed$hybas_level<- 1:12

for(level in 1:12){
  sum <- 0
  print(level)
  for(i in 1:length(regions)){
    tmp <- dbGetQuery(con, paste0("SELECT COUNT(DISTINCT hybas_id) FROM basin_boundaries.", regions[i], "_", level))
    print(regions[i])
    print(tmp)
    dta_detailed[level,i+1] <- as.character(tmp$count)
    sum <- sum + tmp
  }
  print(level)
  print(sum)
  dta$hybas_level[level] <- level
  dta$basin_count[level] <- as.character(sum$count)
}

dta_detailed_coast <- as.data.frame(matrix(nrow = 12, ncol = 9))
names(dta_detailed_coast) <- c("hybas_level", regions)
dta_detailed_coast$hybas_level <- 1:12

for(level in 1:12){
  print(level)
  for(i in 1:length(regions)){
    tmp <- dbGetQuery(con, paste0("SELECT COUNT(DISTINCT hybas_id) FROM basin_boundaries.", regions[i], "_", level, " WHERE coast = 0"))
    print(regions[i])
    print(tmp)
    dta_detailed_coast[level,i+1] <- as.character(tmp$count)
  }
}

dta_detailed_bas<- as.data.frame(matrix(nrow = 12, ncol = 9))
names(dta_detailed_bas) <- c("hybas_level", regions)
dta_detailed_bas$hybas_level <- 1:12

for(level in 1:12){
  print(level)
  for(i in 1:length(regions)){
    tmp <- dbGetQuery(con, paste0("SELECT COUNT(DISTINCT hybas_id) FROM basin_boundaries.", regions[i], "_", level, " WHERE hybas_id <> main_bas"))
    print(regions[i])
    print(tmp)
    dta_detailed_bas[level,i+1] <- as.character(tmp$count)
  }
}


dta_detailed_main_bas<- as.data.frame(matrix(nrow = 12, ncol = 9))
names(dta_detailed_main_bas) <- c("hybas_level", regions)
dta_detailed_main_bas$hybas_level <- 1:12

for(level in 1:12){
  print(level)
  for(i in 1:length(regions)){
    tmp <- dbGetQuery(con, paste0("SELECT COUNT(DISTINCT main_bas) FROM basin_boundaries.", regions[i], "_", level))
    print(regions[i])
    print(tmp)
    dta_detailed_main_bas[level,i+1] <- as.character(tmp$count)
  }
}

bas_borders_l10 <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.sa_10 WHERE pfaf_id < 6537500202 and pfaf_id > 6537500199"))
bas_borders_l9 <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.sa_9 WHERE pfaf_id = 653750020"))


ggplot()+
  geom_sf(data = bas_borders_l10, aes(geometry = geom, fill = as.factor(pfaf_id)))+
  geom_sf(data = bas_borders_l9, aes(geometry = geom, fill = as.factor(pfaf_id)), col = "black", alpha = 0.2, lwd = 2)+
  theme_void()

bas_borders_l10 <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.sa_10 WHERE pfaf_id < 6537500201 and pfaf_id > 6537500199"))

ggplot()+
  geom_sf(data = bas_borders_l9, aes(geometry = geom, fill = as.factor(pfaf_id)), col = "black", lwd = 2)+
  geom_sf(data = bas_borders_l10, aes(geometry = geom, fill = as.factor(pfaf_id)))+
  theme_void()

bas_borders_l8 <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.sa_8 WHERE pfaf_id = 65322402"))
bas_borders_l9 <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.sa_9 WHERE pfaf_id > 653224019 AND pfaf_id < 653224030"))

ggplot()+
  geom_sf(data = bas_borders_l8, aes(geometry = geom, fill = as.factor(pfaf_id)), col = "black", lwd = 2)+
  geom_sf(data = bas_borders_l9, aes(geometry = geom, fill = as.factor(pfaf_id)))+
  theme_void()

bas_borders_l8 <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.sa_8 WHERE pfaf_id = 65322402"))
bas_borders_l9 <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.sa_9 WHERE pfaf_id = 653224020"))

ggplot()+
  geom_sf(data = bas_borders_l8, aes(geometry = geom, fill = as.factor(pfaf_id)), col = "black", lwd = 2)+
  geom_sf(data = bas_borders_l9, aes(geometry = geom, fill = as.factor(pfaf_id)))+
  theme_void()
