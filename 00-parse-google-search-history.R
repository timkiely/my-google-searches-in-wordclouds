


##===========================================================
##    Exploring my Personal Google Search History
##
## This script takes the raw, unziped Google Search history and
## outputs that history into .csv files, one per year. 
##
## For instructions on downloading your personal Google Search
## history, see: 
##    https://support.google.com/accounts/answer/3024190?hl=en
##
## You will need to download "Searches" from the above Google
## page, then place the unzipped "Searches" folder into the
## working directory of this script. The script will then 
## unpack the JSON-formatted data and transform it into a
## usable data frame, then output each year as a separate .csv file
##
## Tim Kiely
## 09/10/2016
##===========================================================


# flow control for setting up the Searches folder from Google History
if(!"Searches"%in%dir()){
  stop("Download and unzip your 'Searches' folder , then place it in this working directory. See https://support.google.com/accounts/answer/3024190?hl=en")
}

if(length(dir("Searches"))<1){
  stop("The 'Searches' folder is empty")
}


# This scripts relies on the RJSONIO package
if("RJSONIO" %in% rownames(installed.packages()) == FALSE) {install.packages("RJSONIO")};library(RJSONIO)
if("tidyverse" %in% rownames(installed.packages()) == FALSE) {install.packages("tidyverse")};library(tidyverse)
if("lubridate" %in% rownames(installed.packages()) == FALSE) {install.packages("lubridate")};library(lubridate)


# loop through the directory and convert the JSON format
df.of.searches<-data.frame()
for(j in 1:length(dir("Searches"))){
  
  search.file<-dir("Searches")[j]
  json_file <- paste0("Searches","/",search.file)
  json_data <- RJSONIO::fromJSON(json_file)[["event"]]
  
  df.fin1<-data.frame()
  for(i in 1:length(json_data)){
    try({
      dat<-json_data[i]
      df<-data.frame('Time_Stamp'=dat[[1]]$query$id[[1]]['timestamp_usec']
                     ,'Search_Text'=dat[[1]]$query$query_text
                     ,stringsAsFactors = F)
      row.names(df)<-NULL
      df.fin1<-rbind(df.fin1,df)
    },silent=T)
  }
  df.of.searches <- rbind(df.of.searches,df.fin1)
}

df.of.searches$DateTime<-
  as.POSIXct(
    as.numeric(
      as.character(
        df.of.searches$Time_Stamp 
      )
    )
    /1000000
    ,origin="1970-01-01", tz="EST")


library(lubridate)
df.of.searches$Date<-as.Date(df.of.searches$DateTime)
df.of.searches$Year<-year(df.of.searches$DateTime)
df.of.searches$Month<-sprintf("%02.0f",month(df.of.searches$DateTime))
df.of.searches$YearMonth<-paste0(df.of.searches$Year,df.of.searches$Month)
df.of.searches$Day_of_Week<-wday(df.of.searches$DateTime,label=T)
df.of.searches$Hour<-hour(df.of.searches$DateTime)


# output the top 100 words per year as .csv files
if(!"searches-by-year"%in%dir()){
  dir.create("searches-by-year")
}

yrs <- unique(df.of.searches$Year)

for(i in 1:length(yrs)){
  df_sub <- dplyr::filter(df.of.searches,Year==yrs[i])
  readr::write_csv(df_sub, path = paste0("searches-by-year/my-google-searches-",yrs[i],".csv"))
}







