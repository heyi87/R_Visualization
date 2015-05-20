
library(ggplot2)
library(reshape2)
library(grid)
library(scales)
source('fun.r')
data(Seatbelts)

areaPlot<-function(molten){
  data.plot<-subset(molten, variable != 'total')
  p.area <- ggplot(data.plot, aes(x=time, y=value))
  p.area <- p.area+geom_area(aes(group=variable, fill = variable, color= variable))
  p.area <- p.area +  scale_x_continuous(name = "Year",limits = c(min(data.plot$time), max(data.plot$time) ),
    expand = c(0, 0),breaks = c(seq(as.numeric(as.character(min(data.plot$year))), as.numeric(as.character(max(data.plot$year))), 1), as.numeric(as.character(max(data.plot$time))) ),labels = function(x) {ceiling(x)}
  )
  p.area <- p.area + scale_deaths()
  p.area <- p.area + theme_legend()
  p.area <- p.area + coord_fixed (ratio=1/1000)
  p.area <- p.area + theme(panel.background = element_rect(fill = NA))
  p.area <- p.area + theme(legend.text=element_text(size=40))
  p.area <- p.area + theme(panel.grid.major = element_line(color='grey', linetype=1))
  p.area <- p.area + theme(panel.grid.minor = element_line(color='grey', linetype=2))
  p.area <- p.area + theme(axis.text=element_text(size=30),
          axis.title=element_text(size=40,face="bold"))
  return(p.area)
}

heatPlot<-function(molten){
  p.heat <- ggplot(subset(molten, variable =='total'),aes(x=month, y=year)) 
  p.heat <- p.heat + geom_tile(aes(fill = value), colour = "white") 
  p.heat <- p.heat + scale_fill_gradientn(colours = brewer_pal(type = "div", palette = "PRGn")(5),
                                          name = "Deaths",limits = c(0, 3000),breaks = c(0, 2000, 4000))
  p.heat <- p.heat + scale_x_discrete(name = "Month",expand = c(0, 0))
  p.heat <- p.heat + scale_y_discrete(expand = c(0, 0))
  p.heat <- p.heat +  theme(axis.text.y = element_text(angle = 90,hjust = 0.5),
                            axis.ticks = element_blank(),
                            axis.title = element_blank(),
                            legend.direction = "horizontal",
                            legend.position = "bottom",
                            panel.background = element_blank()
  )
  p.heat <- p.heat + theme(legend.text=element_text(size=20))
  p.heat <- p.heat + theme(legend.title=element_text(size=20))
  p.heat <- p.heat + theme(axis.text=element_text(size=20),
                           axis.title=element_text(size=30,face="bold"))
  p.heat <- p.heat + coord_fixed(ratio = 1)
  return(p.heat)
}

multiPlot<-function(molten){
  data.plot <- subset(molten, variable == "total")
  p.mult <- ggplot(data.plot, aes(x = month, y = value, group = year, color = year))
  p.mult <- p.mult + geom_line(alpha = 0.8)
  palette1 <- c('#a6cee3','#1f78b4','#b2df8a','#33a02c','#fb9a99','#e31a1c','#fdbf6f','#ff7f00','#cab2d6',
                '#6a3d9a','#ffff99','#b15928','#d9d9d9','#fccde5','#b3de69','#fdb462')
  p.mult <- p.mult + scale_fill_manual(values=palette1)
  p.mult <- p.mult + scale_months()
  p.mult <- p.mult + scale_y_continuous(name = "Deaths in Thousands",limits = c(0, 3500),expand = c(0, 0),breaks = seq(0, 4000, 500),
    labels = function(x) {paste0(x / 1000, 'k')})
  p.mult <- p.mult + theme_legend()
  p.mult <- p.mult + theme_guide()
  p.mult <- p.mult + theme(panel.background = element_rect(fill = NA))
  p.mult <- p.mult + theme(panel.grid.major = element_line(color='grey', linetype=1))
  p.mult <- p.mult + theme(panel.grid.minor = element_line(color='grey', linetype=2))
  p.mult <- p.mult + theme(legend.text=element_text(size=40))
  p.mult <- p.mult + theme(axis.text=element_text(size=30),axis.title=element_text(size=40,face="bold"))
  return(p.mult)
}


globalData<-Seatbelts

shinyServer(function(input, output){
  cat("Press \"ESC\" to exit...\n")
  
  data.in<-globalData
  
  outputData <- reactive({
    times<-time(data.in[,1])
    years <- floor(times)
    years <- factor(years, ordered=TRUE)
    cycle(times)
    months <- factor (month.abb[cycle(times)], levels=month.abb, ordered=TRUE)
    deaths<-data.frame(year=years, month=months, time=as.numeric(times),
                       total=as.numeric(data.frame(data.in)$drivers), 
                       front=as.numeric(data.frame(data.in)$front),
                       rear=as.numeric(data.frame(data.in)$rear),
                       PetrolPrice = as.numeric(data.frame(data.in)$PetrolPrice),
                       kms=as.numeric(data.frame(data.in)$kms))

    death.new <- subset(deaths, deaths$year>=input$timeUI[1] & deaths$year<=input$timeUI[2] &
                                deaths$PetrolPrice>=input$petrolUI[1] & deaths$PetrolPrice<=input$petrolUI[2] &
                                deaths$kms >= input$kmsUI[1] & deaths$kms[1] <= input$kmsUI[2])      
    death.plot <- data.frame(year=death.new$year, month=death.new$month, time=death.new$time,
                   total=death.new$total, front=death.new$front, rear=death.new$rear)
    
    molten <- melt(death.plot, id= c('year', 'month', 'time'))
    return(molten)
    
  })
  
  output$arePlot <- renderPlot({
    arePlot <- areaPlot(
      outputData()
    )
    print(arePlot)
  })
  
  output$heatMap <- renderPlot({
    heatMap <- heatPlot(
      outputData()
    )
    print(heatMap)
  })
  
  output$multiPlot <- renderPlot({
    multiPlot <- multiPlot(
      outputData()
    )
    print(multiPlot)
  })
  
})