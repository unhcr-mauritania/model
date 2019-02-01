# Modeling Vulnerability with Machine learning

This project allows to run an assistance targeting categorisation.

The model is trained through the result of a vulnerability survey using measurement of food security.

The model is then applied to the registration registry in order to get the categories for each case.

The following algorithms are used and compared to generate prediction

 * Multinomial logistic regression
 * Neural network regression 
 * Stochastic Gradient Boosted Decision Trees
 * Random Decision forest
 
The resulting models can be eventually re-trained based on potential categories revision after the targeting committe redress process.

A script `schedule.R` is available to schedule the categorisation script on regular basis within the server - for instance at night...

a report is prebuilt to provide an overview of the the targeting process. `Prioritisation-report`
