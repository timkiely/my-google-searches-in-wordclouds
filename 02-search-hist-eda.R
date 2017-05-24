
##===========================================================
##    Exploring my Personal Google Search History
##
## This script takes the data output from the 
## "00-parse-google-search-history.R" script and
## does some basic EDA. plots are saved and used in
## an RMarkdown document
## 
## The images are also output as static images 
## in the "img" folder
##
##
## Tim Kiely
## 09/10/2016
##===========================================================


if("RJSONIO" %in% rownames(installed.packages()) == FALSE) {install.packages("RJSONIO")};library(RJSONIO)
if("tidyverse" %in% rownames(installed.packages()) == FALSE) {install.packages("tidyverse")};library(tidyverse)
if("lubridate" %in% rownames(installed.packages()) == FALSE) {install.packages("lubridate")};library(lubridate)
if("wordcloud" %in% rownames(installed.packages()) == FALSE) {install.packages("wordcloud")};library(wordcloud)
if("SnowballC" %in% rownames(installed.packages()) == FALSE) {install.packages("SnowballC")};library(SnowballC)
if("tm" %in% rownames(installed.packages()) == FALSE) {install.packages("tm")};library(tm)
if("ggthemes" %in% rownames(installed.packages()) == FALSE) {install.packages("ggthemes")};library(ggthemes)


if(!"searches-by-year"%in%dir()){
  stop("searches-by-year file directory not found. Are we in the right directory?")
}


# get file names in the corpus directory_location
file_names <- dir("searches-by-year")
if(length(file_names)<1){
  stop("File directory is empty. Did you run the 00-parse-google-search-history script?")
}

if(!"img"%in%dir()){
  dir.create("img")
}



# initialize an empty data frame
text_df <- data.frame()

for (i in 1:length(file_names)) { 
  
  this_file <- file_names[i]
  search_frame_1 <- readr::read_csv(file.path("searches-by-year/",this_file))
  text_df <- bind_rows(text_df,search_frame_1)
}

text_df <- tbl_df(text_df)


# we will store our ggplot output as a list for printing later
master.plot.list <- list()


# histogram of searches over time
master.plot.list[["GoogleSearchHistogram"]]<-
text_df %>% 
  group_by(Date) %>% 
  summarise(count=n()) %>% 
  ggplot()+
  aes(x=Date, y = count)+
  geom_col()+
  theme_bw()+
  labs(title="My Google Search History Over Time") 


# density plot
master.plot.list[["GoogleSearchDensity"]]<-
text_df %>% 
  filter(Year%in%2012:2015) %>% 
  mutate(Day = lubridate::day(Date)
         ,AllDate = as.POSIXct(paste0("2016-",Month,"-",Day))) %>% 
  mutate(Year = factor(Year,levels = c("2011","2012","2013","2014","2015","2016"))) %>% 
  ggplot()+
  aes(x=AllDate,group=Year,fill=Year)+
  geom_density(alpha=0.5, adjust=1, color = "black")+
  theme_bw()+
  labs(title="My Google Search History, Density View"
       ,x = "Date of the Year (Ignore the '2016')"
       ,y = NULL) 



# bar plot over time
master.plot.list[["GoogleSearchSeasonal"]]<-
  text_df %>% 
  mutate(Day = lubridate::day(Date)
         ,AllDate = as.POSIXct(paste0("2016-",Month,"-",Day))) %>% 
  mutate(Year = factor(Year,levels = c("2011","2012","2013","2014","2015","2016"))) %>% 
  group_by(Year,Month) %>% 
  summarise(count=n()) %>% 
  ggplot()+
  aes(x=Month,y=count,group=Year,fill=Year)+
  geom_col(position="dodge")+
  theme_bw()+
  scale_fill_tableau()+
  labs(title="My Google Search History,Bar Plot"
       ,xlab = "Month"
       ,ylab = "Count")


