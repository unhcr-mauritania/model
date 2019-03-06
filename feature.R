
####################################################################################################
## Family Profile
cases$familyprofile <- ""
cases$familyprofile[cases$Num_Inds==1] <- "single"
cases$familyprofile[cases$Num_Inds==2 & cases$couple==1] <- "couple.no.kids"
cases$familyprofile[cases$Num_Inds>1 & cases$nonnuclear==1 & cases$couple==0 & cases$minordependant > 0 ] <- "uniparental.with.kids"
cases$familyprofile[ cases$minordependant > 0 &  cases$nonnuclear ==1 & cases$couple==1 ] <- "couple.with.kids.no.dependant"
cases$familyprofile[ cases$nonnuclear > 1 ] <- "non.nuclear.or.adult.dependant"
cases$familyprofile[cases$familyprofile==""] <- "non.nuclear.or.adult.dependant"
prop.table(table(cases$familyprofile, useNA = "ifany"))

####################################################################################################
## Case size turned into factor
prop.table(table(as.factor(cases$Num_Inds), useNA = "ifany"))
prop.table(table(cut(cases$Num_Inds,   breaks = c(0,1,2,3,4,6,50),include.lowest = TRUE)))
#rm(Case.size)
cases$Case.size <- cut(cases$Num_Inds,
                       breaks = c(0,1,2,3,4,6,50),
                       labels = c("Case.size.1", "Case.size.2", "Case.size.3", "Case.size.4",
                                  "Case.size.5", "Case.size.6.or.more"),include.lowest = TRUE)

####################################################################################################
## Dependency ratio
cases$dependency <-  cut( (cases$Child_0_14+cases$Eldern_65) / cases$Work_15_64, c(0.0001,0.99,1.1,Inf))
prop.table(table(cases$dependency, useNA = "ifany"))
cases$dependency <- as.character(cases$dependency)
cases$dependency[is.na(cases$dependency)]<- "1.no.dependant"
cases$dependency[cases$dependency == "(0.0001,0.99]"] <- "2.few.dependant"
cases$dependency[cases$dependency == "(0.99,1.1]"] <- "3.half.dependant"
cases$dependency[cases$dependency == "(1.1,Inf]"] <- "4.majority.dependant"
prop.table(table(cases$dependency, useNA = "ifany"))

####################################################################################################
## Female ratio
cases$female.ratio <- cut(cases$Female / cases$Num_Inds, c(0.0001,0.45,0.55,0.99,1.1))
prop.table(table(cases$female.ratio, useNA = "ifany"))
cases$female.ratio <- as.character(cases$female.ratio)
cases$female.ratio[is.na(cases$female.ratio)]<- "1.no.female"
cases$female.ratio[cases$female.ratio == "(0.0001,0.45]"] <- "2.few.female"
cases$female.ratio[cases$female.ratio == "(0.45,0.55]"] <- "3.half.female"
cases$female.ratio[cases$female.ratio == "(0.55,0.99]"] <- "4.most.female"
cases$female.ratio[cases$female.ratio == "(0.99,1.1]"] <- "5.all.female"
prop.table(table(cases$female.ratio, useNA = "ifany"))


####################################################################################################
## Extracting main ocupation category from occupation code
prop.table(table(cases$dem_marriage, useNA = "ifany"))
cases$dem_marriagecat <- as.character(cases$dem_marriage)
cases$dem_marriagecat[cases$dem_marriagecat == "WD"] <- "Widowed"
cases$dem_marriagecat[cases$dem_marriagecat == "SN"] <- "Single-Engaged"
cases$dem_marriagecat[cases$dem_marriagecat == "DV"] <- "Divorced-Separated-Unknown"
cases$dem_marriagecat[cases$dem_marriagecat == "MA"] <- "Married"
cases$dem_marriagecat[cases$dem_marriagecat == "EG"] <- "Single-Engaged"
#cases$dem_marriagecat[cases$dem_marriagecat == "SR"] <- "Divorced-Separated-Unknown"
#cases$dem_marriagecat[cases$dem_marriagecat == "CL"] <- "Married"
prop.table(table(cases$dem_marriagecat, useNA = "ifany"))



####################################################################################################
## Adding Age cohort of PA
cases$agecohort <- cut(cases$dem_age,c(0,18,25,35,45,59,Inf))
prop.table(table(cases$agecohort, useNA = "ifany"))
##Eliminating ifany records where PA has no age
cases <- cases[!is.na(cases$agecohort), ]

### Arrival year

table(cases$YearArrival, useNA = "ifany")

table(cut(cases$YearArrival, breaks = c(0,2012,2013,2016,2017,Inf),include.lowest = TRUE), useNA = "ifany")

cases$YearArrivalCat <- cut(cases$YearArrival, breaks = c(0,2012,2013,2016,2017,Inf),include.lowest = TRUE,
                            labels = c("2012.or.before", "2013", "2014.to.2016", "2017", "2018.and.after"))

