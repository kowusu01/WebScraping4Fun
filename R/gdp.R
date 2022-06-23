
################################################################################
##
## load world gdp data from world bank site
##
################################################################################

# source:https://databank.worldbank.org/id/a02faab9?Report_Name=GDP-data#
url <- "https://databank.worldbank.org/data/download/GDP.pdf"


if(!require(pdftools)) install.packages("pdftools")
if(!require(tidyverse)) install.packages("tidyverse")

library(pdftools)
library(tidyverse)


fnCleanPdfPage <- function(pdf_table, max_rows=LAST_ROW){
  
  pdf_table <- pdf_table %>% as.data.frame()
  colnames(pdf_table) <- c("data")

  cols<- c("country_code", "ranking", "country", "gdp_millions")
  
  regex_country_code <- "([a-zA-Z]{3})"
  regex_ranking <- "[\\s]*([\\d]{1,3})"
  regex_country_name <- "\\s([a-zA-Z\\s,.'ô\\)\\()ç\\-ãé]*)"
  regex_gdp <- "([\\d]*[,]*[\\d]*[,]*[\\d]*|[\\d]*[,]*[\\d]*[,]*[\\d]*[\\s]*)[a-z]*"
  regex_all <- paste0("^",regex_country_code, regex_ranking, regex_country_name, regex_gdp, "$")
  gdp_info <- pdf_table %>% extract(data, cols, regex=regex_all)
  gdp_info <- gdp_info[4:max_rows, ]
  
  gdp_info <- gdp_info %>% mutate(across(everything(), ~str_trim(., side = "both")))
  gdp_info$gdp_millions <- str_remove_all(gdp_info$gdp_millions, ",")
  gdp_info <- gdp_info %>% mutate(across( c(ranking, gdp_millions), as.numeric) )
  gdp_info <- gdp_info %>% mutate(country_code = factor(country_code))
  
  gdp_info
}


# number of rows in tables
LAST_ROW <- 68


# load pdf from web
pdf <- pdf_text(url)

# the gdp data is in a table split across 4 pages
pdf <- pdf %>% str_split("\n")

# read the data from each page and clean it up
# then merge all the data into a single dataframe
world_gdp <- fnCleanPdfPage(pdf[[1]]) %>% 
  rbind(fnCleanPdfPage(pdf[[2]])) %>% 
  rbind(fnCleanPdfPage(pdf[[3]])) %>% 
  rbind(fnCleanPdfPage(pdf[[4]], 14))

str(world_gdp)

write.csv(world_gdp, "data/world_2020_gdp.csv")


