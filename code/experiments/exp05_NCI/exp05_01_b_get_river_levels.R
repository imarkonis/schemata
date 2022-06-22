source('code/source/libs.R')
source('code/source/experiments/exp_05.R')

options(scipen = 15)
regions <- c("af", "as", "na", "au", "eu", "sa_n", "sa_s", "si")

# add basin, sub-basin, interbasin, closed, region, 
for(i in 1:length(regions)){
  river_pfaf <- readRDS(paste0(data_path,'/',regions[i], '_rivers_pfaf.rds'))
  river_pfaf <- as.data.table(river_pfaf)
  pfaf_level <- 12
  river_pfaf[, zerotest := FALSE]
  river_pfaf[,last_pi_digit := substr(pfaf_id, pfaf_level, pfaf_level)]
  river_pfaf[ last_pi_digit == "0", zerotest := TRUE]
  river_pfaf[(pfaf_id%%2) == 0, basin:= "sub-basin"]
  river_pfaf[(pfaf_id%%2) == 1, basin:= "inter-basin"]
  river_pfaf[zerotest == TRUE, basin:= "closed"]
  river_pfaf[,lowest_ord_clas := min(ord_clas), .(pfaf_id)]
  river_pfaf[,pfaf_id_level:= pfaf_id]
  river_pfaf[,main_test:= FALSE]
  river_pfaf[,lookformain:= TRUE]
  river_pfaf[, pfaf_in_main := length(unique(pfaf_id_level)),  .(main_riv)]
  river_pfaf[pfaf_in_main == 1, main_test := TRUE,  .(pfaf_id_level)]
  river_pfaf[, main_riv_level := -100]
  river_pfaf[main_test == TRUE & lookformain == TRUE, main_riv_level := pfaf_level]
  river_pfaf[main_test == TRUE & lookformain == TRUE, main_riv_pfaf_id := pfaf_id_level]
  river_pfaf[main_test == TRUE , lookformain:= FALSE]
  
  river_tmp <- river_pfaf[zerotest == FALSE & ord_clas == lowest_ord_clas & basin == "sub-basin"]
  
  for(pfaf_level in 11:3){
    river_pfaf[,pfaf_id_level:=  as.numeric(substr(pfaf_id, 1, pfaf_level))]
    river_pfaf[,zerotest := FALSE]
    river_pfaf[,last_pi_digit := substr(pfaf_id, pfaf_level, pfaf_level)]
    river_pfaf[ last_pi_digit == "0", zerotest := TRUE]
    river_pfaf[(pfaf_id_level%%2) == 0, basin:= "sub-basin"]
    river_pfaf[(pfaf_id_level%%2) == 1, basin:= "inter-basin"]
    if(pfaf_level == 3){
      river_pfaf[(pfaf_id_level%%2) == 1, basin:= "sub-basin"]
    }    
    river_pfaf[zerotest == TRUE, basin:= "closed"]
    river_pfaf[, lowest_ord_clas := min(ord_clas), .(pfaf_id_level)]
    river_pfaf[, pfaf_in_main := length(unique(pfaf_id_level)),  .(main_riv)]
    river_pfaf[pfaf_in_main == 1, main_test := TRUE,  .(pfaf_id_level)]
    river_pfaf[pfaf_level < main_riv_level, basin := "region" ]
    river_pfaf[main_test == TRUE & lookformain == TRUE, main_riv_level := pfaf_level]
    river_pfaf[main_test == TRUE & lookformain == TRUE, main_riv_pfaf_id := pfaf_id_level]
    river_pfaf[main_test == TRUE, lookformain:= FALSE]
    river_tmp_lev <- river_pfaf[zerotest == FALSE & ord_clas == lowest_ord_clas & basin == "sub-basin"]
    river_tmp <- rbind(river_tmp, river_tmp_lev)
  }
  river_tmp[, cnt_gid := nrow(.SD), gid]
  river_tmp[, pfaf_id_level_true := min(pfaf_id_level), gid]
  river_tmp <- river_tmp[pfaf_id_level_true == pfaf_id_level]
  river_tmp[, zerotest := NULL]
  river_tmp[, last_pi_digit := NULL]
  saveRDS(river_tmp, paste0(data_path, '/',regions[i],'_levels.rds'))
  print(regions[i])
}

