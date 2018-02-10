#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Flight Data"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      selectInput("Airline_Carriers", "Select Airline Carrier",
                  choices=c("AA","UA","DL","NK","WN"), width="120px"),
      selectInput("The Day of Week","Please select the departure day of week",
                  choices=c("1","2","3","4","5","6","7"),width="120px"),
      
      selectInput("Day", "Select day of departure",
                  choices = c("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31"), width="120px"),
      
      selectInput("Hour", "Select departure hour",
                  choices = c("1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24"), width="120px"),
      
      selectInput("Month", "Select Month",
                  choices = c("1","2","3","4","5","6","7","8","9","10","11","12"), width="120px"),
      width = 2),
    
    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(
        tabPanel("Sentiment Graph", plotOutput("distPlot"),plotOutput("predictorPlot")),
        tabPanel("Sentiment Summary", verbatimTextOutput("summary")),
        tabPanel("Flight Graph", plotOutput("flightPlot"),plotOutput("flightpredPlot")),
        tabPanel("Flight Summary", verbatimTextOutput("flightsummary")),
        tabPanel("User Output", textOutput("userOutput"), textOutput("userOutput2"))
        
      )
    )
  )
))
