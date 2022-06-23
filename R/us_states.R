
################################################################################
## extract US states and territories with basic information
################################################################################

if(!require("rvest")) install.packages("rvest")
if(!require("tidyverse")) install.packages("tidyverse")
library(rvest)
library(tidyverse)

us_states_wikipedia_url <- "https://en.wikipedia.org/wiki/List_of_states_and_territories_of_the_United_States"
html <- read_html(us_states_wikipedia_url)

# use browser to target the correct table note
# read the page, and convert the table to tibble 
states_table <- html %>% 
  html_nodes(xpath='//*[@id="mw-content-text"]/div[1]/table[2]') %>% 
  html_table()

# to select data, change col names, at dataframe level, convert to dataframe 
states_table <- states_table %>%  as.data.frame()
states_table <- states_table[-1, c(1, 2,3,4,6,7,9,11)]

# change col names
colnames(states_table) <- c("name", "cd", "capital", "largest_city", "2020_population", 'total_area','total_land', "total_water") 

# approach 1: use remove unwanted string
#states_table$name <- str_remove(states_table$name, "\\[[A-D]\\]")
#states_table %>% View()

# approach 2: use extract - extract only required string
str_pattern <- "^[a-zA-Z]*[\\s]?[a-zA-Z]*"
states_table$name <-str_extract(states_table$name, str_pattern)
states_table %>% View()

#save data as csv
# write.csv() is from utils package
write.csv(states_table, "data/us_states.csv")

str(states_table)





