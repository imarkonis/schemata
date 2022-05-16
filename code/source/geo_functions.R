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
vert_deviation <- function(z_s, z_l, zend, zbeg){
  # z_l is actual z at location l
  # z_s is z on the straight line
  return((z_l-z_s)/(zbeg- zend))
}

#elevation if river was a straight line
z_straight <- function(l_distance,m_straight, zbeg){
  return(m_straight*l_distance+zbeg)
}


# slope of straight line
m_straight <- function(zend,zbeg,l){
    return((zend-zbeg)/l)
}