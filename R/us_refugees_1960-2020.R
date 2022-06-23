################################################################################
##
## scrape US refugees stats from web
## - two datasets
##   1) refugees accepted by US
##   2) refugees accepted by different countries
##
################################################################################

if(!require("rvest")) install.packages("rvest")
if(!require("tidyverse")) install.packages("tidyverse")
library(rvest)
library(tidyverse)

refugees_page <- read_html("https://www.macrotrends.net/countries/USA/united-states/refugee-statistics")


us_refugees <- refugees_page %>% 
  html_nodes(xpath='//*[@id="main_content"]/div[11]/table/tbody') %>% 
  html_table() %>% as.data.frame()

# select only first two col
us_refugees <- us_refugees[, c(1:2)]
colnames(us_refugees) <- c("year", "total_refugees")

us_refugees$total_refugees <-  str_remove(us_refugees$total_refugees, ",")
us_refugees <- us_refugees %>% mutate(across(total_refugees, ~as.numeric(.)))
str(us_refugees)
us_refugees %>% arrange(year)

us_refugees %>% ggplot() + 
  aes(x=year, y=total_refugees) + 
  geom_point(color="blue", size=3) +
  geom_line(color="red", size=1.3)


#########################################################################
## 2020 refugees by country
#########################################################################
refugees_accepted <- refugees_page %>% 
  html_nodes(xpath='//*[@id="main_content"]/div[9]/table/tbody') %>% 
  html_table() %>% as.data.frame()

# select only first two col
colnames(refugees_accepted) <- c("country_name", "asylum_granted")

refugees_accepted$asylum_granted <- refugees_accepted$asylum_granted %>%
  str_remove_all(",") %>% 
  as.numeric()
str(refugees_accepted)

write.csv(refugees_accepted, "data/refugees_accepted_by_country_2020.csv")

#########################################################################
## US refugees historical
#########################################################################
us_refugees_historical <- refugees_page %>% 
  html_nodes(xpath='//*[@id="main_content"]/div[11]/table/tbody') %>% 
  html_table() %>% as.data.frame()

us_refugees_historical <- us_refugees_historical[,1:2]
colnames(us_refugees_historical) <- c("year", "asylum_granted")
us_refugees_historical$asylum_granted <- str_remove(us_refugees_historical$asylum_granted, "," )
us_refugees_historical <- us_refugees_historical %>% 
  mutate(year=as.integer(year), asylum_granted = as.numeric(asylum_granted))

str(us_refugees_historical)
write.csv(refugees_accepted, "data/us_refugees_historical.csv")
