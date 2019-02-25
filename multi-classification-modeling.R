## Credit  Microsoft -- adaptation to CRAN package only
## https://github.com/Microsoft/SQL-Server-R-Services-Samples/blob/master/PredictiveMaintenance/R/02c-multi-classification-modeling.R

####################################################################################################
## Training regression models to answer questions on whether a refugee case is likely to be food unsecure
## cycles. The models will be trained include:
## 1. Decision forest;
## 2. Boosted decision tree;
## 3. Multinomial modeling;
## 4. Neural network


## The Objective is to predict between 3 classes for variable unconditionnal2
## "full.allocation",
## "no.allocation",
## "reduced.allocation"

## Install pacman to manage package installation
# install.packages("pacman")

pacman::p_load('caret', 'RODBC',
               'reshape2',  'randomForest',
               'gbm', 'nnet')


####################################################################################################
####################################################################################################
## Extract registry
####################################################################################################
source("get_data_from_db.R")

####################################################################################################
## Feature engineering to reduce number of modalities for good classification
####################################################################################################
## This may need to be adjusted depending on the specific context

source("feature.R")


####################################################################################################
## Join with Survey
####################################################################################################
cat("Joining on table from survey with observed vulnerability category. \n")

train <- read.csv("train.csv")


## Merging Registry & survey data
train_table <-  merge(x = cases2, y = train[ , c("CaseNo", "unconditionnal2")] , by = "CaseNo", all.y = TRUE)

## Keeping case id as row names only
row.names(train_table) <- train_table$CaseNo
train_table$CaseNo <- NULL

## Convert all character variable into factor in one line:
library(dplyr)
train_table <- train_table %>% mutate_if(is.character, as.factor)
train_table <- train_table %>% mutate_if(is.integer, as.factor)
#str(train_table)

## Remove variables with NA
train_table <- train_table[, colSums(!is.na(train_table)) > 0]
#str(train_table)


####################################################################################################
## Partitionning dataset for train & test
####################################################################################################

# The function createDataPartition can be used to create balanced splits of the data.
# If the y argument to this function is a factor, the random sampling occurs within each class
# and should preserve the overall class distribution of the data.
# Here we create a single 60/40% split of the  data:

### see documentation here: http://topepo.github.io/caret/data-splitting.html

#install caret package
#install.packages('caret')
#load package
#library(caret)
trainIndex = createDataPartition(train_table$unconditionnal2,
                                 p = 0.6, list = FALSE,times = 1)

train_table_na = train_table[trainIndex,]
prediction_df = train_table[-trainIndex,]


####################################################################################################
## Mulit-classification model evaluation metrics
####################################################################################################
evaluate_model <- function(observed, predicted) {
  confusion <- table(observed, predicted)
  num_classes <- nlevels(observed)
  tp <- rep(0, num_classes)
  fn <- rep(0, num_classes)
  fp <- rep(0, num_classes)
  tn <- rep(0, num_classes)
  accuracy <- rep(0, num_classes)
  precision <- rep(0, num_classes)
  recall <- rep(0, num_classes)
  for (i in 1:num_classes) {
    tp[i] <- sum(confusion[i, i])
    fn[i] <- sum(confusion[-i, i])
    fp[i] <- sum(confusion[i, -i])
    tn[i] <- sum(confusion[-i, -i])
    accuracy[i] <- (tp[i] + tn[i]) / (tp[i] + fn[i] + fp[i] + tn[i])
    precision[i] <- tp[i] / (tp[i] + fp[i])
    recall[i] <- tp[i] / (tp[i] + fn[i])
  }
  overall_accuracy <- sum(tp) / sum(confusion)
  average_accuracy <- sum(accuracy) / num_classes
  micro_precision <- sum(tp) / (sum(tp) + sum(fp))
  macro_precision <- sum(precision) / num_classes
  micro_recall <- sum(tp) / (sum(tp) + sum(fn))
  macro_recall <- sum(recall) / num_classes
  metrics <- c("Overall accuracy" = overall_accuracy,
               "Average accuracy" = average_accuracy,
               "Micro-averaged Precision" = micro_precision,
               "Macro-averaged Precision" = macro_precision,
               "Micro-averaged Recall" = micro_recall,
               "Macro-averaged Recall" = macro_recall)
  return(metrics)
}


####################################################################################################
## Random Decision forest modeling
####################################################################################################
# install.packages("randomForest")
cat("Joining on table from survey with observed vulnerability category. \n")

#library(randomForest)
forest_model <- randomForest(unconditionnal2 ~ ., data = train_table_na,
                             nTree = 8,
                             maxDepth = 32,
                             mTry = 35,
                             na.action = na.omit,
                             seed = 5)
## save this model
save(forest_model, file = "forest_model.rda")

#load("forest_model.rda")

forest_prediction <- as.data.frame(predict(forest_model, newdata = prediction_df,
                                           type = "prob",
                                           overwrite = TRUE))

names(forest_prediction) <- c("full.allocation",
                              "no.allocation",
                              "reduced.allocation")
forest_prediction$Forest_Prediction <- predict(forest_model, newdata = prediction_df)

forest_metrics <- evaluate_model(observed = prediction_df$unconditionnal2,
                                 predicted = forest_prediction$Forest_Prediction)
####################################################################################################
## Stochastic Gradient Boosted Decision Trees modeling
####################################################################################################
# install.packages("gbm")
cat("Joining on table from survey with observed vulnerability category. \n")

