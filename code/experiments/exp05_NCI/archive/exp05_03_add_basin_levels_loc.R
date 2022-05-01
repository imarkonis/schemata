source('code/source/libs.R')
source('code/source/geo_functions.R')
source('code/source/experiments/exp_05.R')

library(sf)
library(ggplot2)
library(RColorBrewer)



eu_bas_l12 <- readRDS(paste0(data_path, '/basin_borders_eu12.rds'))
eu_bas_l12 <- as.data.table(eu_bas_l12)
eu_bas_l12[nchar(hybas_id) == 9, hybas_id_short := substr(hybas_id, 3, 9)]
eu_bas_l12[nchar(hybas_id) == 10, hybas_id_short := substr(hybas_id, 4, 10)]
eu_bas_l5 <- readRDS(paste0(data_path, '/basin_borders_eu5.rds'))

eu_rivers <- readRDS(paste0(results_path, '/eu_rivers_xyz_NCI_all.rds'))
eu_rivers[,hybas_id_short := substr(hybas_l12, 4, 10)]
eu_rivers[,NCI_alt := median(v_dev), hybas_l12]

eu_main_rivers <- eu_rivers[!duplicated(main_riv),.(hybas_l12)]

eu_rivers[,NCI_hyb := mean(NCI_alt, na.rm = T), hybas_l12]
eu_rivers_NCI_hyb <- eu_rivers[!duplicated(hybas_l12)]

eu_merged_l12 <- merge(eu_bas_l12, eu_rivers_NCI_hyb, by.x = 'hybas_id_short', by.y = "hybas_id_short")

eu_merged_l12$pfaf_id_l5 <- as.integer(substr(eu_merged_l12$pfaf_id,1,5))

eu_merged_l12_dt <- data.table(eu_merged_l12)

eu_nci_l5_dt <- eu_merged_l12_dt[,.(mean(NCI_alt, na.rm = T), X, Y), .(pfaf_id_l5)]
names(eu_nci_l5_dt)[2] <- "NCI"

eu_nci_l5_dt_dup <- eu_nci_l5_dt[!duplicated(pfaf_id_l5)]
eu_merged_l5 <- merge(eu_bas_l5, eu_nci_l5_dt_dup, by.x = 'pfaf_id', by.y = "pfaf_id_l5")

eu_bas_l12$pfaf_id_l5 <- as.integer(substr(eu_bas_l12$pfaf_id,1,5))

eu_bas_l12_dt <- data.table(eu_bas_l12)
eu_bas_l12_coord <- st_coordinates(eu_bas_l12)
eu_bas_w_coords <- merge(eu_bas_l12, eu_bas_l12_coord, by.x = "gid", by.y = "L3", all.y = T)

eu_bas_l12_dt <- eu_bas_w_coords[!duplicated(eu_bas_w_coords$pfaf_id_l5),]
eu_bas_l12_dt <- data.table(eu_bas_l12_dt)
eu_bas_l12_dt <- subset(eu_bas_l12_dt, select = c(pfaf_id_l5, hybas_id, X, Y))

eu_bas_merged_l5 <- merge(eu_bas_l5, eu_bas_l12_dt, by.x = 'pfaf_id', by.y = "pfaf_id_l5")

# eu river
library(RPostgres)
con <- dbConnect(Postgres(), dbname = db_name, host = host_ip, port = port_n,        
                 user = rstudioapi::askForPassword("Database user"),      
                 password = rstudioapi::askForPassword("Database password"))


query_riv_allinfo <- paste0("SELECT * FROM river_atlas.eu_rivers")
region_rivall <- st_read(con, query = query_riv_allinfo)


ggplot()+
  geom_sf(data = region_rivall, aes(geometry = geom, col = ord_clas))+
  theme_void()

ggplot()+
  geom_sf(data = region_rivall, aes(geometry = geom, col = main_riv))+
  theme_void()

ggplot()+
  geom_sf(data = region_rivall, aes(geometry = geom, col = hybas_l12))+
  theme_void()

ggplot()+
  geom_point(data = eu_rivers_NCI_hyb, aes(x = X, y = Y, col = z_av))+
  theme_void()

ggplot()+
  geom_point(data = eu_rivers_NCI_hyb, aes(x = X, y = Y, col = l_max))+
  theme_void()

ggplot()+
  geom_point(data = eu_rivers_NCI_hyb, aes(x = X, y = Y, col = zmin))+
  theme_void()

ggplot()+
  geom_point(data = eu_rivers_NCI_hyb, aes(x = X, y = Y, col = zmax))+
  theme_void()

ggplot()+
  geom_point(data = eu_rivers_NCI_hyb, aes(x = X, y = Y, col = m))+
  theme_void()

ggplot()+
  geom_point(data = eu_rivers_NCI_hyb, aes(x = X, y = Y, col = z_s))+
  theme_void()

ggplot()+
  geom_point(data = eu_rivers_NCI_hyb, aes(x = X, y = Y, col = v_dev))+
  theme_void()

ggplot()+
  geom_point(data = eu_rivers_NCI_hyb, aes(x = X, y = Y, col = NCI))+
  theme_void()

ggplot()+
  geom_point(data = eu_rivers_NCI_hyb, aes(x = X, y = Y, col = NCI_hyb))+
  theme_void()


ggplot()+
  geom_point(data = eu_rivers_NCI_hyb, aes(x = X, y = Y, col = NCI_hyb))+
  geom_point(data = eu_rivers_NCI_hyb[main_riv == 20490321], aes(x = X, y = Y), col = "red")+
  geom_point(data = eu_rivers_NCI_hyb[main_riv == 20498112], aes(x = X, y = Y), col = "blue")+
  theme_void()


ggplot()+
  geom_sf(data = eu_bas_l5, aes(geometry = geom))+
  geom_point(data = eu_rivers_NCI_hyb[ord_clas == 12], aes(x = X, y = Y, col = main_riv))+
  theme_void()


ggplot()+
  geom_sf(data = eu_merged_l12, aes(geometry = geom, fill = NCI_hyb))+
  scale_fill_gradient2(low  = "yellow", mid = "white",high = "darkblue", midpoint = 0)+
  theme_void()


ggplot()+
  geom_sf(data = eu_merged_l5, aes(geometry = geometry, fill = NCI))+
  scale_fill_gradient2(low  = "orange", mid = "white",high = "darkblue", midpoint = 0)+
  theme_void()


ggplot()+
  geom_point(data = eu_rivers, aes(color = NCI, x = X, y = Y))+
  scale_color_gradient2(low  = "yellow", mid = "white",high = "darkblue", midpoint = 0)+
  theme_void()



