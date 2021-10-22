earth_color <- "#97B8C2"
mars_color <- "#D35C37" 
titan_color <- "#BF9A77" 
neutral_color <- "#D6C6B9"

colset_3 <- c(earth_color, mars_color, titan_color)
colset_4 <- c(earth_color, mars_color, titan_color, neutral_color)

colset_mid <- c( "#4D648D", "#337BAE", "#97B8C2",  "#739F3D", "#ACBD78",  
                 "#F4CC70", "#EBB582",  "#BF9A77",
                 "#E38B75", "#CE5A57",  "#D24136", "#785A46" )
colset_mid_qual <- colset_mid[c(11, 2, 4, 6,  1, 8, 10, 5, 7, 3, 9, 12)]
palette_mid <- colorRampPalette(colset_mid)
palette_mid_qual <- colorRampPalette(colset_mid_qual)

palette_RdBu <- colorRampPalette(rev(c('#d73027','#f46d43','#fdae61','#fee090','#fef0d9','#e0f3f8','#abd9e9','#74add1','#4575b4')), space = "rgb")
gradient_RdBu <- palette_RdBu(100)

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
