## install.packages("taskscheduleR")

library(taskscheduleR)


## run script once within 62 seconds
taskscheduler_create(taskname = "prioritisation", 
                     rscript = "D:/R/formule/run-prioritisation.R",  ### script
                     starttime = format(Sys.time() + 62, "%H:%M"), ## When to start
                     schedule = "MINUTE",  ## Every what?
                     modifier = 1)   ## Frequency

## delete the tasks
taskscheduler_delete(taskname = "prioritisation")