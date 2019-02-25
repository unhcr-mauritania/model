### ProGres extraction query
## Compile the main characteristics of an household
## Socio-economic factors recorded in ProcessingGroup Softfield


### Query to get information on dependency

removeLineBreak <- function (x) gsub("[\n]", " ", x)

query1 <- removeLineBreak( 
  "SELECT  PP.ProcessingGroupNumber CaseNo, 
  COUNT(DISTINCT II.IndividualGUID) Num_Inds, 
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
  WHERE ProcessStatusCode IN('A') GROUP BY ProcessingGroupNumber " )


##Property  

query2 <- removeLineBreak ("SELECT 
                           P.ProcessingGroupNumber CaseNo,
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
                           J.LocationLevel5Description coal5,
                           J.LocationLevel5ID coal5id,
                           sum(case when prop.PropertyTypeCode = '001' then prop.PropertyConditionCode else 0 end) as possede_voiture,
                           sum(case when prop.PropertyTypeCode = '002' then prop.PropertyConditionCode else 0 end) as possede_moto,
                           sum(case when prop.PropertyTypeCode = '003' then prop.PropertyConditionCode else 0 end) as possede_Charrette,
                           sum(case when prop.PropertyTypeCode = '004' then prop.PropertyConditionCode else 0 end) as possede_panneaux,
                           sum(case when prop.PropertyTypeCode = '005' then prop.PropertyConditionCode else 0 end) as possede_Bijoux,
                           sum(case when prop.PropertyTypeCode = '006' then prop.PropertyConditionCode else 0 end) as possede_Radio, 
                           sum(case when prop.PropertyTypeCode = '007' then prop.PropertyConditionCode else 0 end) as possede_Ordinateur, 
                           sum(case when prop.PropertyTypeCode = '008' then prop.PropertyConditionCode else 0 end) as possede_Meuble, 
                           sum(case when prop.PropertyTypeCode = '009' then prop.PropertyConditionCode else 0 end) as possede_asins,
                           sum(case when prop.PropertyTypeCode = '010' then prop.PropertyConditionCode else 0 end) as possede_ovin,
                           sum(case when prop.PropertyTypeCode = '020' then prop.PropertyConditionCode else 0 end) as possede_caprin,
                           sum(case when prop.PropertyTypeCode = '030' then prop.PropertyConditionCode else 0 end) as possede_bovin, 
                           sum(case when prop.PropertyTypeCode = '040' then prop.PropertyConditionCode else 0 end) as possede_camelin
                           FROM dbo.dataProcessGroup AS P
                           INNER JOIN dbo.dataIndividualProcessGroup AS IPG ON P.ProcessingGroupGUID = IPG.ProcessingGroupGUID
                           INNER JOIN dbo.dataIndividual AS I ON IPG.IndividualGUID = I.IndividualGUID
                           INNER JOIN dbo.vdataAddressCOA AS J ON IPG.IndividualGUID = J.IndividualGUID
                           INNER JOIN dbo.dataIndividualSoftFields s ON I.IndividualGUID = s.IndividualGUID
                           LEFT JOIN dbo.dataProperty prop on (I.IndividualGUID = prop.IndividualGUID)
                           WHERE I.ProcessStatusCode = 'A' AND IPG.PrincipalRepresentative = 1
                           group by 
                           P.ProcessingGroupNumber,
                           P.ProcessingGroupSize ,
                           IPG.RelationshipToPrincipalRepresentative ,
                           IPG.PrincipalRepresentative ,
                           I.OriginCountryCode ,
                           I.NationalityCode ,
                           DATENAME(mm, I.ArrivalDate) ,
                           DATENAME(yyyy, I.ArrivalDate) ,
                           I.SexCode ,
                           I.IndividualAge ,
                           I.IndividualAgeCohortCode ,
                           I.MarriageStatusCode ,
                           I.EducationLevelCode ,
                           I.SPNeeds,
                           I.HasSPNeed,
                           I.OccupationCode ,
                           J.LocationLevel5Description ,
                           J.LocationLevel5ID ")

## Occupation

query3 <- removeLineBreak  ("Select I.IndividualGUID , P.ProcessingGroupNumber CaseNo , 
                            case when sum(case when  SUBSTRING (Occ.OccupationCode , 1 , 1) in ('1') and EmploymentCountry = 'MAU' then 1 else 0 end) > 0 then 'yes' else 'no' end as Manager , 
                            case when sum(case when  SUBSTRING (Occ.OccupationCode , 1 , 1) in ('2') and EmploymentCountry = 'MAU' then 1 else 0 end) > 0 then 'yes' else 'no' end as Professional ,
                            case when sum(case when  SUBSTRING (Occ.OccupationCode , 1 , 1) in ('3') and EmploymentCountry = 'MAU' then 1 else 0 end) > 0 then 'yes' else 'no' end as Technician ,
                            case when sum(case when  SUBSTRING (Occ.OccupationCode , 1 , 1) in ('4') and EmploymentCountry = 'MAU' then 1 else 0 end) > 0 then 'yes' else 'no' end as Clerk ,
                            case when sum(case when  SUBSTRING (Occ.OccupationCode , 1 , 1) in ('5') and EmploymentCountry = 'MAU' then 1 else 0 end) > 0 then 'yes' else 'no' end as ServiceMarket ,
                            case when sum(case when  SUBSTRING (Occ.OccupationCode , 1 , 1) in ('6') and EmploymentCountry = 'MAU' then 1 else 0 end) > 0 then 'yes' else 'no' end as Agricultural ,
                            case when sum(case when  SUBSTRING (Occ.OccupationCode , 1 , 1) in ('7') and EmploymentCountry = 'MAU' then 1 else 0 end) > 0 then 'yes' else 'no' end as Craft ,
                            case when sum(case when  SUBSTRING (Occ.OccupationCode , 1 , 1) in ('8') and EmploymentCountry = 'MAU' then 1 else 0 end) > 0 then 'yes' else 'no' end as Machine ,
                            case when sum(case when  SUBSTRING (Occ.OccupationCode , 1 , 1) in ('9') and EmploymentCountry = 'MAU' then 1 else 0 end) > 0 then 'yes' else 'no' end as Elementary ,
                            case when sum(case when  Occ.OccupationCode = '0001' then 1 else 0 end) > 0 then 'yes' else 'no' end as Student ,
                            case when sum(case when (Occ.OccupationCode = '-' or Occ.OccupationCode = 'U' or Occ.OccupationCode is null or Occ.OccupationCode = 'None') then 1 else 0 end) > 0 then 'yes' else 'no' end as NoOccup_or_Unkown
                            FROM dbo.dataProcessGroup AS P
                            INNER JOIN dbo.dataIndividualProcessGroup AS IPG ON P.ProcessingGroupGUID = IPG.ProcessingGroupGUID
                            INNER JOIN dbo.dataIndividual AS I ON IPG.IndividualGUID = I.IndividualGUID 
                            LEFT OUTER JOIN dbo.dataEmployment Occ on I.IndividualGUID = Occ.IndividualGUID
                            WHERE I.ProcessStatusCode = 'A' AND IPG.PrincipalRepresentative = 1 and (Occ.EmploymentCountry = 'MAU' or Occ.EmploymentCountry is null)
                            group by I.IndividualGUID , P.ProcessingGroupNumber
                            
                            Union
                            
                            Select I.IndividualGUID , P.ProcessingGroupNumber CaseNo , 
                            'no' Manager , 
                            'no' Professional ,
                            'no' Technician ,
                            'no' Clerk ,
                            'no' ServiceMarket ,
                            'no' Agricultural ,
                            'no' Craft ,
                            'no' Machine ,
                            'no' Elementary ,
                            'no' Student ,
                            'yes' NoOccup_or_Unkown
                            FROM dbo.dataProcessGroup AS P
                            INNER JOIN dbo.dataIndividualProcessGroup AS IPG ON P.ProcessingGroupGUID = IPG.ProcessingGroupGUID
                            INNER JOIN dbo.dataIndividual AS I ON IPG.IndividualGUID = I.IndividualGUID 
                            LEFT OUTER JOIN dbo.dataEmployment Occ on I.IndividualGUID = Occ.IndividualGUID
                            WHERE I.ProcessStatusCode = 'A' AND IPG.PrincipalRepresentative = 1 and (Occ.EmploymentCountry <> 'MAU') and I.IndividualGUID Not in 
                            (Select I.IndividualGUID
                            FROM dbo.dataProcessGroup AS P
                            INNER JOIN dbo.dataIndividualProcessGroup AS IPG ON P.ProcessingGroupGUID = IPG.ProcessingGroupGUID
                            INNER JOIN dbo.dataIndividual AS I ON IPG.IndividualGUID = I.IndividualGUID 
                            LEFT OUTER JOIN dbo.dataEmployment Occ on I.IndividualGUID = Occ.IndividualGUID
                            WHERE I.ProcessStatusCode = 'A' AND IPG.PrincipalRepresentative = 1 and (Occ.EmploymentCountry = 'MAU' or Occ.EmploymentCountry is null)
                            group by I.IndividualGUID  )
                            group by I.IndividualGUID , P.ProcessingGroupNumber")

## Soft field 2 , Moyen D'existence 
query4 <- removeLineBreak("Select I.IndividualGUID , P.ProcessingGroupNumber CaseNo , 
                          Case when soft.IndividualCodeSoftfield2 = '001' then 'yes' else 'no' end Revenue1_Sell_Agriculture_Prod,
                          Case when soft.IndividualCodeSoftfield2 = '002' then 'yes' else 'no' end Revenue1_Salari,
                          Case when soft.IndividualCodeSoftfield2 = '003' then 'yes' else 'no' end Revenue1_transfer_from_abroad,
                          Case when soft.IndividualCodeSoftfield2 = '004' then 'yes' else 'no' end Revenue1_Borrowing,
                          Case when soft.IndividualCodeSoftfield2 = '005' then 'yes' else 'no' end Revenue1_Begging,
                          Case when soft.IndividualCodeSoftfield2 = '006' then 'yes' else 'no' end Revenue1_Sell_Assistance,
                          Case when soft.IndividualCodeSoftfield2 = '007' then 'yes' else 'no' end Revenue1_Work_for_Humanitarian_Org,
                          Case when soft.IndividualCodeSoftfield2 = '008' then 'yes' else 'no' end Revenue1_Transfer,
                          Case when soft.IndividualCodeSoftfield2 = '009' then 'yes' else 'no' end Revenue1_Cash_transfer_state,
                          Case when soft.IndividualCodeSoftfield2 = '010' then 'yes' else 'no' end Revenue1_Prostitution
                          from 
                          dbo.dataProcessGroup AS P
                          INNER JOIN dbo.dataIndividualProcessGroup AS IPG ON P.ProcessingGroupGUID = IPG.ProcessingGroupGUID
                          INNER JOIN dbo.dataIndividual AS I ON IPG.IndividualGUID = I.IndividualGUID 
                          LEFT OUTER JOIN dbo.dataIndividualSoftFields soft on I.IndividualGUID = soft.IndividualGUID
                          WHERE I.ProcessStatusCode = 'A' AND IPG.PrincipalRepresentative = 1")


## Soft field 3 , Moyen D'existence 
query5 <- "Select I.IndividualGUID , P.ProcessingGroupNumber CaseNo , 
Case when soft.IndividualCodeSoftfield3 = '001' then 'yes' else 'no' end Revenue2_Sell_Agriculture_Prod,
Case when soft.IndividualCodeSoftfield3 = '002' then 'yes' else 'no' end Revenue2_Salari,
Case when soft.IndividualCodeSoftfield3 = '003' then 'yes' else 'no' end Revenue2_transfer_from_abroad,
Case when soft.IndividualCodeSoftfield3 = '004' then 'yes' else 'no' end Revenue2_Borrowing,
Case when soft.IndividualCodeSoftfield3 = '005' then 'yes' else 'no' end Revenue2_Begging,
Case when soft.IndividualCodeSoftfield3 = '006' then 'yes' else 'no' end Revenue2_Sell_Assistance,
Case when soft.IndividualCodeSoftfield3 = '007' then 'yes' else 'no' end Revenue2_Work_for_Humanitarian_Org,
Case when soft.IndividualCodeSoftfield3 = '008' then 'yes' else 'no' end Revenue2_Transfer,
Case when soft.IndividualCodeSoftfield3 = '009' then 'yes' else 'no' end Revenue2_Cash_transfer_state,
Case when soft.IndividualCodeSoftfield3 = '010' then 'yes' else 'no' end Revenue2_Prostitution
from 
dbo.dataProcessGroup AS P
INNER JOIN dbo.dataIndividualProcessGroup AS IPG ON P.ProcessingGroupGUID = IPG.ProcessingGroupGUID
INNER JOIN dbo.dataIndividual AS I ON IPG.IndividualGUID = I.IndividualGUID 
LEFT OUTER JOIN dbo.dataIndividualSoftFields soft on I.IndividualGUID = soft.IndividualGUID
WHERE I.ProcessStatusCode = 'A' AND IPG.PrincipalRepresentative = 1 "


## ## Query 3: information on specific needs
query6 <- removeLineBreak ("SELECT
                           I.VulnerabilityDetailsCode as SPNeeds,
                           P.ProcessingGroupNumber CaseNo 
                           FROM  dataVulnerability as I
                           INNER JOIN dbo.dataIndividual AS II ON I.IndividualGUID = II.IndividualGUID
                           INNER JOIN dbo.dataIndividualProcessGroup AS IPG ON IPG.IndividualGUID = II.IndividualGUID
                           INNER JOIN dbo.dataProcessGroup AS P  ON P.ProcessingGroupGUID = IPG.ProcessingGroupGUID
                           WHERE I.VulnerabilityActive = 1")


## Query 4: Information on absentees during GFD
query7 <- removeLineBreak ("SELECT dataProcessGroup.ProcessingGroupNumber  CaseNo,
                           dataEventLog.EventID, dataEventLog.EventLogstatus, dataEventLog.Comments
                           FROM  dataEventLog INNER JOIN
                           dataProcessGroup ON dataEventLog.ProcessingGroupGUID = dataProcessGroup.ProcessingGroupGUID
                           WHERE (dataEventLog.EventID = N'AST36') AND (dataEventLog.EventLogstatus = N'c')")
