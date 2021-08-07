library("surveymonkey")
library("tidyverse")

grads_raw <- 302886746 %>% 
  fetch_survey_obj %>%
  parse_survey

grads_min <- grads_raw %>% 
  # Say that a submission is complete if they answered up to the disability question
  # This increased the number of completes slightly. Should be checked in final processing.
  mutate(complete = !is.na(`Do you identify as a person with a disability?`)) %>% 
  select(date_modified, response_status, 
         `Please tell us the organisation you joined as a graduate.`,
         complete) %>% 
  rename(Employer = `Please tell us the organisation you joined as a graduate.`) 

write_csv(grads_min, str_c("~/Documents/GitHub/nzagedashboard.github.io/Data/fromAPI/", Sys.time(), "_grads.csv"))

# This took 3 requests when last run
interns_raw <- 302886733 %>% 
  fetch_survey_obj %>%
  parse_survey

interns_min <- interns_raw %>% 
  # Say that a submission is complete if they answered up to the disability question
  # This increased the number of completes slightly. Should be checked in final processing.
  mutate(complete = !is.na(`Do you identify as a person with a disability?`)) %>% 
  select(date_modified, response_status, 
         `With which organisation did you undertake your most recent internship?`,
         complete) %>% 
  rename(Employer = `With which organisation did you undertake your most recent internship?`) 

write_csv(interns_min, str_c("~/Documents/GitHub/nzagedashboard.github.io/Data/fromAPI/", Sys.time(), "_interns.csv"))

# This took 2 requests when last run
employers_raw <- 302886711 %>% 
  fetch_survey_obj %>%
  parse_survey


employers_min <- employers_raw %>% 
  # Say that a submission is complete if they answered up to the disability question
  # This increased the number of completes slightly. Should be checked in final processing.
  mutate(complete = !is.na(`What challenges does your organisation face in transitioning graduates from their graduate programme to non-graduate roles, if any?`)) %>% 
  select(date_modified, response_status, 
         `What is the name of your organisation?`,
         complete) %>% 
  rename(Employer = `What is the name of your organisation?`) 

write_csv(employers_min, str_c("~/Documents/GitHub/nzagedashboard.github.io/Data/fromAPI/", Sys.time(), "_employers.csv"))