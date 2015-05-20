library (shiny)


shinyUI(
  pageWithSidebar(
    
    headerPanel('Road Casualties in Great Britain'),
    
    sidebarPanel(
      sliderInput('timeUI','Time: ', min=1969, max=1984,value= c(1969,1984)),
      sliderInput('petrolUI','Petrol Price: ', min=0.08117889, max=0.1330274,value= c(0.08117889,0.1330274)),
      sliderInput('kmsUI',' Distance Driven: ', min=7685, max=21626,value= c(7685,21626))),
    
      mainPanel(

        tabsetPanel(
        tabPanel('Area Plot', plotOutput('arePlot',width='150%', height='1000px')),
        tabPanel('Heat Map', plotOutput('heatMap',width='150%', height='1000px')),
        tabPanel('Multi Plot', plotOutput('multiPlot',width='150%', height='1000px'))
      )
    )
  ))