# Modeling Vulnerability with Machine learning

This project allows to run an assistance targeting categorisation.

The model is trained through the result of a vulnerability survey using measurement of food security that is merged with registration information `multi-classification-modeling.R`.

The information pulled out from the registration database is reshapped to prevent imbalences within each modalities of the selected variable. This is done in `feature.R`.

The following algorithms are used and compared to generate prediction: 

 * Multinomial logistic regression 
 * Neural Network regression 
 * Gradient Boosted Decision Trees
 * Random Decision Forest
 
The resulting models can be eventually re-trained based on potential categories revision for cases where the targeting committe  would redress cases categorisation.

The model is then applied to the registration registry in order to get the categories for each case: `run-prioritisation.R`

A script `schedule.R` is available to schedule the categorisation script on regular basis within the server - for instance at night...

a report is prebuilt to provide an overview of the the targeting process: `Prioritisation-report`
