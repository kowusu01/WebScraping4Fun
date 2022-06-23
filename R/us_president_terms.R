################################################################################
## scrape us presidential terms from Wikipedia
################################################################################
library(tidyverse)
library(rvest)

# set url to scrape
url <- "https://en.wikipedia.org/wiki/List_of_presidents_of_the_United_States"

# read entire web page  into an object
htmlDoc <- read_html(url)

# grab all tables from the page 
# tables are returned as a list of html nodes 
tables <- htmlDoc %>% html_nodes("table")

# if you do view source in the browser and see which table you want, 
# you can go directly to it, 
# you can inspect them one at a time

# the html nodes can be converted to R data frames, nice!
myTable <- tables[[1]] %>% html_table
myTable
glimpse(myTable)


#us_presidents <- myTable[c(3, 4, 7, 8, 6)]
#colnames(us_presidents) <- c("president", "term", "election_year", "vice", "party" )

us_presidents <- myTable[c(3, 4)]
colnames(us_presidents) <- c("president", "term")

# extract the names from the date of birth
extract_name_pattern <- "([a-zA-Z]*\\s[a-zA-Z]*)"
us_presidents <- us_presidents %>% extract(president, c("president"), regex = extract_name_pattern, remove = T)

# extract term
# grab begin and year as one
regex_presidential_term <- "(,\\s\\d{4})(,\\s\\d{4})"
us_presidents <- us_presidents %>% extract(term, c("term"), regex = regex_presidential_term)

regex_term_pattern <- "[a-zA-Z\\s]\\d{1,2},\\s(\\d{4}).*(\\d{4}$)"
us_presidents <- us_presidents %>% extract(term, c("from", "to"), regex = regex_term_pattern, remove = T)
us_presidents <- us_presidents %>% mutate(term = paste0(from,"-", to))
us_presidents <- us_presidents %>% distinct() 
us_presidents <- us_presidents %>% filter(!is.na(from)) 
us_presidents %>% view()
write.csv(us_presidents, "data/us_president_terms.csv")


