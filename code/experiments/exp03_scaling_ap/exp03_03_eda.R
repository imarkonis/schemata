source('code/source/libs.R')
source('code/source/geo_functions.R')
source('code/source/experiments/exp_03.R')

library(RPostgres)
library(sf)
library(dbplyr)
library(dplyr)

basin_level <- 6
lm_coefs <- readRDS(paste0(results_path, 'pa_lm_coefs_', basin_level, '.rds'))
basin_feats <- readRDS(paste0(data_path, 'basin_feats_', basin_level, '.rds'))
con <- dbConnect(Postgres(), dbname = db_name,       
                 user = rstudioapi::askForPassword("Database user"),      
                 password = rstudioapi::askForPassword("Database password"))

basins_eu <- st_read(con, query = paste0("SELECT * FROM ", db_schema, ".eu_", basin_level))
basins_au <- st_read(con, query = paste0("SELECT * FROM ", db_schema, ".au_", basin_level))
basins <- bind_rows(basins_au, basins_eu)
basins_no_coast <- basins[basins$coast == 0,]

basins <- basins %>% 
  select(pfaf_id) 
basins <- merge(basins, lm_coefs, by = 'pfaf_id')

basins_no_coast <- basins_no_coast %>% 
  select(pfaf_id) 
basins_no_coast <- merge(basins_no_coast, lm_coefs, by = 'pfaf_id')

plot(basins["slope"])
plot(basins_no_coast["slope"])
summary(lm_coefs)
hist(lm_coefs$slope, breaks = 25)

basins_2 <- basins %>% 
  filter(slope < 2 & slope > 1.5)
plot(basins_2["slope"])

basin_feats[, gc := gc_coef(perimeter, area)]
basin_feats[, fractal := fractal_dim(perimeter, area)]
basin_feats[, circ_area := perimeter ^ 2 / (4 * pi)]
basin_feats[, sqr_area := perimeter ^ 2 / 4]
basins_more <- merge(lm_coefs, basin_feats, by = c('pfaf_id', 'region'))
basins_more <- basins_more[complete.cases(basins_more)]

to_plot <- basins_more[, .(area = max(area)), pfaf_id]
to_plot <- unique(basins_more[to_plot, on = c('area', 'pfaf_id')])

ggplot(to_plot[gc < 5], aes(gc, slope, col = region)) +
  geom_point() +
  theme_light()

ggplot(to_plot[gc < 5], aes(x = log(gc), fill = region)) +
  geom_density(alpha = 0.5) +
  theme_light()

ggplot(to_plot, aes(x = fractal, fill = region)) +
  geom_density(alpha = 0.5) +
  theme_light()

ggplot(basin_feats, aes(log(area), log(perimeter), col = log(gc))) +
  geom_point() +
  theme_light()

ggplot(basin_feats[gc < 3], aes(log(area), log(perimeter), col = log(gc))) +
  geom_point() +
  theme_light()

ggplot(basin_feats) +
  geom_smooth(aes(log(perimeter), log(area), col = region), method = 'lm', se = F) +
  geom_smooth(aes(log(perimeter), log(circ_area),  col = 'circle'), method = 'lm', se = F) +
  theme_light()

ggplot(basin_feats, aes(log(area), log(gc), group = pfaf_id, col = region)) +
  geom_line() +
  #geom_smooth(method = 'lm', se = F) +
  theme_light()

lm_fit <- lm(log(area) ~ log(perimeter), data = basins_more)


