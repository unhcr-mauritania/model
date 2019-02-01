### ProGres extraction query
## Compile the main characteristics of an household
## Socio-economic factors recorded in ProcessingGroup Softfield

query <- "DROP TABLE IF EXISTS AnalysisCaseprofile1;

SELECT  PP.ProcessingGroupNumber CaseNo,
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
INTO [dbo].[AnalysisCaseprofile1]
FROM dbo.dataProcessGroup AS PP
INNER JOIN dbo.dataIndividualProcessGroup AS IPGG ON PP.ProcessingGroupGUID = IPGG.ProcessingGroupGUID
INNER JOIN dbo.dataIndividual AS II ON IPGG.IndividualGUID = II.IndividualGUID
WHERE ProcessStatusCode IN('A') GROUP BY ProcessingGroupNumber;


DROP TABLE IF EXISTS AnalysisCaseprofile2;

SELECT P.ProcessingGroupNumber CaseNo,
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

INTO [dbo].[AnalysisCaseprofile2]
FROM dbo.dataProcessGroup AS P

INNER JOIN dbo.dataIndividualProcessGroup AS IPG ON P.ProcessingGroupGUID = IPG.ProcessingGroupGUID
INNER JOIN dbo.dataIndividual AS I ON IPG.IndividualGUID = I.IndividualGUID
INNER JOIN dbo.vdataAddressCOA AS J ON IPG.IndividualGUID = J.IndividualGUID
INNER JOIN dbo.dataProcessGroupSoftFields s ON P.ProcessingGroupGUID = s.ProcessingGroupGUID
LEFT OUTER JOIN dbo.dataProcessGroupPhyFile AS PGF ON PGF.ProcessingGroupGUID = P.ProcessingGroupGUID
WHERE I.ProcessStatusCode = 'A' AND IPG.PrincipalRepresentative = 1


DROP TABLE IF EXISTS AnalysisCaseprofile;


SELECT P.CaseNo,
P.Num_Inds1,
P.Relationship,
P.Relationshippa,
P.CountryOrigin,
P.dem_birth_country,
P.Montharrival,
P.YearArrival,
P.dem_sex,
P.dem_age,
P.dem_agegroup,
P.dem_ethn,
P.dem_religion,
P.dem_marriage,
P.edu_highest,

P.SPNeeds,
P.HasSPNeed,
P.occupationcode,
P.coal5,
P.coal5id,
Cal_1.Num_Inds,
Cal_1.Child_0_14,
Cal_1.Youth_15_17,
Cal_1.Work_15_64,
Cal_1.Eldern_65,
Cal_1.Male,
Cal_1.Female,
Cal_1.NOGender,
Cal_1.couple,
Cal_1.minordependant,

P.ProcessingGroupNumberSoftfield1,
P.ProcessingGroupNumberSoftfield2,
P.ProcessingGroupNumberSoftfield3,
P.ProcessingGroupNumberSoftfield4,
P.ProcessingGroupFlagSoftfield1,
P.ProcessingGroupFlagSoftfield2,
P.ProcessingGroupFlagSoftfield3,
P.ProcessingGroupFlagSoftfield4,
P.ProcessingGroupFlagSoftfield5,
P.ProcessingGroupFlagSoftfield6,
P.ProcessingGroupCodeSoftfield1,
P.ProcessingGroupCodeSoftfield2,
P.ProcessingGroupCodeSoftfield3,
P.ProcessingGroupCodeSoftfield4,
P.ProcessingGroupCodeSoftfield5

INTO [dbo].[AnalysisCaseprofile]
FROM AnalysisCaseprofile2 as P
LEFT JOIN AnalysisCaseprofile1 AS Cal_1  ON P.CaseNo = Cal_1.CaseNo

DROP TABLE IF EXISTS AnalysisCaseprofile1;
DROP TABLE IF EXISTS AnalysisCaseprofile2;


