#Supervised basin classification 

library(parallelSVM) 
library(randomForest) 
source('code/source/libs.R')
source('code/source/experiments/exp_01.R')

path_results <- paste0("./data/experiments/", experiment, "/classify/")
dir.create(path_results)
basin_classes <- readRDS(paste0("./results/experiments/", experiment, "/basin_soms_9_classes.rds"))

sample_size <- nrow(basin_classes)
train_size <- round(sample_size * 0.8)
basin_classes_train <- basin_classes[1:train_size, ]
basin_classes_pred <- basin_classes[(train_size + 1):sample_size, ]

predictors_train <- cbind(tot_riv_length = basin_classes_train$tot_riv_length, 
                          gc = basin_classes_train$gc)
predictors_pred <- cbind(tot_riv_length = basin_classes_pred$tot_riv_length, 
                         gc = basin_classes_pred$gc)
classes_train <- basin_classes_train$cluster
classes_pred <- basin_classes_pred$cluster

# Support Vector Machines
basins_model_svm <- parallelSVM(predictors_train, classes_train)
basins_svm_pred <- predict(basins_model_svm, predictors_pred)
table(basins_svm_pred, classes_pred)

# Random Forests
basins_model_rf <- randomForest(cluster ~ tot_riv_length + gc, data = basin_classes_train, importance = TRUE,
                                proximity =  TRUE)
basins_rf_pred <- predict(basins_model_rf, predictors_pred)
table(basins_rf_pred, classes_pred)

## Use basin area and perimeter as predictors
predictors_train <- cbind(perimeter = basin_classes_train$perimeter, area = basin_classes_train$area)
predictors_pred <- cbind(perimeter = basin_classes_pred$perimeter, area = basin_classes_pred$area)

basins_model_svm <- parallelSVM(predictors_train, classes_train)
basins_svm_pred <- predict(basins_model_svm, predictors_pred)
table(basins_svm_pred, classes_pred)

basins_model_rf <- randomForest(cluster ~ perimeter + area, data = basin_classes_train, importance = TRUE,
                                proximity =  TRUE)
basins_rf_pred <- predict(basins_model_rf, predictors_pred)
table(basins_rf_pred, classes_pred)
