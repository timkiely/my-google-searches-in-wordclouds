Exploring My Google Search History
================

This script takes my personal Google Search history and creates a "word bubble" of my Top 100 most freuqently searched terms in 2015 and YTD 2016.

For instructions on downloading your personal Google Search history, see [Google's support page on creating a personal archive](https://support.google.com/accounts/answer/3024190?hl=en)

From the above link, you will need to download the "Searches" product.

Then, place the unzipped "Searches" folder into the working directory of this script. The script will then unpack the JSON-formatted data and transform it into a usable data frame, then output each year as a separate .csv file

Setting Up
=============

I don't know of an easy way to do this programatically, but Google makes it relatively simple to download a zipped copy of your search history

``` r
# flow control for setting up the Searches folder from Google History
if(!"Searches"%in%dir()){
  stop("Download and unzip your 'Searches' folder , then place it in this working directory. See https://support.google.com/accounts/answer/3024190?hl=en")
}
```

Check to see that the `Searches` folder has downloaded correctly:

``` r
if(length(dir("Searches"))<1){
  stop("The 'Searches' folder is empty")
} else tail(dir("Searches"))
```

    ## [1] "2016-01-01 January 2016 to March 2016.json"   
    ## [2] "2016-04-01 April 2016 to June 2016.json"      
    ## [3] "2016-07-01 July 2016 to September 2016.json"  
    ## [4] "2016-10-01 October 2016 to December 2016.json"
    ## [5] "2017-01-01 January 2017 to March 2017.json"   
    ## [6] "2017-04-01 April 2017 to June 2017.json"

This scripts relies on the `RJSONIO` package and various `tidyverse` functions. Install and load them:

``` r
if("RJSONIO" %in% rownames(installed.packages()) == FALSE) {install.packages("RJSONIO")};library(RJSONIO)
if("tidyverse" %in% rownames(installed.packages()) == FALSE) {install.packages("tidyverse")};library(tidyverse)
```

Running the scripts:
====================

``` r
source("00-parse-google-search-history.R")

source("01-search-history-bubble.R")

source("02-search-hist-eda.R")

rmarkdown::render("google-search-analysis-markdown.Rmd")
```


![Hourly](img/GoogleSearchHourly-EDA.jpg)



