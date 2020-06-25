# read river data and turn into multiline 
library(sf)

data_loc <- "./data/raw/hydrosheds/GEE/"

filename <- paste0(data_loc, "river_pilot.shp")
river_pilot <- st_read(filename)  

river_multi <- st_cast(river_pilot$geometry, 
                       to = 'MULTILINESTRING', 
                       ids = river_pilot$BAS_ID)

png('results/river_pilot_test.png')
plot(river_multi, 
     col = unique(river_pilot$BAS_ID), 
     lwd = 0.5, axes = T)
dev.off()
