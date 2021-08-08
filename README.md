# NZAGE Survey Dashbaord

This repo creates a dashboard summarising responses to the NZAGE Graduate, Intern and Employer survey, administered by Talent Solutions.

## Sub-tasks/skills

-   Connect to SurveyMonkey from API (`surveymonkey` package, creating an authentication token)

-   File management `(list.files()`, `file.info()`)

-   Wrangling data (`dplyr`)

-   Visualizing data (`ggplot2`)

-   Create HTML files in R (can be a simple single page or use the Distill package to make a more polished multipage site)

-   Git and GitHub

-   `crontab` on Linux/Mac terminals (I think there are reasonably equivalent things on Windows, but don't know them)

## Technical set up

#### My session info:

Note: I did this on a Mac. That set up will be different for a Windows machine.

    > sessionInfo()
    R version 3.6.2 (2019-12-12)
    Platform: x86_64-apple-darwin15.6.0 (64-bit)
    Running under: macOS  10.16

## Automation is the hardest part (for me at least)

Pretty reliably you should be able to get this down to just needing to run one line to have everything else happen, it is setting up the `crontab` that I had the most trouble with, though it is super reqarding when it does work.

Some of these instructions are probably just superstition...

Need to allow the bash script to be executed before putting it in a crontab job `chmod +x ~/Documents/GitHub/nzagedashboard.github.io/nzagedashboard_driver.sh`.

Make sure your GitHub credentials are set up, you want the SSH version. Just google whatever GitHub's latest advice is.

I had issues getting the correct version of pandoc to be applied, so have to put it explicitly in the R code that is run.

This is my `nzagedashboard.sh` file:

    cd ~/Documents/GitHub/nzagedashboard.github.io
    /usr/local/bin/Rscript -e 'Sys.setenv(RSTUDIO_PANDOC="/Applications/RStudio.app/Contents/MacOS/pandoc");
                                source("~/Documents/GitHub/nzagedashboard.github.io/connect_API.R");
                                rmarkdown::render_site(encoding = "UTF-8");
                                rmarkdown::clean_site()'
    git add -A
    git commit -m "Autoupdate"
    git push

This code sets the working directory to my folder for this project, then (line 2) it sets up using R to run 4 commands, first, set where to find pandoc, second, run the script that accessed the API (I've kept this in a separate file because it makes it easier to remove it when testing so I don't hit the API limit), third, the site is rendered, in the process, the data is loaded and run and the visualizations updated, finally the unneeded files are cleaned up.

#### My crontab workflow

(must have run the `chmod +x ~/Documents/GitHub/nzagedashboard.github.io/nzagedashboard_driver.sh` code)

1.  Open Terminal
2.  Type `crontab -e` and Enter/Return
3.  Press `i` to enter 'Insert mode' and add a line like this: `0 */3 * * * ~/Documents/GitHub/nzagedashboard.github.io/nzagedashboard_driver.sh`. This says "run this script every three hours". This site is really helpful for interpretting the cron syntax <https://crontab.guru/#0_*/3_*_*_>\*

## Connecting to the Survey Monkey API

This is the 'instructions' version of the code. The file that is actually run is `connect_API.R`.

## 1. Install the required packages

The `surveymonkey` package makes it easier to access the Survey Monkey API in R. It is developed and maintained by TNTP, a nonprofit company working to end the injustice of educational inequality.

```{r, eval}
# for wrangling, viz, etc.
if(!require("tidyverse")) {
  install.packages("tidyverse")
}

# easy editting of R environments
if(!require("usethis")) {
  install.packages("usethis")
}

# Need devtools install surveymonkey package from github
if(!require("devtools")) {
  install.packages("devtools")
}

# Get the dev version of surveymonkey package 
# https://github.com/tntp/surveymonkey
devtools::install_github("tntp/surveymonkey")

```

    library("surveymonkey")
    library("tidyverse")

## 2. Set up an API key in Survey Monkey

At time of writing, you create your access token by making a new private app here: <https://developer.surveymonkey.com/apps/>.

Then follow these intructions from the surveymonkey package documentation (or more updated authentication information):

Add the SurveyMonkey account's OAuth token to your .Rprofile file. To open and edit that file, run `usethis::edit_r_profile()`, then add a line like this: `options(sm_oauth_token = "kmda332fkdlakfld8am7ml3dafka-dafknalkfmalkfad-THIS IS NOT THE REAL KEY THOUGH").`

WARNING 1: Don't share the token or accidentally add it on GitHub, etc.

WARNING 2: Pay attention to the number of requests you are allowed to make in a day. At time of writing, 500.

WARNING 3: Only 100 responses can be fetched per API call, a survey with X respondents will make at least X/100 calls to the API.

    # Get the latest 10 (or n) surveys so you can find the IDs for the surveys you want
    surveys <- browse_surveys(10)

## 3. Get the data

Here I'm saving the data as .csv that can be used as back up and more easily integrated into the site.

    # This took 6 requests when last run
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

    write_csv(grads_min, str_c("Data/fromAPI/", Sys.time(), "_grads.csv"))

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

    write_csv(interns_min, str_c("Data/fromAPI/", Sys.time(), "_interns.csv"))

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

    write_csv(employers_min, str_c("Data/fromAPI/", Sys.time(), "_employers.csv"))
