#Author: Yi He
#Data Visualization Homework 3 Ui.R

library (shiny)


shinyUI(
  navbarPage('Quality of Wine',
             tabPanel('Bubble Plot',
  pageWithSidebar(
    headerPanel('Bubble Plot of Wine Quality'),
    sidebarPanel(  
      selectInput('sizeUI', 'Bubble Size By:', choices=c('Fixed Acidity', 'Volatile Acidity', 
                                                         'Citric Acid', 'Residual Sugar',
                                                         'Chlorides', 'Free Sulfur Dioxide',
                                                         'Total Sulfur Dioxide', 'Density',
                                                         'pH', 'Sulphates', 'alcohol', 'quality')),
      selectInput('xUI', 'X-Axis:', choices=c('Fixed Acidity', 'Volatile Acidity', 
                                                         'Citric Acid', 'Residual Sugar',
                                                         'Chlorides', 'Free Sulfur Dioxide',
                                                         'Total Sulfur Dioxide', 'Density',
                                                         'pH', 'Sulphates', 'alcohol', 'quality')),
      selectInput('yUI', 'Y-Axis:', choices=c('Fixed Acidity', 'Volatile Acidity', 
                                                         'Citric Acid', 'Residual Sugar',
                                                         'Chlorides', 'Free Sulfur Dioxide',
                                                         'Total Sulfur Dioxide', 'Density',
                                                         'pH', 'Sulphates', 'alcohol', 'quality')),  
      checkboxInput("abbrevUI3", "Add Quality 3", TRUE),
      checkboxInput("abbrevUI4", "Add Quality 4", TRUE),
      checkboxInput("abbrevUI5", "Add Quality 5", TRUE),
      checkboxInput("abbrevUI6", "Add Quality 6", TRUE),
      checkboxInput("abbrevUI7", "Add Quality 7", TRUE),
      checkboxInput("abbrevUI8", "Add Quality 8", TRUE),
      sliderInput('xlimUI','Scatter X-lim: ', min=0, max=1,value= c(0,1)),
      sliderInput('ylimUI','Scatter Y-lim: ', min=0, max=1,value= c(0,1)),
      
      checkboxInput("abbrevUI", "Add Quality Abbreviation", FALSE),
      checkboxInput("fitUI", "Regression", FALSE)
      ),
    mainPanel(  
        tabPanel('Bubble Plot', plotOutput('bubPlot'), width='150%', height='800px'))
    )),
  tabPanel('Histogram Plot',
           sidebarPanel(
             selectInput('scatterUI', 'Histogram of :', choices=c('Fixed Acidity', 'Volatile Acidity', 
                                                                  'Citric Acid', 'Residual Sugar',
                                                                  'Chlorides', 'Free Sulfur Dioxide',
                                                                  'Total Sulfur Dioxide', 'Density',
                                                                  'pH', 'Sulphates', 'alcohol', 'quality')),
             selectInput('sortUI', 'Group By', choices=c('Fixed Acidity', 'Volatile Acidity', 
                                                         'Citric Acid', 'Residual Sugar',
                                                         'Chlorides', 'Free Sulfur Dioxide',
                                                         'Total Sulfur Dioxide', 'Density',
                                                         'pH', 'Sulphates', 'alcohol', 'quality')),
             checkboxInput("abbrevUI3", "Add Quality 3", TRUE),
             checkboxInput("abbrevUI4", "Add Quality 4", TRUE),
             checkboxInput("abbrevUI5", "Add Quality 5", TRUE),
             checkboxInput("abbrevUI6", "Add Quality 6", TRUE),
             checkboxInput("abbrevUI7", "Add Quality 7", TRUE),
             checkboxInput("abbrevUI8", "Add Quality 8", TRUE),
             selectInput('plotOnly', 'Plot Only:', choices=c('100%', '75%', '50%', '25%'))
             ),
           mainPanel(
             tabPanel('Scatter Matrix', plotOutput('histPlot', width='150%', height='800px'))
  ))
  
  ))
  
  
