#Our next hypothesis is that the impact of basin area is due to differences between precipitation and lithology heterogeneity 
#that appears below 1000 km2. To test it we estimate Moran's I for levels 5 and 7 partitioned by 11 level.

source('code/source/libs.R')
source('code/source/graphics.R')
source('code/source/experiments/exp_03.R')
#library(gtools)
library(sf)
library(spdep)
library(tmap)
library(dplyr)

#Research hypothesis: Precipitation spatial autocorrelation weakens at level 5

basins <- readRDS(paste0(data_path, 'basin_atlas_feats.rds'))

con <- dbConnect(Postgres(), dbname = db_name, host = host_ip, port = port_n,        
                 user = "yannis",      
                 password = rstudioapi::askForPassword("Database password"))

#Pilot
basins[coast == 0 & level == 4 & area > 10^11, pfaf_id]
tmap_options(check.and.fix = TRUE)
single_pfaf_id <- 1724
single_basin <- st_read(con, query = paste0("SELECT * FROM ", db_schema, ".basins_all_regions_4_11 
                                         WHERE (LEFT(pfaf_id, 4) IN ('", single_pfaf_id, "'))"))
single_basin <- single_basin %>% 
  filter(as.numeric(pfaf_id) > 10^10) %>% 
  left_join(basins, by = 'pfaf_id')

tm_shape(single_basin) + tm_polygons(style = "quantile", col = "prcp") +
  tm_legend(outside = TRUE, text.size = .8) 

tm_shape(single_basin) + tm_polygons(col = "lithology") +
  tm_legend(outside = TRUE, text.size = .8) 

tm_shape(single_basin) + tm_polygons(col = "climate") +
  tm_legend(outside = TRUE, text.size = .8) 

tm_shape(single_basin) + tm_polygons(col = "clay_pc") +
  tm_legend(outside = TRUE, text.size = .8) 

tm_shape(single_basin) + tm_polygons(col = "vegetation") +
  tm_legend(outside = TRUE, text.size = .8) 

single_pfaf_id <- 2251902
single_basin <- st_read(con, query = paste0("SELECT * FROM ", db_schema, ".basins_all_regions_4_11 
                                         WHERE (LEFT(pfaf_id, 7) IN ('", single_pfaf_id, "'))"))
single_basin <- single_basin %>% 
  filter(as.numeric(pfaf_id) > 10^10) %>% 
  left_join(basins, by = 'pfaf_id')

tm_shape(single_basin) + tm_polygons(style = "quantile", col = "prcp") +
  tm_legend(outside = TRUE, text.size = .8) 

tm_shape(single_basin) + tm_polygons(col = "lithology") +
  tm_legend(outside = TRUE, text.size = .8) 


nb <- poly2nb(single_basin, queen=TRUE)
lw <- nb2listw(nb, style="W", zero.policy=TRUE)

moran_prcp  <-  moran.mc(single_basin$prcp, lw, nsim=599,zero.policy=T) 
plot(moran_prcp, main="", las=1)

moran_lithology <-  moran.mc(as.numeric(single_basin$lithology), lw, nsim=599,zero.policy=T) 
plot(moran_lithology, main="", las=1)
