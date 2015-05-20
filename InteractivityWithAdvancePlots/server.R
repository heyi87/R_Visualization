#Author: Yi He
#Data Visualization Homework 3 Server.R

library(ggplot2)
library(shiny)
library(grid)
library(GGally)

loadData <- function(){
  df <- data.frame(state.x77,
                   State = state.name,
                   Abbrev = state.abb,
                   Region = state.region,
                   Division = state.division)
  return (df)
}


bublePlot <- function(data, x.min, x.max, y.min, y.max, abbre, sizeBy, fitYes){
  data.x<-subset(data, data$Population>=x.min & data$Population<=x.max)
  data.y<-subset(data.x, data$Income>=y.min & data$Income<=y.max)
  cols<-colnames(data.y)
  data.New<-data.y[!rowSums(is.na(data.y[cols])), ]
  if (sizeBy == 'Illiteracy'){
  p <- ggplot(data.New, aes(x = Population,y = Income,color = Region,size = Illiteracy)) 
  anontateText<-paste("Circle area is proportional to ", names(data.New)[3])}
  if (sizeBy == 'Life Expectency'){
    p <- ggplot(data.New, aes(x = Population,y = Income,color = Region,size = Life.Exp)) 
    anontateText<-paste("Circle area is proportional to ", names(data.New)[4])
  }
  if (sizeBy == 'Murder'){
    p <- ggplot(data.New, aes(x = Population,y = Income,color = Region,size = Murder)) 
    anontateText<-paste("Circle area is proportional to ", names(data.New)[5])
  }
  
  p<-p + geom_point (alpha=0.6, position = 'jitter')
  p<-p + scale_size_area(max_size = 10, guide='none')
  scales<-c(min(data.New[,1])-.1*(min(data.New[,1])),max(data.New[,1])+.1*(max(data.New[,1])),min(data.New[,2])-.1*(min(data.New[,2])),max(data.New[,2])+.1*(max(data.New[,2])))
  p<- p + scale_x_continuous (limits=c(0,scales[2]), expand=c(0,0))
  p<- p + scale_y_continuous (limits=c(3000,scales[4]), expand=c(0,0))
  p<- p + labs (size = names(data.New)[3],x=names(data.New)[1],y=names(data.New)[2])
  p<- p+ labs(colour='Region')
  p <- p + theme(legend.background = element_blank())
  p <- p + theme(legend.text = element_text(size = 12))
  p <- p + theme(legend.margin = unit(0, "pt"))
  p <- p + annotate(
    "text", x = 0.5*max(data.New[,1]), y = max(data.New[,2])+.05*max(data.New[,2]),
    hjust = 0.5, color = "grey40", size=8,
    label = anontateText)
  p<-p + theme(panel.background = element_rect(fill = NA))
  p<-p + theme(panel.grid.major = element_line(color='grey', linetype=1))
  p<-p + theme(panel.grid.minor = element_line(color='grey', linetype=2))
  if (abbre == TRUE){
  p<-p + geom_text(aes(label=Abbrev), size=3, color='black')}
  
  if (fitYes==TRUE){
    p<-p+geom_smooth(aes(x=Population, y=Income), method=lm, linetype=2,size = 1, colour = "red", se = TRUE, stat = "smooth")
  }
  
  return (p)
}

scatPlot <- function(data.new, nn){
  if (nn=='Population vs Income'){n<-2}
  if (nn== 'Population vs Income vs Illiteracy'){n<-3}
  if (nn == 'Population vs Income vs Illiteracy vs Life. Exp') {n<-4} 
  if (nn == 'Population vs Income vs Illiteracy vs Life.Exp vs Murder') {n<-5}    
  p<-ggpairs (data.new, 
              columns=1:n,
              upper ='blank',
              lower=list(continuous = 'points'),
              diag = list(continuous ='density'),
              axisLabels = 'none',
              colour = 'Region',
              legends=T)
  for (i in 1:n) {
    inner = getPlot(p, i, i);
    inner = inner + theme(panel.grid = element_blank());
    p <- putPlot(p, inner, i, i);}
  return(p)

}

