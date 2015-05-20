library(ggplot2)
library(shiny)
library(plyr)
library(scales)

million_formatter <- function(x) {
  #label <- round(x / 1000)
  return(sprintf("%dM", round(x / 10^6)))
}

loadData <- function(){
  data("movies", package = "ggplot2")
  #create a column genre with Action, Animation, Comedy, Drama, Documentary, Romance, and Short
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
  #Combine data
  movies<-cbind(movies, genre)
  movies<-subset(movies, movies$budget>0)
  movies<-subset(movies, movies$mpaa!='')
  return (movies)
  
}

getPlot <- function(localFrame, mpaa,  genreVec,Color, dotSize, dotAlpha, fitYes){
  #This function plots the scatter plot  
  genreVec <-as.numeric(genreVec) #change character to numbers
  #create a list of genre
  genreNames <-c('Action', 'Animation', 'Comedy', 'Drama', 'Documentary', 'Romance', 'Short')
  #subset base on how many genre user picked
  if(length(genreVec)>0){localFrame.new <- subset(localFrame , genre %in% genreNames[genreVec])}
  #if user doesn't pick any genre, use all genre
  else{localFrame.new <- localFrame}
  localPlot<- ggplot(localFrame.new)+ #create a base plot
    ggtitle('Rating v. Budget')+
    xlab('Movie Budget')+
    ylab('Movie Rating')
  
  #subplot the data base on if which genre the user picks
  if (mpaa == 'All'){localPlot <- localPlot+geom_point(aes(x=budget, y=rating, color=factor(mpaa)), size=dotSize, alpha=dotAlpha)}
  else if (mpaa == 'NC-17'){localPlot <- localPlot + geom_point (aes(x=budget, y=rating, color=factor(mpaa)), size=dotSize, alpha=dotAlpha, subset = .(localFrame.new$mpaa %in% c('NC-17')))}
  else if (mpaa == 'PG'){localPlot <- localPlot + geom_point (aes(x=budget, y=rating, color=factor(mpaa)), size=dotSize, alpha=dotAlpha, subset = .(localFrame.new$mpaa %in% c('PG')))}
  else if (mpaa == 'PG-13'){localPlot <- localPlot + geom_point (aes(x=budget, y=rating, color=factor(mpaa)), size=dotSize, alpha=dotAlpha, subset = .(localFrame.new$mpaa %in% c('PG-13')))}
  else if (mpaa == 'R'){localPlot <- localPlot + geom_point (aes(x=budget, y=rating, color=factor(mpaa)), size=dotSize, alpha=dotAlpha, subset = .(localFrame.new$mpaa %in% c('R')))}

  #Change color setting base on user input
  if (Color == 'Accent'){localPlot<-localPlot + scale_colour_brewer(palette = 'Accent')}
  else if (Color == 'Set1'){localPlot<-localPlot + scale_colour_brewer(palette = 'Set1')}
  else if (Color == 'Set2'){localPlot<-localPlot + scale_colour_brewer(palette = 'Set2')}
  else if (Color == 'Set3'){localPlot<-localPlot + scale_colour_brewer(palette = 'Set3')}
  else if (Color == 'Dark2'){localPlot<-localPlot + scale_colour_brewer(palette = 'Dark2')}
  else if (Color == 'Pastel1'){localPlot<-localPlot + scale_colour_brewer(palette = 'Pastel1')}
  else if (Color == 'Pastel2'){localPlot<-localPlot + scale_colour_brewer(palette = 'Pastel2')}
  else if (Color == 'Color-Blind Friendly'){localPlot<-localPlot + scale_colour_manual(values=palette1)}
  else if (Color =='Default'){localPlot <- localPlot + scale_colour_brewer()}

  #draw the regression line
  if (fitYes==TRUE){localPlot<-localPlot+geom_smooth(aes(x=budget, y=rating), method=lm, linetype=2,size = 1, colour = "red", se = TRUE, stat = "smooth")}
  
  #retool the plot:
  localPlot<-localPlot+theme(legend.title=element_blank())#remove the legend title
  localPlot<-localPlot + theme(panel.background = element_rect(fill = NA))
  localPlot<-localPlot + scale_x_continuous(limits=c(0-10^6,max(localFrame.new$budget)+10^6), expand=c(0,0),label=million_formatter)
  localPlot<-localPlot + scale_y_continuous(limits=c(0,10),expand = c(0, 0))
  localPlot<-localPlot + theme(panel.grid.major = element_line(color='grey', linetype=1))
  localPlot<-localPlot + theme(panel.grid.minor = element_line(color='grey', linetype=2))

  return(localPlot) 
}

globalData <- loadData()

