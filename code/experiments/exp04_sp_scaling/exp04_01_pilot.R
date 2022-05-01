source('code/source/libs.R')
source('code/source/experiments/exp_03.R')

library(RPostgres)
#library(sf)

### Import, merge and plot basin

con <- dbConnect(Postgres(), dbname = db_name, host = host_ip, port = port_n,         
                 user = rstudioapi::askForPassword("Database user"),      
                 password = rstudioapi::askForPassword("Database password"))

basin_atlas_feats <- readRDS(paste0(data_path, 'basin_atlas_feats.rds'))

sample_region <- regions_all[5] # Sample region is Europe
sample_pfaf_id <- 222


basin <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.", 
                            sample_region, "_all WHERE pfaf_id like '", sample_pfaf_id, "%'"))

basin <- merge(basin, basin_atlas_feats, by = c('pfaf_id', 'hybas_id', 'coast'))

to_plot <- basin[basin$level == 3, ]
ggplot(to_plot) +
  geom_sf(fill = as.numeric(to_plot$climate)) +
  theme_light()

sample_pfaf_id <- 221
min_bas_level <- 5

basin_temp <- st_read(con, query = paste0("SELECT * FROM basin_boundaries.", 
                                          sample_region, "_all WHERE pfaf_id like '", sample_pfaf_id, "%'"))
basin_temp <- merge(basin_temp, basin_atlas_feats, by = c('pfaf_id', 'hybas_id', 'coast'))

basin_dt <- data.table(basin_temp)
basin_dt <- basin_dt[!duplicated(round(perimeter, 0))]
basin_dt[, main_basin_id := factor(substr(pfaf_id, 1, min_bas_level))]
basin_dt[, prcp_sd_lvl := sd(prcp), .(level, main_basin_id)]
basin_dt[, area_m_lvl := mean(area), .(level, main_basin_id)]

ggplot(basin_dt[coast == 0], aes(x = log(level), y = log(prcp_sd_lvl), col = main_basin_id)) +
  geom_point() +
  geom_smooth(method = 'lm', se = 0) +
  theme_light()

ggplot(basin_dt[coast == 0], aes(x = level, y = prcp_sd_lvl, group = level)) +
  geom_boxplot() +
  theme_light()

to_plot <- basin_dt[coast == 0, .(prcp = log(mean(prcp_sd_lvl, na.rm = T)), area_m = mean(fractal)), level]
to_plot <- to_plot[complete.cases(to_plot),]
to_plot <- melt(to_plot, id.vars = 'level')
ggplot(to_plot, aes(level, log(value), col = variable)) +
  geom_point() +
  geom_smooth(method = 'lm', se = 0, ) +
  facet_wrap(~variable, scales = "free") + 
  theme_light()



### Estimate precipitation scaling
basin_dt <- data.table(basin[basin$coast == 0,])
basin_dt[, prcp_sd_lvl := sd(prcp), level]
basin_dt[, area_m_lvl := mean(area), level]
plot(basin_dt[, .(scale_log = log(level), prcp_log = log(prcp_sd_lvl))])