paraPlot <- function(data.new, typeVec){
  typeVec.new <-as.numeric(typeVec) #change character to numbers
  typeNames <-c('Illiteracy', 'Life.Exp', 'Murder')
  colnames<-cbind('Population','Income', typeNames[typeVec.new], 'Region.new', 'Abbrev', 'Region')
  
  if(length(typeVec.new)==0){n<-2
                             k<-8
  data.new.2 <-data.new}
  
  if(length(typeVec.new)==1){   
    data.new.2<-data.new[,colnames(data.new)%in%colnames] 
    n<-3
    k<-6}
  
  if(length(typeVec.new)==2){   
    data.new.2<-data.new[,colnames(data.new)%in%colnames] 
    n<-4
    k<-7}
  if(length(typeVec.new)==3){   
    data.new.2<-data.new[,colnames(data.new)%in%colnames] 
    n<-5
    k<-8}
  p <- ggparcoord(data = data.new.2, 
  columns = 1:n, groupColumn =k , order = "anyClass",showPoints = FALSE,alphaLines = 0.6,shadeBox = NULL,
  scale = "uniminmax" 
  )
  p <- p + theme_minimal()
  p <- p + scale_y_continuous(expand = c(0.02, 0.02))
  p <- p + scale_x_discrete(expand = c(0.02, 0.02))
  p <- p + theme(axis.ticks = element_blank())
  p <- p + theme(axis.title = element_blank())
  p <- p + theme(axis.text.y = element_blank())
  p <- p + theme(panel.grid.minor = element_blank())
  p <- p + theme(panel.grid.major.y = element_blank())
  p <- p + theme(panel.grid.major.x = element_line(color = "#bbbbbb"))
  p <- p + theme(legend.position = "bottom")
  p <- p + theme(legend.text=element_text(size=20))
  p <- p + theme(axis.text=element_text(size=15))
  p <- p + theme(legend.title=element_text(size=20))
  return (p)
}

globalData<-loadData()

shinyServer(function(input, output){
  
  cat("Press \"ESC\" to exit...\n")
  data.old <- globalData
  
  Outout1<-reactive({
    genreNames <-c('Population', 'Income', 'Illiteracy','Life.Exp','Murder')
    data.new2 <- subset(data.old , select=genreNames)
    data.final <- data.frame(data.new2, Region.new=data.old$Region, Abbrev=data.old$Abbrev)
    Region<-rep('Other',length(data.final[,1]))
    if (input$regionUI=='Northeast'){
      for (i in 1:length(Region)){ if (data.final$Region.new[i]=='Northeast'){Region[i] <- 'Northeast' }}
      data.final<-data.frame(data.final, Region)
      return(data.final)}
    if (input$regionUI=='South'){
      for (i in 1:length(Region)){ if (data.final$Region.new[i]=='South'){Region[i] <- 'South'}}
      data.final<-data.frame(data.final, Region)
      return(data.final)}
    if (input$regionUI=='North Central'){
      for (i in 1:length(Region)){ if (data.final$Region.new[i]=='North Central'){Region[i] <- 'North Central'}}
      data.final<-data.frame(data.final, Region)
      return(data.final)}
    if (input$regionUI=='West'){
      for (i in 1:length(Region)){ if (data.final$Region.new[i]=='West'){Region[i] <- 'West'}}
      data.final<-data.frame(data.final, Region)
      return(data.final)}
    else{
      Region<-data.final$Region.new
      data.final<-data.frame(data.final, Region)
    return (data.final)}
  })
  
  Outout2<- reactive({
    data.new.para <- Outout1()
    print(data.new.para)
     if (input$sortUI== 'Population'){data.new3<-data.new.para[with(data.new.para, order(-Population)),]}
     if (input$sortUI== 'Income'){data.new3<-data.new.para[with(data.new.para, order(-Income)),]}
     if (input$sortUI== 'Illiteracy'){data.new3<-data.new.para[with(data.new.para, order(-Illiteracy)),]}
     if (input$sortUI== 'Life.Exp'){data.new3<-data.new.para[with(data.new.para, order(-Life.Exp)),]}
     if (input$sortUI== 'Murder'){data.new3<-data.new.para[with(data.new.para, order(-Murder)),]} 
     if (input$plotOnly == '100%'){data.final<-data.new3}
     if (input$plotOnly=='75%'){data.final <- data.new3[1:38,]}
     if (input$plotOnly=='50%'){data.final <- data.new3[1:25,]}
     if (input$plotOnly=='25%'){data.final <- data.new3[1:10,]}
    return(data.final)   
  })
  
  output$bubPlot <- renderPlot({
    bubPlot <- bublePlot(
      data=Outout1(), x.min=input$xlimUI[1], x.max=input$xlimUI[2], y.min=input$ylimUI[1], y.max=input$ylimUI[2],
      abbre=input$abbrevUI, sizeBy=input$sizeUI, fitYes=input$fitUI
    )
    print(bubPlot)
  })
  
  output$scatPlot <- renderPlot({
    scatPlot <- scatPlot(
      data=Outout2(), nn=input$scatterUI
    )
    print(scatPlot)
  })
  
  output$paraPlot <- renderPlot({
    paraPlot <- paraPlot(
      data=Outout1(), typeVec=input$typeUI
    )
    print(paraPlot)
  })
  
})
