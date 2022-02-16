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

#Normalized Concavity Index
NCI <- function(z_s, z_l, z_min, z_max){
  return((z_s-z_l)/(z_max- z_min))
}

#elevation if river was a straight line
z_straight <- function(l_distance,m_straight, z_min){
  return(m_straight*l_distance+z_min)
}

#distance from min
l_distance <- function(x_min,y_min,x_l,y_l){
  return(sqrt((x_min-x_l)^2+(y_min-y_l)^2))
}

# slope of straight line
m_straight <- function(z_min,z_max,l){
    return((z_max-z_min)/l)
}