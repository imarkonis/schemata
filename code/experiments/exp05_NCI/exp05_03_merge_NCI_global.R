source('code/source/experiments/exp_05.R')

regions <- c("af", "as", "na", "au", "eu", "sa_n", "sa_s", "si")
for(i in 1:length(regions)){
  print(regions[i])
  if(i == 1){
    river_NCI <- readRDS(paste0(data_path,"/",regions[i],'_NCI_hybas.rds'))
  }else{
    river_tmp <- readRDS(paste0(data_path,"/",regions[i],'_NCI_hybas.rds'))
    river_NCI <- rbind(river_NCI, river_tmp)
  }
}

saveRDS(river_NCI, paste0(data_path, "/NCI_global.rds"))
