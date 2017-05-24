

source("00-parse-google-search-history.R")

source("01-search-history-bubble.R")

source("02-search-hist-eda.R")

rmarkdown::render("google-search-analysis-markdown.Rmd")
