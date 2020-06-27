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

one_river <- river_multi[3]
plot(one_river, 
     lwd = 0.5, axes = T)

river_lengths <- vector()
for(i in 1:length(river_multi)) {
  river_lengths<- c(river_lengths,
        length(river_multi[[i]]))
}
hist(river_lengths, breaks = 100)
