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

dbhandleprogres <- odbcConnect(progres, uid=user, pwd=passw)

query <- "SELECT  PP.ProcessingGroupNumber CaseNo,
COUNT(DISTINCT II.IndividualGUID) Num_Inds,
AVG(II.IndividualAge) AVG_Age,
STDEV(II.IndividualAge) STDEV_Age,
Count( CASE WHEN(II.IndividualAge < 15) THEN(II.IndividualGUID) ELSE(NULL) END) Child_0_14,
Count( CASE WHEN(II.IndividualAge < 19 AND IndividualAge > 14) THEN(II.IndividualGUID) ELSE(NULL) END) Youth_15_17,
Count( CASE WHEN(II.IndividualAge < 65 AND IndividualAge > 14) THEN(II.IndividualGUID) ELSE(NULL) END) Work_15_64,
Count( CASE WHEN(II.IndividualAge > 64) THEN(II.IndividualGUID) ELSE(NULL) END) Eldern_65,
Count( CASE WHEN(II.SexCode = 'M') THEN(SexCode) ELSE(NULL) END) Male,
Count( CASE WHEN(II.SexCode = 'F') THEN(SexCode) ELSE(NULL) END) Female,
Count( CASE WHEN(II.SexCode not in  ('F','M')) THEN('Empty')  END) NOGender,
Count( CASE WHEN(IPGG.RelationshipToPrincipalRepresentative ='HUS' or IPGG.RelationshipToPrincipalRepresentative ='EXM' or IPGG.RelationshipToPrincipalRepresentative ='WIF'
or IPGG.RelationshipToPrincipalRepresentative ='EXF' or IPGG.RelationshipToPrincipalRepresentative ='CLH' or IPGG.RelationshipToPrincipalRepresentative ='CLW') THEN(II.IndividualGUID) ELSE(NULL) END) couple,
Count( CASE WHEN(IPGG.RelationshipToPrincipalRepresentative ='SCF' or IPGG.RelationshipToPrincipalRepresentative ='SCM' or IPGG.RelationshipToPrincipalRepresentative ='FCF'
or IPGG.RelationshipToPrincipalRepresentative ='FCM' or IPGG.RelationshipToPrincipalRepresentative ='SON' or IPGG.RelationshipToPrincipalRepresentative ='DAU' and II.IndividualAge < 19) THEN(II.IndividualGUID) ELSE(NULL) END) minordependant

FROM dbo.dataProcessGroup AS PP
INNER JOIN dbo.dataIndividualProcessGroup AS IPGG ON PP.ProcessingGroupGUID = IPGG.ProcessingGroupGUID
INNER JOIN dbo.dataIndividual AS II ON IPGG.IndividualGUID = II.IndividualGUID
WHERE ProcessStatusCode IN('A') GROUP BY ProcessingGroupNumber"

## fetching the view containing information aggregated at the case level and the event
progres.case <- sqlQuery(dbhandleprogres, query)

main <- getwd()

write.csv(progres.case , paste0(main, "/progrescase-target", format(Sys.time(), "%m-%d-%Y"),".csv"))

## Now format the data so that i can be compatiable with what the model will ingest --


## Load and run the model
#load("prioritisation.rda")