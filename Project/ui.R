#Author: Yi He
#Data Visualization Homework 3 Ui.R

library (shiny)


shinyUI(
  navbarPage('Wine Quality',
             tabPanel('Exploratory Data Analysis',
                      fluidPage(
                        sidebarPanel(  
                          
                          selectInput('xUI', 'X-Axis:', choices=c('FixedAcidity', 'VolatileAcidity', 
                                                                  'CitricAcid', 'ResidualSugar',
                                                                  'Chlorides', 'FreeSulfurDioxide',
                                                                  'TotalSulfurDioxide', 'Density',
                                                                  'pH', 'Sulphates', 'Alcohol', 'Quality')),
                          selectInput('yUI', 'Y-Axis:', choices=c('VolatileAcidity', 'FixedAcidity', 
                                                                  'CitricAcid', 'ResidualSugar',
                                                                  'Chlorides', 'FreeSulfurDioxide',
                                                                  'TotalSulfurDioxide', 'Density',
                                                                  'pH', 'Sulphates', 'Alcohol', 'Quality')),
                          sliderInput('sizeUI', label='Size of Points:', min=1, max=10, value=3),
                          sliderInput('alphaSUI', label='Point Apha Level', min=0, max=1, value=0.8)
                        ),
                        mainPanel(width=10,
                          tabsetPanel(
                            tabPanel('Scatter Plot', plotOutput('bubPlot', width='100%', height='100%')),
                            tabPanel('Density Matrix', plotOutput('histPlot', width='100%', height='100%')),
                            fluidRow(
                              column(
                                4,
                                h4('Zooming'),
                                wellPanel(
                                  sliderInput('xlimUI','Scatter X-lim: ', min=0, max=1,value= c(0,1)),
                                  sliderInput('ylimUI','Scatter Y-lim: ', min=0, max=1,value= c(0,1))
                                )#wellPanel
                              ),#column
                              column(
                                4,
                                h4('Filtering'),
                                wellPanel(
                                  checkboxGroupInput("highlightUI", "Quality Highlight", c('High', 'Medium', 'Low'),
                                                     selected = c('High', 'Medium', 'Low')),
                                  checkboxInput("fitUI", "Regression", FALSE)
                                )#wellPanel
                              )#column
                            )
                          ))
                      )#fluidPage
                      ),#end of tabPanel 1,
             tabPanel('Discovery',
                      sidebarPanel(
                        checkboxInput("dLowUI", "Include Low", TRUE),
                        checkboxInput("dMediumUI", "Include Medium", TRUE),
                        checkboxInput("dHighUI", "Include High", TRUE),
                        radioButtons("colorUI","Color Types:",c("Set1","Set2","Set3"),selected="Set1"),
                        checkboxGroupInput('typeUI', 'Add: ',c('FixedAcidity' = 1,'VolatileAcidity' = 2,'CitricAcid'=3,'ResidualSugar'=4,
                                                               'Chlorides' = 5,'FreeSulfurDioxide'= 6,'TotalSulfurDioxide'=7,
                                                               'Density'=8,'pH'=9, 'Sulphates'=10,'Alcohol'=11), selected=c('FixedAcidity','VolatileAcidity',
                                                                'CitricAcid','ResidualSugar', 'Chlorides',
                                                                'Density','pH','Sulphates','Alcohol')
                                           )
                      ),
                      mainPanel(width=10,
                        tabsetPanel(
                          tabPanel('Heat Map', plotOutput('heatPlot', width='100%', height='100%')),
                          tabPanel('Parallel Coordinate Map', plotOutput('paraPlot', width='100%', height='100%'))
                      ))),
             tabPanel('RandomForest',
                      sidebarPanel(
                        checkboxInput("rMediumUI", "Include Medium Quality", TRUE),
                        sliderInput('sampleUI', label='Sample Size:', min=100, max=1500, value=1000),
                        sliderInput('treeUI', label='Number of Trees:', min=5, max=50, value=30),
                        sliderInput('nodeUI', label='Number of Nodes:', min=1, max=10, value=5)
                      ),
                      mainPanel(width=10,
                                tabsetPanel(
                                  tabPanel('Model', plotOutput('modelPlot', width='100%', height='100%')))
                      )),
             tabPanel('Principal Component Analysis and Factor Analysis',
                      sidebarPanel(
                        selectInput('xpcaUI', 'X-Axis:', choices=c('Score1', 'Score2', 
                                                                'Score3', 'Score4',
                                                                'Score5', 'Score6',
                                                                'Score7', 'Score8',
                                                                'Score9', 'Score10', 'Score11')),
                        selectInput('ypcaUI', 'Y-Axis:', choices=c('Score2', 'Score1', 
                                                                   'Score3', 'Score4',
                                                                   'Score5', 'Score6',
                                                                   'Score7', 'Score8',
                                                                   'Score9', 'Score10', 'Score11')),
                        checkboxInput("pLowUI", "Include Low", TRUE),
                        checkboxInput("pMediumUI", "Include Medium", TRUE),
                        checkboxInput("pHighUI", "Include High", TRUE),
                        sliderInput('sizePCAUI', label='Size of Points:', min=1, max=10, value=3),
                        sliderInput('sizeFAUI', label='Text Size of FA', min=3, max=15, value=6),
                        sliderInput('alphaUI', label='Point Apha Level', min=0, max=1, value=0.8)
                        ),#end of siderbarPanel
                      mainPanel(width=12,
                        tabsetPanel(
                        tabPanel('PCA-Analysis', plotOutput('pcaPlot', width='100%', height='100%')),
                        tabPanel('FA-Analysis', plotOutput('faPlot', width='100%', height='100%')),
                        tabPanel('R PCA output', tableOutput('pcaTable')),
                        tabPanel('R FA output', tableOutput('faTable'))
                        
                        )#tabsetPanel
                        )
                      )
   
  ))





