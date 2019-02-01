#install.packages("RODBC")
library(RODBC)

#########################################
## Db handle for progres registration DB
#########################################
source("pass.R")
## Create a file name pass with credentials to log into the registration database
# progres <- "..." ## Name of the ODBC connection to the DB - needs to be created before
## user <- "..."  ### Advised to use a read-only user
## passw <- "..."

cat("Connecting to the server")
dbhandleprogres <- odbcConnect(progres, uid = user, pwd = passw)
source("extract-query.R")

## fetching the view containing information aggregated at the case level and the event
cat("Executing the summary table creation within proGres")
progres.case <- sqlQuery(dbhandleprogres, query)

## fetching the view containing information aggregated at the case level and the event
cat("Fetching table to apply prediction")
progres.case <-  sqlFetch(dbhandleprogres, "caseprofile")

## Now format the data so that compatible with what the model will ingest --




####################################################################################################
## Decision forest modeling
####################################################################################################
# install.packages("randomForest")
library(randomForest)
load("forest_model.rda")
forest_prediction <- as.data.frame(predict(forest_model, newdata = prediction_df,
                                           type = "prob",
                                           overwrite = TRUE))

names(forest_prediction) <- c("Forest_Probability_Class_0",
                              "Forest_Probability_Class_1",
                              "Forest_Probability_Class_2")
forest_prediction$Forest_Prediction <- predict(forest_model, newdata = prediction_df)


####################################################################################################
## Stochastic Gradient Boosted Decision Trees modeling
####################################################################################################
# install.packages("gbm")
library(gbm)
load("boosted_model.rda")

boosted_prediction <- predict(boosted_model, newdata = prediction_df,
                                type = "prob",
                                overwrite = TRUE)

names(boosted_prediction) <- c("Boosted_Probability_Class_0",
                               "Boosted_Probability_Class_1",
                               "Boosted_Probability_Class_2")

boosted_prediction$Boosted_Prediction <- predict(boosted_model, newdata = prediction_df)



####################################################################################################
## Neural network regression modeling
####################################################################################################
# install.packages("nnet")
library(nnet)
load("nnet_model.rda")
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


####################################################################################################
## Multinomial modeling
####################################################################################################
# install.packages("nnet")
library(nnet)
load("multinomial_model.rda")
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



cat("Saving Results")
main <- getwd()
write.csv(progres.case , paste0(main, "/progrescase-target", format(Sys.time(), "%m-%d-%Y"),".csv"))