DROP TABLE IF EXISTS AnalysisCaseprofileneeds;
SELECT *
INTO [dbo].[AnalysisCaseprofileneeds]
FROM
(SELECT I.IndividualGUID,
I.VulnerabilityDetailsCode as SPNeeds,
I.VulnerabilityDetailsCode as code,
P.ProcessingGroupNumber CaseNo --Colums to pivot
FROM  dataVulnerability as I
INNER JOIN dbo.dataIndividual AS II ON I.IndividualGUID = II.IndividualGUID
INNER JOIN dbo.dataIndividualProcessGroup AS IPG ON IPG.IndividualGUID = II.IndividualGUID
INNER JOIN dbo.dataProcessGroup AS P  ON P.ProcessingGroupGUID = IPG.ProcessingGroupGUID
WHERE I.VulnerabilityActive = 1
AND VulnerabilityDetailsCode in (
'CR', 'CR-AF', 'CR-CC', 'CR-CH', 'CR-CL', 'CR-CP', 'CR-CS', 'CR-LO', 'CR-LW', 'CR-MS', 'CR-NE', 'CR-SE', 'CR-TP',

'DS', 'DS-BD', 'DS-DF', 'DS-MM', 'DS-MS', 'DS-PM','DS-PS', 'DS-SD',

'ER', 'ER-FR', 'ER-MC', 'ER-NF', 'ER-OC', 'ER-SC', 'ER-UR',
-- 'FU', 'FU-FR', 'FU-TR',
--'LP', 'LP-AF', 'LP-AN', 'LP-AP', 'LP-BN', 'LP-CR', 'LP-DA', 'LP-DN', 'LP-DO', 'LP-DP', 'LP-DT', 'LP-ES',
-- 'LP-FR', 'LP-IH', 'LP-LS', 'LP-MD', 'LP-MM', 'LP-MS', 'LP-NA', 'LP-ND', 'LP-PV', 'LP-RD', 'LP-RP', 'LP-RR',
-- 'LP-ST', 'LP-TA', 'LP-TC', 'LP-TD', 'LP-TO', 'LP-TR', 'LP-UP', 'LP-VA', 'LP-VF', 'LP-VO', 'LP-VP', 'LP-WP',
-- 'PG', 'PG-HR', 'PG-LC',
'SC', 'SC-CH', 'SC-FC', 'SC-IC', 'SC-NC', 'SC-SC', 'SC-UC', 'SC-UF', 'SC-UM',
'SM', 'SM-AD', 'SM-CC', 'SM-CI', 'SM-DP', 'SM-MI', 'SM-MN', 'SM-OT',
'SP', 'SP-CG', 'SP-GP', 'SP-PT'--,
-- 'SV', 'SV-FM', 'SV-GM', 'SV-HK', 'SV-HP', 'SV-SS', 'SV-VA', 'SV-VF', 'SV-VO', 'TR', 'TR-HO', 'TR-PI',
-- 'TR-WV', 'WR', 'WR-GM', 'WR-HR',
--'WR-LC', 'WR-PY', 'WR-SF', 'WR-UW', 'WR-WF', 'WR-WR'
))
as sourcetable
pivot(
COUNT(IndividualGUID) --Pivot on this column
for SPNeeds --Make colum where SPNeeds is in one of these.
in([CR], [CR - AF], [CR - CC], [CR - CH], [CR - CL], [CR - CP], [CR - CS], [CR - LO], [CR - LW], [CR - MS], [CR - NE], [CR - SE], [CR - TP],
[DS], [DS - BD], [DS - DF], [DS - MM], [DS - MS], [DS - PM], [DS - PS], [DS - SD],
[ER], [ER - FR], [ER - MC], [ER - NF], [ER - OC], [ER - SC], [ER - UR],
--[FU], [FU - FR], [FU - TR], [LP], [LP - AF], [LP - AN], [LP - AP], [LP - BN],
--[LP - CR], [LP - DA], [LP - DN], [LP - DO], [LP - DP], [LP - DT], [LP - ES], [LP - FR], [LP - IH], [LP - LS], [LP - MD], [LP - MM], [LP - MS], [LP - NA], [LP - ND], [LP - PV], [LP - RD], [LP - RP], [LP - RR], [LP - ST], [LP - TA], [LP - TC], [LP - TD], [LP - TO], [LP - TR], [LP - UP], [LP - VA], [LP - VF], [LP - VO], [LP - VP], [LP - WP], [PG], [PG - HR], [PG - LC],
[SC], [SC - CH], [SC - FC], [SC - IC], [SC - NC], [SC - SC], [SC - UC], [SC - UF], [SC - UM],
[SM], [SM - AD], [SM - CC], [SM - CI], [SM - DP], [SM - MI], [SM - MN], [SM - OT],
[SP], [SP - CG], [SP - GP], [SP - PT], [SV], [SV - FM], [SV - GM], [SV - HK], [SV - HP], [SV - SS], [SV - VA], [SV - VF], [SV - VO]
--, [TR], [TR - HO], [TR - PI], [TR - WV], [WR], [WR - GM], [WR - HR], [WR - LC], [WR - PY], [WR - SF], [WR - UW], [WR - WF], [WR - WR])
)
as CountSpecificNeeds



SELECT *
INTO [dbo].[AnalysisCaseprofilefinal]
FROM AnalysisCaseprofile as P
LEFT JOIN AnalysisCaseprofileneeds AS Cal_1  ON P.CaseNo = Cal_1.CaseNo
DROP TABLE IF EXISTS AnalysisCaseprofileneeds;
DROP TABLE IF EXISTS AnalysisCaseprofile;

"
