#Author: Yi He
#Data Visualization Project Prototype Server.R

library(ggplot2)
library(shiny)
library(grid)
library(GGally)

loadData <- function(){
  red.wine<-read.csv('winequality-red.csv',sep=";",header=TRUE)
  return (red.wine)
}


bublePlot <- function(data){
  data.plot <- data.frame(data)
  p.b <- ggplot(data.plot, aes(x = alcohol,y = pH,color = as.factor(quality),size = as.factor(quality)))
  p.b <- p.b  + geom_point (alpha=0.6, position = 'jitter') + labs(color='Wine Quality')+ labs(size='Wine Quality')
  p.b <- p.b + scale_y_continuous(limits=c(2.5,4.2), expand=c(0,0))
  p.b <- p.b + scale_x_continuous(name = '% alcohol', limits=c(7.5, 15), expand=c(0,0))
  anontateText<-paste("Circle area is proportional to Quality of Wine")
  p.b <- p.b + annotate("text", x = 11, y = 3.9,hjust = 0.5, color = "grey40", size=8,label = anontateText)
  p.b <- p.b + theme(panel.background = element_rect(fill = NA))
  p.b <- p.b + theme(panel.grid.major = element_line(color='grey', linetype=1))
  p.b <- p.b + theme(panel.grid.minor = element_line(color='grey', linetype=2))

  return (p.b)
}

histPlot <- function(data){
  data.hist <- data.frame(data)
  p<- ggplot(data.hist, aes(residual.sugar, fill=as.factor(quality)))
  p<- p + geom_density(alpha = 0.2)  
  p<-p + theme(panel.background = element_rect(fill = NA))
  p<-p + theme(panel.grid.major = element_line(color='grey', linetype=1))
  p<-p + theme(panel.grid.minor = element_line(color='grey', linetype=2))
  p <- p + guides(fill=guide_legend(title="Wine Quality"))
  p <- p + scale_y_continuous(name = 'Density')
  p <- p + scale_x_continuous(name = '% Sugar')
  p <- p + ggtitle('Histograms of % Sugar of Wine Quality')
  return (p)
}



globalData<-loadData()

shinyServer(function(input, output){
  
  cat("Press \"ESC\" to exit...\n")
  data <- globalData
  

  
  output$bubPlot <- renderPlot({
    bubPlot <- bublePlot(
      data
    )
    print(bubPlot)
  })
  
  output$histPlot <- renderPlot({
    histPlot <- histPlot(
      data
    )
    print(histPlot)
  })
  
  
})
