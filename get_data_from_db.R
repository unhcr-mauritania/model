
#install.packages("RODBC")
#library(RODBC)

#########################################
## Db handle for proGres Registration
#########################################

## Create a distinct file name pass.R and write down credentials to log into the registration database
# progres <- "..." ## Name of the ODBC connection to the DB - needs to be created before
## user <- "..."  ### Advised to use a read-only user
## passw <- "..."
source("pass.R")

cat("Connecting to the server \n")
dbhandleprogres <- odbcConnect(progres, uid=user, pwd=passw)
source("extract-query.R")

## fetching the view containing information aggregated at the case level and the event
cat("Executing the summary table creation within proGres. \n")
dependency <- sqlQuery(dbhandleprogres, query1)
capacity <- sqlQuery(dbhandleprogres, query2)
specificneeds <- sqlQuery(dbhandleprogres, query3)
AbsenteesGFD <- sqlQuery(dbhandleprogres, query4)

names (AbsenteesGFD)
cases <- merge( x = dependency, y = capacity, by = "CaseNo" )

## install.packages("reshape2")
#library(reshape2)
specificneeds2 <- dcast(specificneeds, CaseNo ~  SPNeeds, value.var = "CaseNo" )

cases <- merge( x = cases, y = specificneeds2, by = "CaseNo", all.x = TRUE )

#library(reshape2)
AbsenteesGFD2 <- dcast(AbsenteesGFD, CaseNo ~  EventID, value.var = "CaseNo" )

cases <- merge( x = cases, y = AbsenteesGFD2, by = "CaseNo", all.x = TRUE )

## clean folder
rm(dependency, capacity, specificneeds, specificneeds2, AbsenteesGFD2,
   passw, user, progres, dbhandleprogres,
   query1, query2, query3, query4)
