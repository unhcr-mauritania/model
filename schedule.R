#########################################
## Run the script as scheduled task
#########################################


## install.packages("taskscheduleR")
# https://cran.r-project.org/web/packages/taskscheduleR/vignettes/taskscheduleR.html

library(taskscheduleR)
main <- getwd()
path.to.script <- paste0( main, "/run-prioritisation.R")

## run script once within 62 seconds
taskscheduler_create(taskname = "prioritisation",
                     rscript = path.to.script,  ### script
                     starttime = format(Sys.time() + 62, "%H:%M"), ## When to start
                     schedule = "DAILY",  ## Every what?
                     starttime = "21:30"#, starting what time
                    # modifier = 1 ## Frequency
                     )

## delete the tasks
taskscheduler_delete(taskname = "prioritisation")
