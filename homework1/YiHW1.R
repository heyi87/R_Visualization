#Author: Yi He for MSAN-622 for Homework 1

library(ggplot2) 
data(movies) 
data(EuStockMarkets)
setwd('C:/Users/yh/Desktop/DataVisualization/HW1/')

##Code provided by Professor Engle
genre <- rep(NA, nrow(movies))
count <- rowSums(movies[, 18:24])
genre[which(count > 1)] = "Mixed"
genre[which(count < 1)] = "None"
genre[which(count == 1 & movies$Action == 1)] = "Action"
genre[which(count == 1 & movies$Animation == 1)] = "Animation"
genre[which(count == 1 & movies$Comedy == 1)] = "Comedy"
genre[which(count == 1 & movies$Drama == 1)] = "Drama"
genre[which(count == 1 & movies$Documentary == 1)] = "Documentary"
genre[which(count == 1 & movies$Romance == 1)] = "Romance"
genre[which(count == 1 & movies$Short == 1)] = "Short"
eu <- transform(data.frame(EuStockMarkets), time = time(EuStockMarkets))

#Combine data
movies<-cbind(movies, genre)
movies<-subset(movies, movies$budget>0)

yiHomework1 <- function(){

  ### Question 1
  
  question1Plot <- ggplot (movies, aes(x=budget, y=rating))+
    geom_point(size=1, color='red')+
    geom_smooth(method=lm, se=FALSE)+
    ggtitle('Rating v. Budget')+
    xlab('Movie Budget')+
    ylab('Movie Ratig')
  question1Plot 
  ggsave(filename='hw1-scatter.png', height=10, width=10)
  
  ###Question 2
  question2Plot<-ggplot(movies, aes(factor(genre),fill=genre))+
    geom_bar()+
    ggtitle('Genre Count')+
    xlab('Movie Genre')+
    ylab('Movie Count')
  question2Plot
  ggsave(filename='hw1-bar.png', height=10, width=10)
  
  ###Question 3
  
  question3Plot<-ggplot(movies, aes(x=budget, y=rating, group=factor(genre), color=factor(genre)))+
    geom_point(size=2)+
    geom_smooth(method=lm, se=FALSE)+
    facet_wrap(~genre)+
    ggtitle('Movie Rating vs. Movie Budget per Genre')+
    xlab('Movie Budget')+
    ylab('Movie Rating')
  question3Plot
  ggsave(filename='hw1-multiples.png', height=10, width=10)
  
  ###Question 4
  question4Plot <-ggplot()+
    geom_line(data=eu,aes(x=time, y=eu$DAX,  color='DAX'))+
    geom_line(data=eu,aes(x=time, y=eu$SMI, color='SMI'))+
    geom_line(data=eu,aes(x=time, y=eu$CAC, color='CAC'))+
    geom_line(data=eu,aes(x=time, y=eu$FTSE,  color='FTSE'))+
    theme(legend.title=element_blank())+
    ggtitle('EU Index Moving Average')+
    xlab('Time')+
    ylab('Index Value')
  question4Plot
  ggsave(filename='hw1-multiline.png', height=10, width=10)

}

yiHomework1()