####################################################################################################
# Recoding Education of had of household
prop.table(table(cases$edu_highest, useNA = "ifany"))

cases$educat <- as.character(cases$edu_highest)
cases$educat[cases$educat == "KG"] <- "Formal Education" # "Kindergarten"
cases$educat[cases$educat == "01"] <- "Formal Education" # "Grade 1"
cases$educat[cases$educat == "02"] <- "Formal Education" # "Grade 2"
cases$educat[cases$educat == "03"] <- "Formal Education" # "Up to Grade 5" # "Grade 3"
cases$educat[cases$educat == "04"] <- "Formal Education" #"Up to Grade 5" # "Grade 4"
cases$educat[cases$educat == "05"] <- "Formal Education" #"Up to Grade 5" # "Grade 5"
cases$educat[cases$educat == "06"] <- "Formal Education" #"Grade 6-8" # "Grade 6"
cases$educat[cases$educat == "07"] <- "Formal Education" #"Grade 6-8" # "Grade 7"
cases$educat[cases$educat == "08"] <- "Formal Education" #"Grade 6-8" # "Grade 8"
cases$educat[cases$educat == "09"] <- "Formal Education" #"Grade 9-11" # "Grade 9"
cases$educat[cases$educat == "10"] <- "Formal Education" #"Grade 9-11" #"Grade 10"
cases$educat[cases$educat == "11"] <- "Formal Education" #"Grade 9-11" #"Grade 11"
cases$educat[cases$educat == "12"] <- "Formal Education" #"Grade 12-14" #"Grade 12"
cases$educat[cases$educat == "13"] <- "Formal Education" #"Grade 12-14" #"Grade 13"
cases$educat[cases$educat == "14"] <- "Formal Education" #"Grade 12-14" #"Grade 14"
cases$educat[cases$educat == "IN"] <- "Informal Education"
cases$educat[cases$educat == "NE"] <- "No education"
cases$educat[cases$educat == "U"] <- "Unknown"
cases$educat[cases$educat == "-"] <- "Unknown"
cases$educat[cases$educat == "TC"] <- "Higher Education" # "Techn Vocational"
cases$educat[cases$educat == "UG"] <- "Higher Education" #"University level"
cases$educat[cases$educat == "PG"] <- "Higher Education" # "Post university level"
cases$educat <- as.factor(cases$educat)
prop.table(table(cases$educat, useNA = "ifany"))




####################################################################################################
## Occurence of specific needs
#  "SPNeeds",  "HasSPNeed" # ,
## Child at risk
cases$Child.at.risk <- ifelse(cases$`CR-AF` > 0 |
                                cases$`CR-CC` > 0 |
                                cases$`CR-CP` > 0 |
                                cases$`CR-CS` > 0 |
                                cases$`CR-CS` > 0 |
                                cases$`CR-LO` > 0 |
                                cases$`CR-NE` > 0 |
                                cases$`CR-SE` > 0 |
                                cases$`CR-SE` > 0 |
                                cases$`CR-TP` > 0 ,
                              "yes", "no")
cases$Child.at.risk[is.na(cases$Child.at.risk)] <- "no"
prop.table(table(cases$Child.at.risk, useNA = "ifany"))


## Disabled
cases$Disabled <- ifelse(cases$`DS-BD` > 0 |
                           cases$`DS-DF` > 0 |
                           cases$`DS-MM` > 0 |
                           cases$`DS-MS` > 0 |
                           cases$`DS-PM` > 0 |
                           cases$`DS-PS` > 0 |
                           cases$`DS-SD` > 0  ,
                         "yes", "no")
cases$Disabled[is.na(cases$Disabled)] <- "no"
prop.table(table(cases$Disabled, useNA = "ifany"))

## Elder
cases$Elder <- ifelse(cases$`ER-FR` > 0 |
                        cases$`ER-MC` > 0 |
                        cases$`ER-NF` > 0  ,
                      "yes", "no")
cases$Elder[is.na(cases$Elder)] <- "no"
prop.table(table(cases$Elder, useNA = "ifany"))

## Single Child
cases$Single.Child <- ifelse(cases$`SC-CH` > 0 |
                               cases$`SC-FC` > 0 |
                               cases$`SC-SC` > 0 |
                               cases$`SC-UC` > 0  ,
                             "yes", "no")
cases$Single.Child[is.na(cases$Single.Child)] <- "no"
prop.table(table(cases$Single.Child, useNA = "ifany"))

## Serious medical needs
cases$Serious.medical.needs <- ifelse(cases$`SM-CC` > 0 |
                                        cases$`SM-CI` > 0 |
                                        cases$`SM-MN` > 0 |
                                        cases$`SM-OT` > 0  ,
                                      "yes", "no")
