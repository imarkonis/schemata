source('code/source/libs.R')
source('code/source/geo_functions.R')
source('code/source/experiments/exp_05.R')

library(sf)
library(ggplot2)
library(RColorBrewer)

dta_dir <- "data/Seybold"

fnames <- list.files(path = dta_dir)

dta_sd <- read.table(paste0(dta_dir,"/",fnames[1]), sep = ",", header = T)

eu_bas_l5 <- readRDS(paste0(data_path, '/basin_borders_eu5.rds'))

eu_merged2 <- merge(eu_bas_l5, dta_sd, by.x = 'hybas_id', by.y = "HYBAS_ID")


min_NCI <- min(eu_merged2$NCI_Chen_et_al)
max_NCI <- max(eu_merged2$NCI_Chen_et_al)


eu_merged2$NCIbin <- cut(eu_merged2$NCI_Chen_et_al, breaks <- c(-0.5, -0.15,-0.05, 0.05, 0.15))

ggplot()+
  geom_sf(data = eu_merged2, aes(fill = NCI_Chen_et_al))+
  scale_fill_gradient2(low  = "darkorange", mid = "green",high = "royalblue2", midpoint = -0.2)+
  theme_void()


ggplot()+
  geom_sf(data = eu_merged2, aes(fill = NCI_Chen_et_al))+
  scale_fill_continuous(type = "viridis")+
  theme_void()

NCI_colors <- c(
  "(-0.5,-0.15]" = "yellow",
  "(-0.15,-0.05]" = "darkorange",
  "(-0.05,0.05]" = "royalblue2",
  "(0.05,0.2]" = "darkblue"

)

ggplot()+
  geom_sf(data = eu_merged2, aes(fill = NCIbin))+
  scale_fill_manual(values = NCI_colors)+
  theme_void()
