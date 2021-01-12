library(ggplot2)
library(data.table)
library(sf)

plot_BAS_IDs <- function(BAS_IDs, shape_file){
  data_loc <- "./data/raw/hydrosheds/GEE/"
  filename <- paste0(data_loc, shape_file)
  river_pilot <- st_read(filename, quiet = T)  
  river_dt <- as.data.table(river_pilot)
  data_has_BAS <- all(BAS_IDs %in% river_dt$BAS_ID)
  if(!data_has_BAS){
    available_BAS <- which(BAS_IDs %in% river_dt$BAS_ID)
    print(paste('BAS_ID', BAS_IDs[-available_BAS], 'not available'))
  }
  river_dt_sel_BAS <-  river_dt[BAS_ID %in% BAS_IDs,]
  
  return(ggplot(river_dt_sel_BAS)+
    geom_sf(aes(geometry = geometry))+
    facet_wrap(~BAS_ID)+
    theme_bw())
}


#Example 
shape_file <- "river_pilot.shp"
BAS_IDs <- c(2583824, 2558949)
pBI <- plot_BAS_IDs(BAS_IDs = BAS_IDs, shape_file)
