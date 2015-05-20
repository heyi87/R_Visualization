library(shiny)

shinyUI(
  pageWithSidebar(
    
    headerPanel('IMDB Movie Rating'),

    sidebarPanel(
      radioButtons(
        'mpaa',
        'MPAA Rating:', 
        c('All', 'NC-17', 'PG', 'PG-13', 'R')
        ),      
      
      checkboxGroupInput("genreUI", "Genre: ",c("Action" = 1,"Animation" = 2,
                           "Comedy" = 3, 'Drama'= 4,'Documentary'=5,
                           'Romance'=6,'Short'=7
                           )),
      
      selectInput('colorL', 'Color Type:', choices=c('Default', 'Accent', 'Set1',
                                                  'Set2','Set3','Dark2','Pastel1','Pastel2','Color-Blind Friendly')),
      checkboxInput("fitUI", "Regression", FALSE),
      sliderInput("dotSizeUI", "Dot Size:", min=0, max=10, value=3),
      sliderInput("dotAlphaUI", "Dot Alpha:", min=0, max=1, value=0.8)
    ),
    mainPanel(
      tabsetPanel(
        tabPanel('Scatter Plot', plotOutput('scatPlot')),
        tabPanel('Table: Genre vs Rating', tableOutput('getTable')),
        tabPanel('Table: MPAA vs Budget', tableOutput('getTable2'))
      )
    
  )
))

