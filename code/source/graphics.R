earth_color <- "#97B8C2"
mars_color <- "#D35C37" 
titan_color <- "#BF9A77" 
neutral_color <- "#D6C6B9"

colset_3 <- c(earth_color, mars_color, titan_color)
colset_4 <- c(earth_color, mars_color, titan_color, neutral_color)

#Plots river network
plot_rivers <- function(sf_object){
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