cases$Serious.medical.needs[is.na(cases$Serious.medical.needs)] <- "no"
prop.table(table(cases$Serious.medical.needs, useNA = "ifany"))

## single parent
cases$single.parent <- ifelse(cases$`SP-CG` > 0 |
                                cases$`SP-GP` > 0 |
                                cases$`SP-PT` > 0 ,
                              "yes", "no")
cases$single.parent[is.na(cases$single.parent)] <- "no"
prop.table(table(cases$single.parent, useNA = "ifany"))

####################################################################################################
## Extracting Number of times of HHs absentees GFD

table(cases$AST36, useNA = "ifany")
table(cases$AST36, useNA = "ifany")
prop.table(table(cases$AST36, useNA = "ifany"))

cases$AbsenteesGFD2 <- as.numeric(cases$AST36)
cases$AbsenteesGFD2[is.na(cases$AST36)] <- "0"
prop.table(table(cases$AbsenteesGFD2, useNA = "ifany"))

cases$AbsenteesGFD2 <- as.numeric(cases$AbsenteesGFD2)
str(cases$AbsenteesGFD2)

hist(cases$AbsenteesGFD2)

cases$AbsenteesGFD2.discrete <- cut(cases$AbsenteesGFD2,
                                    breaks = c(-1, 0, 1, 60),
                                    labels = c("Regular.0", "almost.Regular.1", "No.Regular.2.or.more"),
                                    include.lowest = TRUE)

#cases$AbsenteesGFD2 <- as.factor(cases$AbsenteesGFD2.discrete)
prop.table(table(cases$AbsenteesGFD2.discrete, useNA = "ifany"))

####################################################################################################
## Feature engineering for properties

cases$possede_voiture1 <- ifelse(cases$possede_voiture > 0, "yes", "no")
cases$possede_moto1 <- ifelse(cases$possede_moto > 0, "yes", "no")
cases$possede_Charrette1 <- ifelse(cases$possede_Charrette > 0, "yes", "no")
cases$possede_panneaux1 <- ifelse(cases$possede_panneaux > 0, "yes", "no")
cases$possede_Bijoux1 <- ifelse(cases$possede_Bijoux > 0, "yes", "no")
cases$possede_Radio1  <- ifelse(cases$possede_Radio > 0, "yes", "no")
cases$possede_Ordinateur1  <- ifelse(cases$possede_Ordinateur > 0, "yes", "no")
cases$possede_Meuble1  <- ifelse(cases$possede_Meuble > 0, "yes", "no")


cases$possede_asins1 <- ifelse(cases$possede_camelin >= 1,     "yes",  "no" )

psum <- function(..., na.rm=FALSE) {
          x <- list(...)
          rowSums(matrix(unlist(x), ncol = length(x)), na.rm = na.rm)
        }


cases$possede_ovincaprin1 <- cut(psum(cases$possede_ovin, cases$possede_caprin, na.rm = TRUE),
                           breaks = c(-1,0, 2, 3, 100000), include.lowest = TRUE ,
                           labels = c("4.No", "3.One.or.two", "2.Three", "1.Four.and.over"))

cases$possede_caprin1 <- ifelse(cases$possede_caprin >= 1,     "yes",  "no" )
cases$possede_bovincamelin1  <- cut(psum(cases$possede_bovin, cases$possede_camelin, na.rm = TRUE),
                             breaks = c(-1,0, 1, 2, 100000), include.lowest = TRUE ,
                             labels = c("4.no", "3.one", "2.two", "1.morethan.two"))

cases$possede_camelin1 <- ifelse(cases$possede_camelin >= 1,     "yes",  "no" )
cases$possede_camelin2 <- ifelse(cases$possede_camelin >= 2,     "yes",  "no" )


####################################################################################################
## Subset data ready for analysis

colNames <- colnames(cases)
propertyCols <- c( "possede_voiture1", "possede_moto1", "possede_Charrette1", "possede_panneaux1", "possede_Bijoux1",
                  "possede_Radio1", "possede_Ordinateur1", "possede_Meuble1",
                  "possede_asins1", "possede_ovincaprin1", "possede_caprin1", "possede_bovincamelin1", "possede_camelin1", "possede_camelin21")

revenueCol_1 <- colNames[grep(pattern = "Revenue1_" , colNames)]
revenueCol_2 <- colNames[grep(pattern = "Revenue2_" , colNames)]


