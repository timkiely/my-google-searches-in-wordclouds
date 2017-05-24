

##===========================================================
##    Exploring my Personal Google Search History
##
## This script takes the data output from the 
## "00-parse-google-search-history.R" script and
## does some basic EDA as well as creates some word bubbles.
## 
## The images are output as static images in the "img" folder
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


for (i in 1:length(file_names)) { 
  
    this_file <- file_names[i]
    search_frame_1 <- readr::read_csv(file.path("searches-by-year/",this_file))
    cloudCorpus <- Corpus(VectorSource(search_frame_1$Search_Text))
    
    # function optionally used later if bigram word clouds are desired
    BigramTokenizer <-
      function(x)
        unlist(lapply(ngrams(words(x), 2), paste, collapse = " "), use.names = FALSE)
    
    tdm <- tm_map(cloudCorpus, content_transformer(tolower))
    tdm <- tm_map(tdm, removePunctuation)
    tdm <- tm_map(tdm, removeNumbers)
    tdm <- tm_map(tdm, removeWords, c(stopwords("english"),"the"))
    tdm <- TermDocumentMatrix(tdm)
    
    ## For bigrams: 
    #tdm <- TermDocumentMatrix(cloudCorpus, control = list(tokenize = BigramTokenizer))
    
    # create the tdm as a maxtrix
    notsparse <- tdm
    m = as.matrix(notsparse)
    v = sort(rowSums(m),decreasing=TRUE)
    d = data.frame(word = names(v),freq=v)
    d <- head(d,n=100)
    
    # color pallettes
    pal = brewer.pal(6,"BuPu")
    colfunc <- colorRampPalette(c("grey", "darkgreen"))
    
    
    # print to the img directory
    output_name <- gsub(".csv","",file_names[i])
    
    jpeg(filename = file.path("img",paste0(output_name,"-wordcloud.jpeg")))
    # Create the word cloud
    set.seed(2016)
    wordcloud(words = d$word
              ,freq = d$freq
              ,scale = c(4,1)
              ,min.freq = 3
              ,random.order = F
              ,colors = colfunc(20)
              )
    dev.off()
    
    
    }








