
source('code/source/libs.R')
source('code/source/functions.R')
source('code/source/geo_utils.R')
source('code/source/database.R')
source('code/source/geo_functions.R')
source('code/source/experiments/exp_05.R')

library(data.table)

regions <- c("af_rivers", "as_rivers", "na_rivers", "au_rivers", "eu_rivers", "si_rivers", "sa_n_rivers", "sa_s_rivers")

for(i in 1:length(regions)){
  fnames <- list.files(path = data_path, pattern = regions[i])
  for(j in 1:length(fnames)){
   dta_temp <- as.data.table(readRDS(paste0(data_path, '/', fnames[j])))
   if(j == 1){
     dta_dt <- dta_temp
   }else{
     dta_dt <- rbind(dta_dt, dta_temp)
   }
  }
  saveRDS(dta_dt, paste0(data_path, '/',regions[i],'_xyz.rds'))
}




