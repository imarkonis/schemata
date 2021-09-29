source('code/source/libs.R')
source('code/source/geo_functions.R')
source('code/source/experiments/exp_03.R')

pilot_basin <- readRDS(paste0('./data/experiments/', experiment, '/basins/single_basin.rds'))
basins_225 <- readRDS(paste0('./data/experiments/', experiment, '/basins/basins_225.rds'))
basins_222 <- readRDS(paste0('./data/experiments/', experiment, '/basins/basins_222.rds'))
basins_271 <- readRDS(paste0('./data/experiments/', experiment, '/basins/basins_271.rds'))

pilot_basin_line <- st_cast(pilot_basin, "MULTILINESTRING")

basins_225 <- st_make_valid(basins_225)
basins_225_line <- st_cast(basins_225, "MULTILINESTRING")

basins_222 <- st_make_valid(basins_222)
basins_222_line <- st_cast(basins_222, "MULTILINESTRING")

basins_271 <- st_make_valid(basins_271)
basins_271_line <- st_cast(basins_271, "MULTILINESTRING")

pilot_basin <- data.table(cbind(HYBAS_ID = pilot_basin$pfaf_id,
                       area = st_area(pilot_basin),
                       perimeter = st_length(pilot_basin_line)))

ggplot(pilot_basin, aes(log(area), log(perimeter))) +
  geom_point() +
  theme_light()

basins_225 <- data.table(cbind(basin = 225,
                       area = st_area(basins_225),
                       perimeter = st_length(basins_225_line)))
basins_225[, compactness := gc_coef(perimeter, area)]

basins_222 <- data.table(cbind(basin = 222,
                       area = st_area(basins_222),
                       perimeter = st_length(basins_222_line)))
basins_222[, compactness := gc_coef(perimeter, area)]

basins_271 <- data.table(cbind(basin = 271,
                       area = st_area(basins_271),
                       perimeter = st_length(basins_271_line)))
basins_271[, compactness := gc_coef(perimeter, area)]

lm(log(basins_225$area) ~ log(basins_225$perimeter))
lm(log(basins_222$area) ~ log(basins_222$perimeter))
lm(log(basins_271$area) ~ log(basins_271$perimeter))

aa <- 12:28
area <- exp(aa)
square <- data.table(basin = factor('square'), area = area, perimeter = 4 * sqrt(area))
square$compactness <- gc_coef(square$perimeter, square$area)
circle <- data.table(basin = factor('circle'), area = area, perimeter = 2 * sqrt(area * pi))
circle$compactness <- gc_coef(circle$perimeter, circle$area)

lm(log(square$perimeter) ~ log(square$area))
lm(log(circle$perimeter) ~ log(circle$area))

ggplot(rbind(basins_225, basins_222, basins_271, square, circle), aes(log(area), log(perimeter), col = as.factor(basin))) +
  geom_point() +
  geom_smooth(aes(group = basin),  method = "lm") +
  theme_light()

ggplot(rbind(basins_225, basins_222, basins_271, square, circle), aes(log(area), compactness, col = as.factor(basin))) +
  geom_point() +
  theme_light()








