#SOMs for basin classification 

library(kohonen)
source('code/source/libs.R')
source('code/source/experiments/exp_01.R')

path_results <- paste0("./data/experiments/", experiment, "/classify/")
dir.create(path_results)
basin_feats <- readRDS(paste0("./data/experiments/", experiment, "/basin_feats.rds"))

map_dimension <- 3
n_iterations <- 100000
recalculate_map <- T

som_grid <- somgrid(xdim = map_dimension, 
                    ydim = map_dimension, 
                    topo = "hexagonal")

fname <- paste0('som_pilot_', som_grid$xdim, '_', n_iterations)
path_fname <- paste0(path_results, fname, '.Rdata')

if(recalculate_map == F & file.exists(fname) == T){
  load(fname)
} else {
  basin_som <- supersom(apply(basin_feats[, .(tot_riv_length, gc)], 2, scale), 
                grid = som_grid, 
                rlen = n_iterations, 
                alpha = 0.05,
                cores = cores_n
                #,dist.fcts = distances
                #, user.weights = weight_layers
                #, maxNA.fraction = .5
  )
  save(basin_som, file = path_fname)
}


# Validation plots

plot(basin_som, type = "changes")
plot(basin_som, type = "counts")
plot(basin_som, type = "codes")
