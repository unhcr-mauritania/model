# Modeling Vulnerability with Machine learning

This project allows to run an assistance targeting categorisation.

The information pulled out from the registration database through `get_data_from_db.R`. Data are then reshapped to prevent imbalances within each modalities of the selected variable. This is done in `feature.R`.

The result of a vulnerability survey using measurement of food security is then merged with registration information. In the next step, different models are trained through  `multi-classification-modeling.R`.

The following algorithms are used and compared to generate prediction: 

 * Multinomial logistic regression 
 * Neural Network regression 
 * Gradient Boosted Decision Trees
 * Random Decision Forest
 
The resulting models can be eventually re-trained based on potential categories revision for cases where the targeting committe  would redress cases categorisation.

The model is then applied to the registration registry in order to get the categories for each case: `run-prioritisation.R`

A script `schedule.R` is available to schedule the categorisation script on regular basis within the server - for instance at night...

a report is prebuilt to provide an overview of the the targeting process: `Prioritisation-report`
