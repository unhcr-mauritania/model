### ProGres extraction query
## Compile the main characteristics of an household
## Socio-economic factors recorded in ProcessingGroup Softfield


### Query to get information on dependency

query1 <- "SELECT  PP.ProcessingGroupNumber CaseNo,
COUNT(DISTINCT II.IndividualGUID) Num_Inds,
--AVG(II.IndividualAge) AVG_Age,
--STDEV(II.IndividualAge) STDEV_Age,
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
WHERE ProcessStatusCode IN('A') GROUP BY ProcessingGroupNumber;"

### Query to get information on capacity of head of household
# + socio eco indic recorded in process group soft field

query2 <- "SELECT P.ProcessingGroupNumber CaseNo,
P.ProcessingGroupSize Num_Inds1,
IPG.RelationshipToPrincipalRepresentative Relationship,
IPG.PrincipalRepresentative Relationshippa,
I.OriginCountryCode CountryOrigin,
I.NationalityCode dem_birth_country,
DATENAME(mm, I.ArrivalDate) Montharrival,
DATENAME(yyyy, I.ArrivalDate) YearArrival,
I.SexCode dem_sex,
I.IndividualAge dem_age,
I.IndividualAgeCohortCode dem_agegroup,
I.MarriageStatusCode dem_marriage,
I.EducationLevelCode edu_highest,
I.SPNeeds,
I.HasSPNeed,
I.OccupationCode occupationcode,
J.LocationLevel5Description coal5,
J.LocationLevel5ID coal5id,
s.ProcessingGroupNumberSoftfield1,
s.ProcessingGroupNumberSoftfield2,
s.ProcessingGroupNumberSoftfield3,
s.ProcessingGroupNumberSoftfield4,
s.ProcessingGroupFlagSoftfield1,
s.ProcessingGroupFlagSoftfield2,
s.ProcessingGroupFlagSoftfield3,
s.ProcessingGroupFlagSoftfield4,
s.ProcessingGroupFlagSoftfield5,
s.ProcessingGroupFlagSoftfield6,
s.ProcessingGroupCodeSoftfield1,
s.ProcessingGroupCodeSoftfield2,
s.ProcessingGroupCodeSoftfield3,
s.ProcessingGroupCodeSoftfield4,
s.ProcessingGroupCodeSoftfield5

FROM dbo.dataProcessGroup AS P

INNER JOIN dbo.dataIndividualProcessGroup AS IPG ON P.ProcessingGroupGUID = IPG.ProcessingGroupGUID
INNER JOIN dbo.dataIndividual AS I ON IPG.IndividualGUID = I.IndividualGUID
INNER JOIN dbo.vdataAddressCOA AS J ON IPG.IndividualGUID = J.IndividualGUID
INNER JOIN dbo.dataProcessGroupSoftFields s ON P.ProcessingGroupGUID = s.ProcessingGroupGUID
LEFT OUTER JOIN dbo.dataProcessGroupPhyFile AS PGF ON PGF.ProcessingGroupGUID = P.ProcessingGroupGUID
WHERE I.ProcessStatusCode = 'A' AND IPG.PrincipalRepresentative = 1"

## Query 3: information on specific needs
query3 <- "SELECT
I.VulnerabilityDetailsCode as SPNeeds,
P.ProcessingGroupNumber CaseNo --Colums to pivot
FROM  dataVulnerability as I
INNER JOIN dbo.dataIndividual AS II ON I.IndividualGUID = II.IndividualGUID
INNER JOIN dbo.dataIndividualProcessGroup AS IPG ON IPG.IndividualGUID = II.IndividualGUID
INNER JOIN dbo.dataProcessGroup AS P  ON P.ProcessingGroupGUID = IPG.ProcessingGroupGUID
WHERE I.VulnerabilityActive = 1"
