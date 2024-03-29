#First script to run 

options(repos='http://cran.rstudio.org')
have_packages <- installed.packages()
cran_packages <- c('remotes',  'data.table', 'tidyverse', 'dbplyr', 'foreach', 'parallel', 'doParallel',
                   'sf', 'sfc', 'rgdal', 'lwgeom', 'rasterdiv',
                   'RPostgres', 'rpostgis', 
                   'kohonen', 'randomForest', 'tree', 'parallelSVM', 'spatialEco')
to_install <- setdiff(cran_packages, have_packages[, 1])
if(length(to_install) > 0) install.packages(to_install)

#remotes::install_github("r-spatial/rgee")

dir.create('./data')
dir.create('./data/raw') #read-only original data
dir.create('./data/archive') #generated data that are not used in analyses
dir.create('./data/experiments') #generated data that are not used in analyses
dir.create('./results') 
dir.create('./results/experiments') 
dir.create('./results/presentations') 
dir.create('./results/figures')
dir.create('./results/figures/communication') #figures used in papers/presentations
dir.create('./results/figures/archive') #old figures that are not used
dir.create('./docs')
dir.create('./docs/literature')