#library(gbm)
boosted_model <- gbm(unconditionnal2 ~ ., data = train_table_na,
                     distribution = 'multinomial',
                     n.trees = 200,
                     interaction.depth = 4,
                     shrinkage = 0.005)
## save this model
save(boosted_model, file = "boosted_model.rda")

# load("boosted_model.rda")

boosted_prediction <- predict(boosted_model, newdata = prediction_df,
                              n.trees = 200,type = 'response')
boosted_prediction <- as.data.frame(boosted_prediction)
#levels(train_table_na$unconditionnal2)
names(boosted_prediction) <- c("full.allocation",
                               "no.allocation",
                               "reduced.allocation")

boosted_prediction$Boosted_Prediction <- apply(boosted_prediction, 1, which.max)
boosted_prediction$Boosted_Prediction2 <- ifelse(boosted_prediction$Boosted_Prediction == 1, "full.allocation",
                                                 ifelse(boosted_prediction$Boosted_Prediction == 2, "no.allocation",
                                                        "reduced.allocation"))

boosted_metrics <- evaluate_model(observed = prediction_df$unconditionnal2,
                                  predicted = boosted_prediction$Boosted_Prediction)
####################################################################################################
## Multinomial modeling
####################################################################################################
# install.packages("nnet")
cat("Multinomial modeling. \n")
#library(nnet)

multinomial_model <- multinom(unconditionnal2 ~ ., data = train_table_na)


## save this model
save(multinomial_model, file = "multinomial_model.rda")

#load("multinomial_model.rda")
multinomial_prediction <- predict(object = multinomial_model,
                                  newdata = prediction_df,
                                  type = "prob")
multinomial_prediction <- as.data.frame(multinomial_prediction)
names(multinomial_prediction) <- c("full.allocation",
                                   "no.allocation",
                                   "reduced.allocation")

multinomial_prediction$Multinomial_Prediction <- predict(object = multinomial_model, newdata = prediction_df)


multinomial_metrics <- evaluate_model(observed = prediction_df$unconditionnal2,
                                      predicted = multinomial_prediction$Multinomial_Prediction)


cat("Stepwise model. \n")
## Stepwsise variable selection
multinomialstep_model <- step(multinomial_model, trace = 0)
save(multinomialstep_model, file = "multinomialstep_model.rda")

#load("multinomialstep_model.rda")
multinomialstep_prediction <- predict(object = multinomialstep_model,
                                      newdata = prediction_df,
                                      type = "prob")
multinomialstep_prediction <- as.data.frame(multinomialstep_prediction)
names(multinomialstep_prediction) <- c("full.allocation",
                                       "no.allocation",
                                       "reduced.allocation")

multinomialstep_prediction$Multinomialstep_Prediction <- predict(object = multinomialstep_model, newdata = prediction_df)

multinomialstep_metrics <- evaluate_model(observed = prediction_df$unconditionnal2,
                                          predicted = multinomialstep_prediction$Multinomialstep_Prediction)

####################################################################################################
## Neural network regression modeling
####################################################################################################
# install.packages("nnet")
cat("Neural network regression modeling. \n")
#library(nnet)

#nodes <- 10
#weights <- nodes * (35 + 3) + nodes + 3

nnet_model <- nnet(unconditionnal2 ~ ., data = train_table_na,
                   ### Wts = rep(0.1, weights),
                   ##  size = nodes,
                   size = 25,
                   decay = 0.005,
                   maxit = 100,
                   ## MaxNWts = weights),
                   MaxNWts = 100000)
## save this model
save(nnet_model, file = "nnet_model.rda")

# load("nnet_model.rda")

## Prediction
nnet_prediction <- predict(object = nnet_model,
                           newdata = prediction_df,
                           type = "raw")
nnet_prediction <- as.data.frame(nnet_prediction)
names(nnet_prediction) <- c("full.allocation",
                            "no.allocation",
                            "reduced.allocation")

nnet_prediction_response <- predict(object = nnet_model,
                                    newdata = prediction_df,
                                    type = "class")

nnet_prediction_response <- as.data.frame(nnet_prediction_response)
names(nnet_prediction_response) <- "Nnet_Prediction"
nnet_prediction <- cbind(nnet_prediction, nnet_prediction_response)
nnet_metrics <- evaluate_model(observed = prediction_df$unconditionnal2,
                               predicted = nnet_prediction$Nnet_Prediction)
####################################################################################################
## Combine and save metrics
####################################################################################################
cat("Combine and save metrics. \n")

main <- getwd()

predictions <- cbind(prediction_df$unconditionnal2, forest_prediction,
                     boosted_prediction,
                     multinomial_prediction,
                     multinomialstep_prediction,
                     nnet_prediction)


write.csv(predictions , paste0(main, "/predictions", format(Sys.time(), "%m-%d-%Y"),".csv"))


metrics_df <- rbind(forest_metrics,
                    boosted_metrics,
                    multinomial_metrics,
                    multinomialstep_metrics,
                    nnet_metrics)
metrics_df <- as.data.frame(metrics_df)

rownames(metrics_df) <- NULL
Algorithms <- c("Random Decision Forest",
                "Boosted Decision Tree",
                "Multinomial Regression",
                "Multinomial Step Regression",
                "Neural Network")

metrics_df <- cbind(Algorithms, metrics_df)

metrics_df

write.csv(metrics_df , paste0(main, "/metrics_df", format(Sys.time(), "%m-%d-%Y"),".csv"))

#rm(list = ls())
