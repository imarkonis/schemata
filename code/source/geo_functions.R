#Gravelius compactness coefficient 

gc_estimate <- function(perimeter, area){
  return(perimeter / (2 * sqrt(pi * area)))
}

#Horton's form factor
horton_estimate <- function(length, area){
  retunr(area / length^2)
}