#get the color for the color palette 
palette1 <- c("#999999", "#E69F00", "#56B4E9", "#009E73",
              "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

shinyServer(function(input, output) {
  
  cat("Press \"ESC\" to exit...\n")
  
  localFrame <- globalData
  
  outOrder2<-reactive({
    #subset data base on what the user picks
    genreVec <-as.numeric(input$genreUI)
    genreNames <-c('Action', 'Animation', 'Comedy', 'Drama', 'Documentary', 'Romance', 'Short')
    if(length(genreVec)==0){localFrame.new <- localFrame}
    if(length(genreVec)>0){localFrame.new <- subset(localFrame , genre %in% genreNames[genreVec])}
    if (input$mpaa == 'All'){localFrame.new.mp <- localFrame.new}
    if (input$mpaa == 'NC-17'){localFrame.new.mp <- subset(localFrame.new, mpaa=='NC-17')}
    if (input$mpaa == 'PG'){localFrame.new.mp <- subset(localFrame.new, mpaa=='PG')}
    if (input$mpaa == 'PG-13'){localFrame.new.mp <- subset(localFrame.new, mpaa=='PG-13')}
    if (input$mpaa == 'R'){localFrame.new.mp <- subset(localFrame.new, mpaa=='R')} 
    localFrame.tab<-data.frame(mpaa=localFrame.new.mp$mpaa, budget=localFrame.new.mp$budget)
    mpaaGroup<-rep(NA, nrow(localFrame.tab))
    #add a new column and group the budget
    mpaaGroup[which(localFrame.tab$budget <=25*10^6 & 0<localFrame.tab$budget)]<-'$0M-$25M'
    mpaaGroup[which(localFrame.tab$budget <=50*10^6 & 25*10^6<localFrame.tab$budget)]<-'$25M - $50M'
    mpaaGroup[which(localFrame.tab$budget <=100*10^6 & 50*10^6<localFrame.tab$budget)]<-'$50M - $100M'
    mpaaGroup[which(localFrame.tab$budget <=150**10^6 & 100*10^6<localFrame.tab$budget)]<-'$100M - $150M'
    mpaaGroup[which(localFrame.tab$budget <=max(localFrame.tab$budget) & 150**10^6<localFrame.tab$budget)]<-'$150M - $200M'
    #create R table
    localFrame.new.mp <- table(as.character(localFrame.tab$mpaa), mpaaGroup)
    localFrame.final<-as.table(localFrame.new.mp)
    return(localFrame.final)
  })
  
  outOrder<-reactive({
    #sub-set data base on what the user picks
    genreVec <-as.numeric(input$genreUI)
    genreNames <-c('Action', 'Animation', 'Comedy', 'Drama', 'Documentary', 'Romance', 'Short')
    if(length(genreVec)==0){localFrame.new <- localFrame}
    if(length(genreVec)>0){localFrame.new <- subset(localFrame , genre %in% genreNames[genreVec])}
    if (input$mpaa == 'All'){localFrame.new.mp <- localFrame.new}
     if (input$mpaa == 'NC-17'){localFrame.new.mp <- subset(localFrame.new, mpaa=='NC-17')}
     if (input$mpaa == 'PG'){localFrame.new.mp <- subset(localFrame.new, mpaa=='PG')}
     if (input$mpaa == 'PG-13'){localFrame.new.mp <- subset(localFrame.new, mpaa=='PG-13')}
     if (input$mpaa == 'R'){localFrame.new.mp <- subset(localFrame.new, mpaa=='R')} 

    localFrame.tab<-data.frame(genre=localFrame.new.mp$genre, rating=localFrame.new.mp$rating)
    genreGroup<-rep(NA, nrow(localFrame.tab))
    #group base on ratings
    genreGroup[which(localFrame.tab$rating <=2.0 & 0<localFrame.tab$rating)]<-'Rating 0-2'
    genreGroup[which(localFrame.tab$rating <=4.0 & 2.0<localFrame.tab$rating)]<-'Rating 2-4'
    genreGroup[which(localFrame.tab$rating <=6.0 & 4.0<localFrame.tab$rating)]<-'Rating 4-6'
    genreGroup[which(localFrame.tab$rating <=8.0 & 6.0<localFrame.tab$rating)]<-'Rating 6-8'
    genreGroup[which(localFrame.tab$rating <=10.0 & 8.0<localFrame.tab$rating)]<-'Rating 8-10'
    localFrame.new.mp <- table(localFrame.tab$genre, genreGroup)
    #create R table
    localFrame.final<-as.table(localFrame.new.mp)
    return(localFrame.final)
    })
  
  output$getTable2<-renderTable({
    return(outOrder2())
  })
  
  output$getTable <- renderTable({
    return(outOrder())
  })
  
  output$scatPlot <- renderPlot(
    {
      scatPlot <- getPlot(
        localFrame,
        mpaa=input$mpaa,
        genreVec=input$genreUI,
        dotSize=input$dotSizeUI,
        dotAlpha=input$dotAlphaUI,
        Color=input$colorL,
        fitYe=input$fitUI
        )
          
      print(scatPlot)
    }
    )
      
    }
  )