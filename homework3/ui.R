#Author: Yi He
#Data Visualization Homework 3 Ui.R

library (shiny)


shinyUI(
  navbarPage('US State Facts 1977',
             tabPanel('Bubble Plot',
  pageWithSidebar(
    headerPanel('Regions and Education'),
    sidebarPanel(
      
      sliderInput('xlimUI','Scatter X-lim: ', min=365, max=21198,value= c(365,21198)),
      sliderInput('ylimUI','Scatter Y-lim: ', min=3098, max=6315,value= c(3098,6315)),
      radioButtons(
        'regionUI',
        'Regions for Scatter Matrix:', 
        c('All','Northeast', 'South', 'North Central', 'West')
      ),
      checkboxInput("abbrevUI", "Add State Abbreviation:", FALSE),
      
      selectInput('sizeUI', 'Bubble Size By:', choices=c('Illiteracy', 'Life Expectency', 'Murder')),
      checkboxInput("fitUI", "Regression", FALSE)
      ),
    mainPanel(
      
        tabPanel('Bubble Plot', plotOutput('bubPlot'), width='110%', length='110%'))
    )),
  tabPanel('ScatterPlot Matrix',
           sidebarPanel(
             selectInput('scatterUI', 'Scatter Matrix Of:', choices=c('Population vs Income', 
                                                                   'Population vs Income vs Illiteracy', 
                                                                   'Population vs Income vs Illiteracy vs Life. Exp',
                                                                   'Population vs Income vs Illiteracy vs Life.Exp vs Murder')),
             selectInput('sortUI', 'Sort By:', choices=c('Population', 'Income', 'Illiteracy', 'Life.Exp', 'Murder')),
             selectInput('plotOnly', 'Plot Only:', choices=c('100%', '75%', '50%', '25%'))
             ),
           mainPanel(
             tabPanel('Scatter Matrix', plotOutput('scatPlot', width='150%', height='800px'))
  )),
  
  tabPanel('Parallel Coordinates Plot',
           sidebarPanel(
             checkboxGroupInput('typeUI', 'Add: ',c('Illiteracy' = 1,'Life.Exp' = 2,
                                                       'Murder' = 3))
             
           ),
           mainPanel(
             tabPanel('Parallelcoord', plotOutput('paraPlot', width='150%', height='800px')))
           )))
  
  
