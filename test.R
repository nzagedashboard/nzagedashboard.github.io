library(tidyverse)

historical_data <- tibble::tribble(
  ~Year,           ~Employers, ~Grads, ~Interns, ~Bespokes,
  "2018",             38L,            591L,           NA, 27,
  "2019",             43L,            665L,         223, 27,
  "2020",             48L,            863L,         320, 25,
) %>% 
  pivot_longer(-Year, names_to = "type", values_to = "n" )

write_csv(historical_data, "Data/test.csv")