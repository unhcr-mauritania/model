## Credit  Microsoft -- adaptation to CRAN package only
## https://github.com/Microsoft/SQL-Server-R-Services-Samples/blob/master/PredictiveMaintenance/R/02c-multi-classification-modeling.R

####################################################################################################
## Training regression models to answer questions on whether a refugee case is likely to be food unsecure
## cycles. The models will be trained include:
## 1. Decision forest;
## 2. Boosted decision tree;
## 3. Multinomial modeling;
## 4. Neural network

####################################################################################################
####################################################################################################
## Extract registry
####################################################################################################

#install.packages("RODBC")
library(RODBC)

#########################################
## Db handle for progres Data warehouse
#########################################
source("pass.R")
## In a different file
# progres <- "..." ## Name of the ODBC connection to the DB - needs to be created before
## user <- "..."
## passw <- "..."

cat("Connecting to the server")
dbhandleprogres <- odbcConnect(progres, uid=user, pwd=passw)
source("extract-query.R")

## fetching the view containing information aggregated at the case level and the event
cat("Executing the summary table creation within proGres")
dependency <- sqlQuery(dbhandleprogres, query1)
capacity <- sqlQuery(dbhandleprogres, query2)
specificneeds <- sqlQuery(dbhandleprogres, query3)

cases <- merge( x = dependency, y = capacity, by = "CaseNo" )

## install.packages("reshape2")
library(reshape2)
specificneeds2 <- dcast(specificneeds,CaseNo ~  SPNeeds, value.var = "CaseNo", fun.aggregate = lenght )

cases <- merge( x = cases, y = specificneeds2, by = "CaseNo", all.x = TRUE )

## clean
rm(dependency, capacity, specificneeds, specificneeds2,
   passw, user, progres, dbhandleprogres,
   query1, query2, query3)
####################################################################################################
## Join with Survey
####################################################################################################
cat("Joining on table from survey with observed vulnerability category")

train <- read.csv("train.csv")

## Targeting on phase2
train_table <-  merge(x = cases, y = train , by = "CaseNo", all.y = TRUE)

## Convert all character variable into factor in one line:
library(dplyr)
train_table <- train_table %>% mutate_if(is.character, as.factor)
train_table <- train_table %>% mutate_if(is.integer, as.factor)
#str(train_table)

train_table_na <- train_table[, colSums(is.na(train_table)) == 0]
#str(train_table_na)



prediction_df <- train_table_na

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
library(randomForest)



forest_model <- randomForest(unconditionnal2 ~ ., data = train_table_na,
                             nTree = 8,
                             maxDepth = 32,
                             mTry = 35,
                             seed = 5)
## save this model
save(forest_model, file = "forest_model.rda")



forest_prediction <- as.data.frame(predict(forest_model, newdata = prediction_df,
                                           type = "prob",
                                           overwrite = TRUE))

names(forest_prediction) <- c("Forest_Probability_Class_0",
                              "Forest_Probability_Class_1",
                              "Forest_Probability_Class_2")
forest_prediction$Forest_Prediction <- predict(forest_model, newdata = prediction_df)

forest_metrics <- evaluate_model(observed = prediction_df$unconditionnal2,
                                 predicted = forest_prediction$Forest_Prediction)
####################################################################################################
## Stochastic Gradient Boosted Decision Trees modeling
####################################################################################################
# install.packages("gbm")
library(gbm)
boosted_model <- gbm(unconditionnal2 ~ ., data = train_table_na,
                     distribution = "gaussian",
                     n.trees = 10000,
                     shrinkage = 0.01,
                     interaction.depth = 4)
## save this model
save(boosted_model, file = "boosted_model.rda")

boosted_prediction <- predict(boosted_model, newdata = prediction_df,
                              n.trees = 10000,
                              type = "response",
                              overwrite = TRUE)

boosted_prediction2 <- predict(boosted_model, newdata = prediction_df,
                               n.trees = 10000,
                               type = "link",
                               overwrite = TRUE)

names(boosted_prediction) <- c("Boosted_Probability_Class_0",
                               "Boosted_Probability_Class_1",
                               "Boosted_Probability_Class_2")

#boosted_prediction$Boosted_Prediction <- predict(boosted_model, newdata = prediction_df)

boosted_metrics <- evaluate_model(observed = prediction_df$unconditionnal2,
                                  predicted = boosted_prediction$Boosted_Prediction)
####################################################################################################
## Multinomial modeling
####################################################################################################
# install.packages("nnet")
library(nnet)

multinomial_model <- multinom(unconditionnal2 ~ ., data = train_table, MaxNWts = 100000)

## Stepwsise variable selection
multinomial_modelstep <- step(multinomial_model, trace = 0)

## save this model
save(multinomial_model, file = "multinomial_model.rda")
save(multinomial_modelstep, file = "multinomial_modelstep.rda")

mnet_prediction <- predict(object = multinomial_model,
                           newdata = prediction_df,
                           type = "prob")
mnet_prediction <- as.data.frame(mnet_prediction)
names(mnet_prediction) <- c("Multinomial_Probability_Class_0",
                            "Multinomial_Probability_Class_1",
                            "Multinomial_Probability_Class_2")

mnet_prediction_response <- predict(object = multinomial_model, newdata = prediction_df)

mnet_prediction_response <- as.data.frame(mnet_prediction_response)
names(mnet_prediction_response) <- "Multinomial_Prediction"
mnet_prediction <- cbind(mnet_prediction, mnet_prediction_response)

multinomial_metrics <- evaluate_model(observed = prediction_df$unconditionnal2,
                                      predicted = mnet_prediction$Multinomial_Prediction)
####################################################################################################
## Neural network regression modeling
####################################################################################################
# install.packages("nnet")
library(nnet)

#nodes <- 10
#weights <- nodes * (35 + 3) + nodes + 3

nnet_model <- nnet(unconditionnal2 ~ ., data = train_table,
                   ### Wts = rep(0.1, weights),
                   size = nodes,
                   decay = 0.005,
                   maxit = 100,
                   ## MaxNWts = weights),
                   MaxNWts = 100000)
## save this model
save(nnet_model, file = "nnet_model.rda")

## Prediction
nnet_prediction <- predict(object = nnet_model,
                           newdata = prediction_df,
                           type = "raw")
nnet_prediction <- as.data.frame(nnet_prediction)
names(nnet_prediction) <- c("Nnet_Probability_Class_0",
                            "Nnet_Probability_Class_1",
                            "Nnet_Probability_Class_2")

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
main <- getwd()

predictions <- cbind(prediction_df$unconditionnal2, forest_prediction,
                     boosted_prediction, mnet_prediction, nnet_prediction)


write.csv(predictions , paste0(main, "/predictions", format(Sys.time(), "%m-%d-%Y"),".csv"))


metrics_df <- rbind(forest_metrics, boosted_metrics, multinomial_metrics, nnet_metrics)
metrics_df <- as.data.frame(metrics_df)
rownames(metrics_df) <- NULL
Algorithms <- c("Decision Forest",
                "Boosted Decision Tree",
                "Multinomial",
                "Neural Network")
metrics_df <- cbind(Algorithms, metrics_df)

write.csv(metrics_df , paste0(main, "/metrics_df", format(Sys.time(), "%m-%d-%Y"),".csv"))

rm(list = ls())
