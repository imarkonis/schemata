#' This function calculates the relative hyposometric curve and should be almost identical to the function found in hydroTSM package
#' 
#' 
#' @param x SpatialGridDataframe as input for the calculation of the hypsometric curve
#' @param band band to be used for hypsometric curve
#' @param main character for the title of the figure
#' @param xlab character lable for x-axis
#' @param ylab character lable for y-axis
#' @param col color of the curve
#' @param fname name of the csv file, only saves data if !NULL
#' @param figname character is the desired output name (character) of the pdf for the hyposometric curve. Only saves pdf if, only saves data if !NULL

my_hypso_rel <- function (x, 
                          band = 1, 
                          main = "Hypsometric Curve", 
                          xlab = "Relative Area above Elevation, (a/A)",
                          ylab = "Relative Elevation, (h/H)",
                          col = "blue", 
                          fname = NULL,
                          figname = NULL, ...) 
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
  res <- plot.stepfun(ecdf(as.matrix(mydem)), lwd = 0, cex.points = 0)
  z.median.index <- which(round(res$y, 3) == 0.5)[1]
  z.median <- res$t[z.median.index]
  if (is.na(z.median)) {
    z.median.index <- which(round(res$y, 2) == 0.5)[1]
    z.median <- res$t[z.median.index]
  }
  else if (is.na(z.median)) {
    z.median <- median(mydem, na.rm = TRUE)
  }
  relative.area <- (1 - res$y[-1])
  relative.elev <- (res$t[-c(1, length(res$t))] - z.min)/(z.max - z.min)
  if(length(relative.area) > 1000){
    id_sel <- seq(1, length(relative.area), length.out = 1000)
    relative.area <- relative.area[id_sel]
    relative.elev <- relative.elev[id_sel]
  }   
  if(!is.null(fname)){
    print("writing hypsometric data")
    write.csv(as.matrix(cbind(relative.area,relative.elev)), file = fname)
    print(paste("hypsometric data written to", fname))
  }
  if(!is.null(figname)){
    print("printing hypsometric data")
    pdf(figname)
  }
  plot(relative.area, relative.elev, xaxt = "n", yaxt = "n", 
       main = main, xlim = c(0, 1), ylim = c(0, 1), type = "l", 
       ylab = ylab, xlab = xlab, col = col)
  Axis(side = 1, at = seq(0, 1, by = 0.05), labels = TRUE)
  Axis(side = 2, at = seq(0, 1, by = 0.05), labels = TRUE)
  f <- splinefun(relative.area, relative.elev, method = "monoH.FC")
  hi <- integrate(f = f, lower = 0, upper = 1, stop.on.error = FALSE)
  legend("topright", c(paste("Min Elev. :", round(z.min, 2), "[m.a.s.l.]", sep = " "), 
                       paste("Median Elev.:", round(z.median, 2), "[m.a.s.l.]", sep = " "), 
                       paste("Mean Elev.:", round(z.mean,2), "[m.a.s.l.]", sep = " "), 
                       paste("Max Elev. :", round(z.max,2), "[m.a.s.l.]", sep = " "), 
                       paste("Max Area  :", round(max.area, 1), "[m2]", sep = " "),
                       "", 
                       paste("Integral value :", round(hi$value, 3), sep = " "), 
                       paste("Integral error :", round(hi$abs.error, 3), sep = " ")),
        bty = "n", cex = 0.9,  
        col = c("black", "black", "black"), 
        lty = c(NULL, NULL, NULL, NULL))
  if(!is.null(figname)){
    dev.off()
  }
}

#' This function calculates a mixed hyposometric curve with absolute elevation and relative area
#' 
#' 
#' @param x SpatialGridDataframe as input for the calculation of the hypsometric curve
#' @param band band to be used for hypsometric curve
#' @param main character for the title of the figure
#' @param xlab character lable for x-axis
#' @param ylab character lable for y-axis
#' @param col color of the curve
#' @param fname name of the csv file, only saves data if !NULL
#' @param figname character is the desired output name (character) of the pdf for the hyposometric curve. Only saves pdf if, only saves data if !NULL

