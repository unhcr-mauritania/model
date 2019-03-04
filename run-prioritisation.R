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

##remove rows which have empty values:
row.has.na  <- apply(cases2, 1, function(x){any(is.na(x))})
cases2 <- cases2[!row.has.na, ]

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

## further split using apportion  based on initial population segment -
data <- cases2target
# **Emergent** -  12%
# **Catalyst** -  2%
## so top 14 % of full allocation
data.full <- data[data$predicted.target == "full.allocation", c("CaseNo", "predicted.prob")]
data.full$predicted.target.centile <- ntile(data.full$predicted.prob, 100)
data.full$predicted.target.sub <- ifelse(data.full$predicted.target.centile >= 14, "full.top14pc","full.tail86pc")
# **Unstable** -  11%
# **Fragile** -  19%
## so top 36 % of full allocation
data.reduc <- data[data$predicted.target == "reduced.allocation", c("CaseNo", "predicted.prob")]
data.reduc$predicted.target.centile <- ntile(data.reduc$predicted.prob, 100)
data.reduc$predicted.target.sub <- ifelse(data.reduc$predicted.target.centile >= 36, "reduc.top36pc","reduc.tail64pc")

# **Destitute** -  34%
# **Insecure** -  22%
## so top 39 % of full allocation
data.no <- data[data$predicted.target == "no.allocation", c("CaseNo", "predicted.prob")]
data.no$predicted.target.centile <- ntile(data.no$predicted.prob, 100)
data.no$predicted.target.sub <- ifelse(data.no$predicted.target.centile >= 39, "no.top39pc","no.tail61pc")

datasub <- rbind(data.no, data.full, data.reduc)
datasub <- datasub[ ,c("caseNo", "predicted.target.sub")]
cases2target <- merge( x = cases2target, y = datasub, by = "caseNo", all.x = TRUE )


prop.table(table(forest_prediction$predicted.target, useNA = "ifany"))
table(forest_prediction$predicted.target, useNA = "ifany")

cat("Saving Results for records. \n")
main <- getwd()
write.csv(cases2target , paste0(main, "/progrescase-target", format(Sys.time(), "%m-%d-%Y"),".csv"), row.names = FALSE)


cat("Saving Results for report. \n")
write.csv(cbind(cases, cases2target) , paste0(main, "/progrescase-last.csv"), row.names = FALSE)

