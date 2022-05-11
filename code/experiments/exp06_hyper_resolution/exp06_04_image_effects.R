source('./code/source/experiments/exp_06.R')
source('./code/source/libs.R')
source('./code/source/geo_utils.R')
library(png)
library(SpatialPack)
library(truncnorm)

data_source_path <- paste0("./data/experiments/", experiment, '/dems/')
data_save_path <- paste0("./data/experiments/", experiment, '/coarse/')

dem_files_png <- list.files(data_source_path, pattern = "*dem.png")
pal <- colorRampPalette(c("white", "black"))

file_count <- 1111

dem_raster <- raster(paste0(data_source_path, dem_files_png[file_count]))
dem_raster_4 <- raster(paste0(data_save_path, "/scale_4/", dem_files_png[file_count]))
dem_raster_8 <- raster(paste0(data_save_path, "/scale_8/", dem_files_png[file_count]))

par(mar = c(0, 0, 0, 0))
plot(dem_raster, main = NULL, key.pos = NULL, col = rev(pal(100)),  
     legend = FALSE, axes=FALSE, box = FALSE)
plot(dem_raster_4, main = NULL, key.pos = NULL, col = rev(pal(100)),  
     legend = FALSE, axes=FALSE, box = FALSE)
plot(dem_raster_8, main = NULL, key.pos = NULL, col = rev(pal(100)),  
     legend = FALSE, axes=FALSE, box = FALSE)

x <- imnoise(as.matrix(dem_raster), type = "saltnpepper", epsilon = 0.10)
plot(as.raster(x))

y <- imnoise(texmos2, type = "speckle")
plot(as.raster(y))

z <- imnoise(texmos2, type = "gamma", looks = 4)
plot(as.raster(z))  

rand_noise<-function(a=50, b=100, m=90, sd=50){
  val=rtruncnorm(n=1,a=a, b=b, mean=m, sd=sd)
  return(val[1])
}

df=as.data.frame(dem_raster, xy=TRUE)
df$noise=apply(df, 1, function(x) rand_noise())

keeps=c('x','y','noise')
df=df[keeps]
noise=rasterFromXYZ(df)
crs(noise) = crs(dem_raster)
noisy=dem_raster+noise
plot(noisy, col = rev(pal(100)))

data(texmos2)
x <- imnoise(texmos2, type = "saltnpepper", epsilon = 0.10)
plot(as.raster(x))
