
source('code/source/libs.R')
source('code/source/functions.R')
source('code/source/geo_utils.R')
source('code/source/database.R')
source('code/source/geo_functions.R')
source('code/source/experiments/exp_05.R')

library(ggplot2)

regions <- c("af", "as", "na", "au", "eu", "sa_n", "sa_s")

for(i in 1:length(regions)){
  river_NCI <- readRDS(paste0(results_path, '/',regions[i],'_NCI_pfaf_ids.rds'))
  
  river_NCI_sel <- subset(river_NCI, select = c(NCI_12, 
                                                NCI_11, 
                                                NCI_10,
                                                NCI_9,
                                                NCI_8,
                                                NCI_7,
                                                NCI_6,
                                                NCI_5,
                                                NCI_4,
                                                NCI_3, 
                                                pfaf_id,
                                                main_riv_pfaf_id, 
                                                main_riv_level))
  
  river_NCI_long <- melt(data = river_NCI_sel, measure.vars = c("NCI_12", 
                                                                "NCI_11", 
                                                                "NCI_12",
                                                                "NCI_10",
                                                                "NCI_9",
                                                                "NCI_8",
                                                                "NCI_7",
                                                                "NCI_6",
                                                                "NCI_5",
                                                                "NCI_4",
                                                                "NCI_3"), variable.name = "level", value.name = "NCI")
  
  
  river_NCI_long <- data.table(river_NCI_long)
  river_NCI_long[, pfaf_level := substr(level, start = 5, stop = 7)]
  river_NCI_long[, pfaf_level := as.numeric(pfaf_level)]
  river_NCI_long[, pfaf_id_NCI := substr(pfaf_id, start = 1, stop = pfaf_level)]
    
  river_NCI_long[main_riv_level > pfaf_level, type := "region"]
  river_NCI_long[main_riv_level < pfaf_level, type := "sub-basin"]
  river_NCI_long[main_riv_level == pfaf_level, type := "main-basin"]
  
  river_NCI_long[type == "region", main_riv_pfaf_id:= NA]
  river_NCI_long[type == "region", main_riv_level:= NA]
  
  river_NCI_long_unique <- unique(river_NCI_long)
  
  river_NCI_long_unique[,level := NULL]
  river_NCI_long_unique[,pfaf_id := NULL]

  old_names <- c("pfaf_id_NCI")
  new_names <- c("pfaf_id")
  setnames(river_NCI_long_unique, old_names, new_names)
  saveRDS(river_NCI_long_unique, paste0(results_path, '/',regions[i],'_NCI_sel.rds'))
  
}
  

