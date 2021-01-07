#' This function calculates the relative hyposometric curve and should be almost identical to the function found in hydroTSM package
#' 
#' 
#' @param x SpatialGridDataframe as input for the calculation of the hypsometric curve
#' @param band band to be used for hypsometric curve

hypso_rel <- function (x, 
                       band = 1) 
{
  if (class(x) != "SpatialGridDataFrame") 
    stop("Invalid argument: 'class(x)' must be 'SpatialGridDataFrame'")
  band.error <- FALSE
  if (is.numeric(band) | is.integer(band)) {
    if ((band < 1) | (band > length(colnames(x@data)))) 
      band.error <- TRUE
  }
  else if (is.character(band)) 
    if (!(band %in% colnames(x@data))) 
      band.error <- TRUE
  if (band.error) 
    stop("Invalid argument: 'band' does not exist in 'x' !")
  mydem <- x@data[band][, 1]
  mydem <- mydem[mydem > 0]
  z.min <- min(mydem, na.rm = TRUE)
  z.mean <- mean(mydem, na.rm = TRUE)
  z.max <- max(mydem, na.rm = TRUE)
  x.dim <- x@grid@cellsize[1]
  y.dim <- x@grid@cellsize[2]
  max.area <- length(which(!is.na(mydem))) * x.dim * y.dim
  # following taken form plot.stepfun used in hydroTSm
  x <- ecdf(as.matrix(mydem))
  knF <- knots(x)
  xval <- knF
  rx <- range(xval)
  dr <- if (length(xval) > 1L) 
          max(0.08 * diff(rx), median(diff(xval)))
        else abs(xval)/16
  xlim <- rx + dr * c(-1, 1)
  xval <- xval[xlim[1L] - dr <= xval & xval <= xlim[2L] + dr]
  ti <- c(xlim[1L] - dr, xval, xlim[2L] + dr)
  ti.l <- ti[-length(ti)]
  ti.r <- ti[-1L]
  y <- x(0.5 * (ti.l + ti.r))
  res <- list(t = ti, y = y)
  relative.area <- (1 - res$y[-1])
  relative.elev <- (res$t[-c(1, length(res$t))] - z.min)/(z.max - z.min)
  if(length(relative.area) > 1000){
    id_sel <- seq(1, length(relative.area), length.out = 1000)
    relative.area <- relative.area[id_sel]
    relative.elev <- relative.elev[id_sel]
  }   
  return(cbind(relative.area,relative.elev))
  }