cases2 <- cases [ , c(   c("CaseNo",
                          ## Featured characteristics
                          "familyprofile",
                          "Case.size",
                          "dependency" ,
                          "female.ratio",
                          "dem_marriagecat" ,
                          "agecohort",
                          "YearArrivalCat" ,
                          "educat" ,
                          "Child.at.risk",
                          "Disabled",
                          "Elder",
                          "Single.Child" ,
                          "Serious.medical.needs",
                          "single.parent" ,
                          #"coal5id",
                          ## Socio-Eco - Data
                          ## Occupation
                          "Manager" , "Professional" , "Technician" , "Clerk" , "ServiceMarket" ,
                          "Agricultural", "Craft" , "Machine" , "Elementary" , "NoOccup_or_Unkown",

                          "AbsenteesGFD2.discrete",

                          # Property
                          "possede_voiture1", "possede_moto1", "possede_Charrette1", "possede_panneaux1", "possede_Bijoux1",
                          "possede_Radio1", "possede_Ordinateur1", "possede_Meuble1",
                          "possede_asins1", "possede_ovincaprin1", "possede_caprin1", "possede_bovincamelin1",
                          "possede_camelin1", "possede_camelin2") ,
                         revenueCol_1 , revenueCol_2) ]

## Remove variable with too little info
prostitutionCols <- colNames[grep(pattern = "*_Prostitution" , colNames)]


cases2[ , prostitutionCols] <- list(NULL)


### Quick overview of tabulation
for (i in 1:ncol(cases2)) {
  table(cases[ ,1], useNA = "always")
}


#str(cases2)
#rm(prostitutionCols, revenueCol_1, revenueCol_2,colNames  )


#cases_to_be_nulled <- cases2 %>% filter(Revenue1_Sell_Agriculture_Prod =='no' & Revenue1_Salari == 'no' & Revenue1_transfer_from_abroad =='no' &
#                                          Revenue1_Borrowing =='no' & Revenue1_Begging =='no' & Revenue1_Sell_Assistance =='no' &
#                                          Revenue1_Work_for_Humanitarian_Org =='no' & Revenue1_Transfer =='no' & Revenue1_Cash_transfer_state =='no' &
#                                          Revenue2_Sell_Agriculture_Prod =='no' & Revenue2_Salari =='no' & Revenue2_transfer_from_abroad =='no' &
#                                          Revenue2_Borrowing =='no' & Revenue2_Begging =='no' & Revenue2_Sell_Assistance =='no' &
#                                          Revenue2_Work_for_Humanitarian_Org =='no' & Revenue2_Transfer =='no' & 
#                                          Revenue2_Cash_transfer_state =='no' & possede_voiture1  == 'no' &
#                                          possede_moto1 == 'no' & possede_Charrette1 == 'no' & possede_panneaux1 == 'no' & 
#                                          possede_Bijoux1 == 'no' & possede_Radio1 == 'no' & possede_Ordinateur1 == 'no' & 
#                                          possede_Meuble1 == 'no' & possede_asins1 == 'no' & possede_ovincaprin1 == '4.No' &
#                                          possede_caprin1 == 'no' & possede_bovincamelin1 == '4.no' & possede_camelin1 == 'no' &
#                                          possede_camelin2 == 'no'  )
#cases_to_be_preserved <- cases2 %>% anti_join(cases_to_be_nulled , by="CaseNo")

propertyCol <- colNames[grep(pattern = "possede_" , colNames)]

cases_to_be_nulled <- cases2 %>% anti_join(dataVerified , by="CaseNo")
cases_to_be_preserved <- cases2 %>% anti_join(cases_to_be_nulled , by="CaseNo")


for (i in 1:length(revenueCol_1)) {
  cases_to_be_nulled [ , revenueCol_1[! revenueCol_1 %in% 'Revenue1_Prostitution']] <- NA
}


for (i in 1:length(revenueCol_2)) {
  cases_to_be_nulled [ , revenueCol_2[! revenueCol_2 %in% 'Revenue2_Prostitution']] <- NA
}


cases_to_be_nulled [ , "possede_voiture1"] <- NA
cases_to_be_nulled [ , "possede_moto1"] <- NA
cases_to_be_nulled [ , "possede_Charrette1"] <- NA
cases_to_be_nulled [ , "possede_panneaux1"] <- NA
cases_to_be_nulled [ , "possede_Bijoux1"] <- NA
cases_to_be_nulled [ , "possede_Radio1"] <- NA
cases_to_be_nulled [ , "possede_Ordinateur1"] <- NA
cases_to_be_nulled [ , "possede_Meuble1"] <- NA
cases_to_be_nulled [ , "possede_asins1"] <- NA
cases_to_be_nulled [ , "possede_ovincaprin1"] <- NA
cases_to_be_nulled [ , "possede_caprin1"] <- NA
cases_to_be_nulled [ , "possede_bovincamelin1"] <- NA

cases_to_be_nulled [ , "possede_camelin1"] <- NA
cases_to_be_nulled [ , "possede_camelin2"] <- NA



cases2 <- bind_rows(cases_to_be_preserved , cases_to_be_nulled)


rm(prostitutionCols, revenueCol_1, revenueCol_2,colNames  )






