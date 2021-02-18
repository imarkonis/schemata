#Perimeter-area ratio index
par_index <- function(perimeter, area){
  return(perimeter / area)
}

#Gravelius compactness coefficient 
gc_coef <- function(perimeter, area){
  return(perimeter / (2 * sqrt(pi * area)))
}

#Fractal dimension index
fractal_dim <- function(perimeter, area){
  return(2 * log(perimeter) / log(area))
}

#Horton's form factor
horton_form <- function(length, area){
  return(area / length^2)
}