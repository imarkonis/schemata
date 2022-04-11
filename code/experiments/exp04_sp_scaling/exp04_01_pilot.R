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

to_plot <- basin[basin$level == 6, ]
ggplot(to_plot) +
  geom_sf(fill = as.numeric(to_plot$climate)) +
  theme_light()

### Estimate precipitation scaling
basin_dt <- data.table(basin[basin$coast == 0,])
basin_dt[, prcp_sd_lvl := sd(prcp), level]
basin_dt[, area_m_lvl := mean(area), level]
plot(unique(basin_dt[, .(area_log = log(area), prcp_log = log(prcp_sd_lvl))]))