# box plot
master.plot.list[["GoogleSearchBoxPlot"]]<-
  text_df %>% 
  mutate(Day = lubridate::day(Date)
         ,AllDate = as.POSIXct(paste0("2016-",Month,"-",Day))) %>% 
  mutate(Year = factor(Year,levels = c("2011","2012","2013","2014","2015","2016"))) %>% 
  group_by(Year,Month) %>% 
  summarise(count=n()) %>% 
  ggplot()+
  aes(x=Month,y=count,group=Month, fill = Month)+
  geom_boxplot(outlier.colour="red", outlier.size=3)+
  theme_bw()+
  scale_fill_tableau('tableau20')+
  theme(legend.position="none")+
  labs(title="My Google Search History, Box Plot"
       ,xlab = "Month"
       ,ylab = "Count")

# weekday
master.plot.list[["GoogleSearchWeekday"]]<-
  text_df %>% 
  mutate(Day_of_Week=factor(Day_of_Week,levels=c("Mon","Tues","Wed","Thurs","Fri","Sat","Sun"))
         ,Hour = as.numeric(Hour)
  ) %>% 
  mutate(Year = factor(Year,levels = c("2011","2012","2013","2014","2015","2016"))) %>% 
  group_by(Year,Month,Day_of_Week,Hour) %>% 
  summarise(count=n()) %>% 
  group_by(Year,Day_of_Week,Hour) %>% 
  summarise(HourlyAverage=mean(count,na.rm=T)) %>%
  ggplot()+
  aes(x=Hour,y=HourlyAverage, fill = HourlyAverage)+
  geom_bar(stat="identity")+
  facet_grid(Year~Day_of_Week, switch="x")+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 0,hjust=0.5,size=12)
       , panel.grid = element_line(colour = "darkgrey"))+
  scale_fill_continuous(low="black",high="red")+
  scale_y_continuous(expand = c(0,0)) + 
  scale_x_continuous(expand = c(0,0)
                     ,breaks=c(0,3,6,9,12,15,18,21)
                     ,labels=c("12AM","3AM","6AM","9AM","12PM","3PM","6PM","9PM"))+
  theme(panel.margin.x = unit(0.05, "lines")
        ,axis.text.x=element_text(angle=90,hjust=1,vjust=0.5))+ 
  guides(fill=FALSE)+
  labs(title="My Google Search History, Hourly Average By Year and Day"
       ,xlab = "Month"
       ,ylab = "Count")



master.plot.list[["GoogleSearchHourly"]]<-
  text_df %>% 
  mutate(Day_of_Week=factor(Day_of_Week,levels=c("Mon","Tues","Wed","Thurs","Fri","Sat","Sun"))
         ,Hour = as.numeric(Hour)
  ) %>% 
  mutate(Year = factor(Year,levels = c("2011","2012","2013","2014","2015","2016"))) %>% 
  ggplot()+
  aes(x=Hour,group=Year, fill = Year)+
  geom_density(alpha=0.2, adjust=1)+
  facet_grid(Year~.)+
  theme_bw()+
  theme(axis.text.x = element_text(angle = 0,hjust=0.5,size=12)
        , panel.grid = element_line(colour = "darkgrey"))+
  scale_x_continuous(expand = c(0,0)
                     ,breaks=c(0,3,6,9,12,15,18,21)
                     ,labels=c("12AM","3AM","6AM","9AM","12PM","3PM","6PM","9PM"))+
  theme(panel.margin.x = unit(0.05, "lines")
        ,axis.text.x=element_text(angle=90,hjust=1,vjust=0.5))+ 
  guides(fill=FALSE)+
  labs(title="My Google Search History, Hourly Average By Year"
       ,xlab = "Month"
       ,ylab = "Density")

  

# sample plot
master.plot.list[["SampleDat"]]<-text_df %>% head(n=6)


# save the plot list as an R file
saveRDS(master.plot.list, file = "google-search-master-plot.rds")
        

# print the plots as .jpegs to the img folder
for(i in 1:length(master.plot.list)){
  jpeg(filename = file.path("img",paste0(names(master.plot.list)[i],"-EDA.jpeg")))
  print(master.plot.list[[i]])
  dev.off()
  
}

        