my_hypso_mix <- function (x, band = 1, main = "Hypsometric Curve", xlab = "Relative Area above Elevation, (a/A)", 
                          ylab = "Elevation, (m)", col = "blue", fname = NULL, dtok = NULL, figname = NULL, ...) 
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
  res <- plot.stepfun(ecdf(as.matrix(mydem)), lwd = 0, cex.points = 0)
  z.median.index <- which(round(res$y, 3) == 0.5)[1]
  z.median <- res$t[z.median.index]
  if (is.na(z.median)) {
    z.median.index <- which(round(res$y, 2) == 0.5)[1]
    z.median <- res$t[z.median.index]
  }
  else if (is.na(z.median)) {
    z.median <- median(mydem, na.rm = TRUE)
  }
  relative.area <- (1 - res$y[-1])
  elev <- res$t[-c(1, length(res$t))]
  if(length(relative.area) > 1000){
    id_sel <- seq(1, length(relative.area), length.out = 1000)
    relative.area <- relative.area[id_sel]
    elev <- elev[id_sel]
  }   
  if(!is.null(fname)){
    print("writing hypsometric data")
    write.csv(as.matrix(cbind(relative.area,elev)), file = fname)
    print(paste("hypsometric data written to", fname))
  }
  if(!is.null(figname)){
    print("printing hypsometric data")
    pdf(figname)
  }
  plot(relative.area, elev, 
       main = main, type = "l", 
       ylab = ylab, xlab = xlab, col = col)
  legend("topright", c(paste("Min Elev. :", round(z.min, 2), "[m.a.s.l.]", sep = " "), 
                       paste("Median Elev.:", round(z.median, 2), "[m.a.s.l.]", sep = " "), 
                       paste("Mean Elev.:", round(z.mean,2), "[m.a.s.l.]", sep = " "), 
                       paste("Max Elev. :", round(z.max,2), "[m.a.s.l.]", sep = " "), 
                       paste("Max Area  :", round(max.area/1e+06, 3), "[km2]", sep = " ")),
         bty = "n", cex = 0.9,  
         col = c("black", "black", "black"), 
         lty = c(NULL, NULL, NULL, NULL))
  if(!is.null(figname)){
    dev.off()
  }
}

#' This function calculates the absolute hyposometric curve with absolute area and elevation
#' 
#' 
#' @param x SpatialGridDataframe as input for the calculation of the hypsometric curve
#' @param band band to be used for hypsometric curve
#' @param main character for the title of the figure
#' @param xlab character lable for x-axis
#' @param ylab character lable for y-axis
#' @param col color of the curve
#' @param fname name of the csv file, only saves data if !NULL
#' @param figname character is the desired output name (character) of the pdf for the hyposometric curve. Only saves pdf if, only saves data if !NULL

my_hypso <- function (x, 
                      band = 1, 
                      main = "Hypsometric Curve", 
                      xlab = expression(paste("Area above Elevation [k",m^2,"]")),
                      ylab = "Elevation [m]", 
                      col = "blue", 
                      fname = NULL, 
                      figname = NULL, ...) 
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
  res <- plot.stepfun(ecdf(as.matrix(mydem)), lwd = 0, cex.points = 0)
  z.median.index <- min(which(res$y > 0.5))
  #z.median.index2 <- max(which(res$y < 0.5))
  
  z.median <- res$t[z.median.index]

  if (is.na(z.median)) {
    z.median.index <- which(round(res$y, 2) == 0.5)[1]
    z.median <- res$t[z.median.index]
  }
  else if (is.na(z.median)) {
    z.median <- median(mydem, na.rm = TRUE)
  }

  area <- (1 - res$y[-1])*max.area
  elev <- res$t[-c(1, length(res$t))]
  if(length(area) > 1000){
    id_sel <- seq(1, length(area), length.out = 1000)
    area <- area[id_sel]
    elev <- elev[id_sel]
  }
  if(!is.null(fname)){
    print("writing hypsometric data")
    write.csv(as.matrix(cbind(area,elev)), file = fname)
    print(paste("hypsometric data written to", fname))
  }
  max.a <- round(max.area/1e+06, 0)
  if(!is.null(figname)){
    print("printing hypsometric data")
    pdf(figname)
  }
  plot(area/1e+06, elev, 
       main = main, type = "l", 
       ylab = ylab, xlab = xlab, col = col)
  legend("topright", legend = c(paste0("Min Elev.: ", round(z.min, 0), " [m.a.s.l.]"), 
                       paste0("Median Elev.: ", round(z.median, 0), " [m.a.s.l.]"), 
                       paste0("Mean Elev.: ", round(z.mean,0), " [m.a.s.l.]"), 
                       paste0("Max Elev.: ", round(z.max,0), " [m.a.s.l.]"), 
                       paste0("Max Area: ", max.a, " [km2]")
                       ),
         bty = "n", cex = 0.9,  
         col = c("black"), 
         lty = c(NULL))
  if(!is.null(figname)){
    dev.off()
    print(paste("curve printed to dir:", figname))
  }
}

  