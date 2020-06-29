
library(ggplot2)
library(data.table)
library(sf)

plot_hydro_sf <- function(sf_object){
    IDs <- unique(sf_object$BAS_ID)
    num_BAS <- length(IDs)
    BAS_dat <- as.data.table(IDs)
    BAS_dat$ind <- 1:num_BAS
    river_dt <- as.data.table(sf_object)
    river_dt[, ind := BAS_dat$ind[which(BAS_ID == BAS_dat$IDs)],BAS_ID]
    cols <- rep(c('royalblue3','gold1','forestgreen','red2'), ceiling(num_BAS/5))
    return(
    ggplot(river_dt)+
           geom_sf(aes(geometry = geometry, col = ind), show.legend = FALSE)+
           theme_bw()+
           scale_color_gradientn(colours = cols)
    )
}


#Example 

data_loc <- "./data/raw/hydrosheds/GEE/"
filename <- paste0(data_loc, "river_pilot.shp")
river_pilot <- st_read(filename, quiet = T)  
p_bd <- plot_hydro_sf(river_pilot)
p_bd
