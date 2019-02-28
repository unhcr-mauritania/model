####################################################################################################
####################################################################################################
## Extract registry
####################################################################################################
source("get_data_from_db.R")

####################################################################################################
## Feature engineering to reduce number of modalities for good classification
####################################################################################################
## This may need to be adjusted depending on the specific context
cat("Reshaping data. \n")
source("feature.R")

## Convert all character variable into factor in one line:
library(dplyr)
cases2 <- cases2 %>% mutate_if(is.character, as.factor)
cases2 <- cases2 %>% mutate_if(is.integer, as.factor)


## Remove variables with NA
cases2 <- cases2[, colSums(!is.na(cases2)) > 0]

####################################################################################################
## Decision forest modeling
####################################################################################################
# install.packages("randomForest")
cat("Loading model & building prediction. \n")
library(randomForest)
load("forest_model.rda")

forest_prediction <- as.data.frame(predict(forest_model, newdata = cases2,
                                           type = "prob",
                                           overwrite = TRUE))

names(forest_prediction) <- c("full.allocation",
                              "no.allocation",
                              "reduced.allocation")
forest_prediction$predicted.target <- predict(forest_model, newdata = cases2)
forest_prediction$predicted.prob <- ifelse(forest_prediction$predicted.target == "full.allocation", forest_prediction$full.allocation,
                                           ifelse(forest_prediction$predicted.target == "no.allocation", forest_prediction$no.allocation,
                                                  forest_prediction$reduced.allocation))

cases2target <- cbind(cases2,forest_prediction )

prop.table(table(forest_prediction$predicted.target, useNA = "ifany"))
table(forest_prediction$predicted.target, useNA = "ifany")

cat("Saving Results for records. \n")
main <- getwd()
write.csv(cases2target , paste0(main, "/progrescase-target", format(Sys.time(), "%m-%d-%Y"),".csv"), row.names = FALSE)


cat("Saving Results for report. \n")
write.csv(cbind(cases, cases2target) , paste0(main, "/progrescase-last.csv"), row.names = FALSE)

