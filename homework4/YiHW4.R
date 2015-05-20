require(tm)        # corpus
require(SnowballC) # stemming
require(wordcloud)
library(ggplot2)
library(reshape)
library(plyr)
library(scales)

#####################################################
###Load the Data
#####################################################

#get the working directory
my.wd<-getwd()
#create a folder called data
#please put all my data into the directory
data.dir <- paste(my.wd,"/data", sep="")
dir.create(data.dir)

#####################################################
###Clean the data
#####################################################


sotu_source<-DirSource(directory=file.path("data"),encoding = "UTF-8",pattern="*.txt",recursive = FALSE,ignore.case=FALSE)
sotu_corpus <- Corpus(sotu_source,readerControl = list(reader=readPlain,language='en'))
sotu_corpus <- tm_map(sotu_corpus, tolower)
sotu_corpus <- tm_map (sotu_corpus,removePunctuation,preserve_intra_word_dashes = TRUE)
sotu_corpus <- tm_map(sotu_corpus,removeNumbers)
sotu_corpus <- tm_map(sotu_corpus,removeWords,stopwords('english'))
sotu_corpus <- tm_map(sotu_corpus,removeWords,c('say','come','will', 'said', 'hand','like','man','know','look','time','now','day'))
sotu_corpus <- tm_map(sotu_corpus,stemDocument,lang='english')
sotu_corpus <- tm_map(sotu_corpus, stripWhitespace)
clean.text = function(x)
{
  if (length(x) > 2){
    # remove punctuation
    x = gsub("[[:punct:]]", "", x)
    return(x)}
}
sotu_corpus<-tm_map(sotu_corpus, clean.text)
sotu_tdm <- TermDocumentMatrix(sotu_corpus)

colnames.sotu <- c('Bleak House', 'David Copperfield', 'Great Expectation', 'Tale of Two Cities')
sotu_tdm$dimnames$Docs<-colnames.sotu
sotu_matrix <- as.matrix(sotu_tdm)

sotu_df<-data.frame(sotu_matrix, terms=sotu_tdm$dimnames$Terms)
View(sotu_df)

#####################################################
###comparison cloud and commonality cloud
#####################################################

comparison.cloud(sotu_matrix, random.order=FALSE, 
                 title.size=1, max.words=50)


commonality.cloud(sotu_matrix, random.order=FALSE, 
                  colors = c("#00B2FF", "red", "#FF0099", "#6600CC"),
                  max.words=100)


######################################################
######Heat Map
######################################################

sotu_df.ranked<- sotu_df[with(sotu_df, order(Tale.of.Two.Cities, decreasing = TRUE)), ]
#pick the top 25 words for easy plotting on heat map
sotu_df.ranked<-sotu_df.ranked[1:20,]

molten <- melt(sotu_df.ranked,id=c('terms'))

##Create heat map
p<-ggplot(molten,aes(x=terms, y=variable))
p <- p + geom_tile(aes(fill=value)  )
p <- p + theme_minimal()
# remove axis titles, tick marks, and grid
p <- p + theme(axis.title = element_blank())
p <- p + theme(axis.ticks = element_blank())
p <- p + theme(panel.grid = element_blank())
# remove padding around grey plot area
p <- p + scale_x_discrete(expand = c(0, 0))
p <- p + scale_y_discrete(expand = c(0, 0))    

palette <-c("#feebe2","#fcc5c0", "#fa9fb5", "#f768a1", "#c51b8a", "#7a0177")
p<-p+scale_fill_gradientn(colours = palette)
p<-p+coord_flip()
p<-p+theme(legend.position = "none")  
p<-p+theme(plot.title = element_text(size=20))
p<-p+title('Word Frequency in Bleak House, David Copperfield, Great Expectation, and Tale of Two Cities')
print(p)
ggsave(file='Yi_HeatMap.png', plot=p, dpi=100, width=15, height=15)

######################################################
######Bar Plot
######################################################
View(molten)

k<-ggplot(molten, aes(x=terms, y=value, fill=variable))
k<-k+geom_bar(stat='identity')
k<-k + scale_fill_discrete(name='Book')
k<-k + theme(panel.background = element_rect(fill = NA))
k<-k + theme(panel.grid.major = element_line(color='grey', linetype=1))
k<-k + theme(panel.grid.minor = element_line(color='grey', linetype=2))
k<-k + scale_y_continuous(limits=c(0,3000))
k<-k+ggtitle('Word Frequency in Bleak House, David Copperfield, Great Expectation, Tale of Two Cities')
k<-k+xlab('Word')
k<-k+ylab('Frequency')
k<-k + theme(axis.ticks = element_blank())
print(k)
ggsave(file='Yi_BarPlot.png', plot=k, dpi=100, width=15, height=15)


