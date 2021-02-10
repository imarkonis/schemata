library(randomForest)
source('code/source/libs.R')
source('code/source/graphics.R')
source('code/source/experiments/exp_01.R')

path_results <- paste0("./data/experiments/", experiment, "/classify/")
dir.create(path_results)
basin_classes <- readRDS(paste0("./results/experiments/", experiment, "/basin_soms_9_classes.rds"))
basin_feats <- readRDS(paste0("./data/experiments/", experiment, "/basin_feats.rds"))

iterations <- rep(100000, cores_n)

data_for_rf <- cbind(basin_classes$tot_riv_length, basin_classes$gc)
basins_rf <- foreach(ntree = iterations, .combine = randomForest::combine, 
                             .multicombine = TRUE, .packages = 'randomForest') %dopar% {
                               randomForest(data_for_rf, ntree = ntree)
                             }
MDSplot(basins_rf, basin_classes$cluster) #comparison with soms

data_for_rf <- cbind(basin_classes$area, basin_classes$perimeter, basin_classes$tot_riv_length)
basins_rf <- foreach(ntree = iterations, .combine = randomForest::combine, 
                             .multicombine = TRUE, .packages = 'randomForest') %dopar% {
                               randomForest(data_for_rf, ntree = ntree)
                             }
MDSplot(basins_rf, basin_classes$cluster)
round(importance(basins_rf), 2)

varImpPlot(basins_rf)
var_imp = data.frame(importance(basins_rf, type = 2))
var_imp$Variables = row.names(var_imp)  
print(var_imp[order(var_imp$MeanDecreaseGini,decreasing = T),])

proximity <- basins_rf$proximity
pam_rf <- cluster::pam(proximity, 9)
predicted <- cbind(pam_rf$clustering, basin_classes$cluster)
table(predicted[,2], predicted[,1])

RFs <- as.factor(pam_rf$cluster)
SOMs <- basin_classes$cluster
ggplot(basin_classes, aes(x = tot_riv_length, y = gc, col = RFs)) + 
  geom_point(size = 3) + 
  scale_color_manual(values = palette_mid_qual(9)) +
  theme_light()
ggplot(basin_classes, aes(x = tot_riv_length, y = gc, col = SOMs)) + 
  geom_point(size = 3) + 
  scale_color_manual(values = palette_mid_qual(9)) +
  theme_light()
