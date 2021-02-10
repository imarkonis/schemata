#First script to run 

options(repos='http://cran.rstudio.org')
have_packages <- installed.packages()
cran_packages <- c('remotes',  'data.table', 'tidyverse', 'dbplyr', 'foreach', 'parallel', 'doParallel',
                   'sf', 'sfc', 'rgdal', 'lwgeom', 'rasterdiv',
                   'RPostgres', 'rpostgis', 'googledrive', 'rgee',
                   'kohonen', 'randomForest', 'tree', 'parallelSVM', 'spatialEco')
to_install <- setdiff(cran_packages, have_packages[, 1])
if(length(to_install)>0) install.packages(to_install)

remotes::install_github("r-spatial/rgee")

dir.create('./code/dev') #code under development - not yet in workflow
dir.create('./code/archive') #code not in workflow but kept anyways
dir.create('./code/experiments')
dir.create('./data')
dir.create('./data/raw') #read-only original data
dir.create('./data/archive') #generated data that are not used in analyses
dir.create('./data/experiments') #generated data that are not used in analyses
dir.create('./results') 
dir.create('./results/experiments') 
dir.create('./results/presentations') 
dir.create('./results/figures')
dir.create('./results/figures/archive') #figures not used in papers/presentations
dir.create('./docs')
dir.create('./docs/literature')






