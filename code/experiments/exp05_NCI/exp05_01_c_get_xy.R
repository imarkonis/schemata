source('code/source/libs.R')
source('code/source/experiments/exp_05.R')
options(scipen = 15)
regions <- c("af", "as", "na", "au", "eu", "sa_n", "sa_s", "si")

mclapply(regions, 
  par_regions, 
  mc.cores = 40,
  mc.cleanup = TRUE
)
