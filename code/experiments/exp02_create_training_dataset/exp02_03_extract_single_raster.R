#Merge basins, rivers and DEMs

source('code/source/exp_02.R')
source('code/source/libs.R')
source('code/source/geo_utils.R')

shapefile_rivers <- paste0("./data/experiments/", experiment, "/rivers.shp")
shapefile_basins <- paste0("./data/experiments/", experiment, "/basins.shp")
rasterfile_dem <- paste0("./data/experiments/", experiment, "/dem.tif")

rivers_sf <- st_read(shapefile_rivers)
basins_sf <- st_read(shapefile_basins)
dem_raster <- raster(rasterfile_dem)
riv_bas_sf <- st_read(paste0("./data/experiments/", experiment, "/riv_bas.shp"))

hybas_id <- 2080321070   

plot(riv_bas_sf[riv_bas_sf$HYBAS_ID == hybas_id, ]$geometry)

single_basin <- basins_sf[basins_sf$HYBAS_ID == hybas_id, ]
single_river <- riv_bas_sf[riv_bas_sf$HYBAS_ID == hybas_id, ]
single_dem <- crop_basin(single_basin, dem_raster)

st_bbox(st_geometry(single_basin))[1]
e <- extent(st_bbox(st_geometry(single_basin))[1], 
            st_bbox(st_geometry(single_basin))[3], 
            st_bbox(st_geometry(single_basin))[2],
            st_bbox(st_geometry(single_basin))[4])
single_dem <- crop(dem_raster, e)

dem_dt <- data.table(rasterToPoints(single_dem))
colnames(dem_dt) <- c('lon', 'lat', 'elevation')

ggplot() +
  geom_raster(data = dem_dt, aes(y = lat, x = lon, fill = elevation)) +
  geom_sf(data = single_river) +
  labs(x = "", y = "") +
  theme_light()

river_raster <- stars::st_rasterize(single_river)
plot(river_raster)

rivers_raster <- stars::st_rasterize(rivers_sf[, "SED"])
plot(rivers_raster)

