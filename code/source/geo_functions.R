#Gravelius compactness coefficient 

gc_estimate <- function(peri, area){
  return(peri / (2 * sqrt(pi * area)))
}