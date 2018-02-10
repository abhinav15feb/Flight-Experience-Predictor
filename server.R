#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
library(C50)
library(shiny)
library(party)
# Load library
library(randomForest)
# Help on ramdonForest package and function
library(help=randomForest)

# Load Library or packages
library(e1071)
library(caret)

rsconnect::setAccountInfo(name='flightsentiment',
                          token='__Token__',
                          secret='__secret')

library(rsconnect)
rsconnect::deployApp('.')
draft<<- read.csv("final_dataset.csv")

draft$DELAYGROUP <-round(draft$DEP_DELAY_GROUP)
draft$DELAYGROUP<-as.factor(draft$DELAYGROUP)

draft$Sentiment <-round(draft$Sentiment)
draft$Sentiment<-as.factor(draft$Sentiment)

sample_size <- floor(0.8*nrow(draft))
training_index <- sample(seq_len(nrow(draft)), size = sample_size)

training <<- draft[training_index,]
test <<- draft[-training_index,]


delayinfo<- c(-2,-1,0,1,2,3,4,5,6,7,8,9,10,11,12)
delaydesc<- c("Delay < -15 minutes", "Delay between -15 and -1 minutes","Delay between 0 and 14 minutes","Delay between 15 to 29 minutes","Delay between 30 to 44 minutes",
              "Delay between 45 to 59 minutes","Delay between 60 to 74 minutes","Delay between 75 to 89 minutes","Delay between 90 to 104 minutes","Delay between 105 to 119 minutes",
              "Delay between 120 to 134 minutes","Delay between 135 to 149 minutes","Delay between 150 to 164 minutes","Delay between 165 to 179 minutes","Delay >= 180 minutes")

delaydata<<-data.frame(delayinfo,delaydesc)
              # Define server logic required to draw a histogram

senti_score <- c(-3,-2,-1,0,1,2,3)
senti_mean <- c("Horrible","Awful","Negative","Neutral","Positive","Perfect","Awesome")
senti_def <<- data.frame(senti_score,senti_mean)
shinyServer(function(input, output) {
  ## SENTIMENT PLOT
  output$distPlot <- renderPlot({
    training_copy <<- training
    predictors <<- c('airline','hour','MONTH','DAY_OF_MONTH','DAY_OF_WEEK','DELAYGROUP')
    model <<- C5.0.default(x = training_copy[,predictors], y = training_copy$Sentiment)
    plot(model)
    summary(model) 

  })
  
  ## SENTIMENT PREDICTOR PLOT
  output$predictorPlot <- renderPlot({
    #variable importance
    VARIMP <- C5imp(model,metric = 'splits')
    VARIMP<-t(VARIMP)
    VARIMP
    barplot(VARIMP,main = "VARIABLE IMPORTANCE",xlab = "Predictor variables")    
    })
  
  
  ## SENTIMENT PLOT
    output$summary <- renderPrint({summary(model)})
    
    
    ## FLIGHT PLOT
    output$flightPlot <- renderPlot({
    training_copy2 <<- training
      predictors2 <<- c('airline','hour','MONTH','DAY_OF_MONTH','DAY_OF_WEEK')
      model2 <<- C5.0.default(x = training_copy2[,predictors2], y = training_copy2$DELAYGROUP)
      plot(model2)
      summary(model2) 

    })
    
    ## FLIGHT PRED PLOT
    output$flightpredPlot <- renderPlot({
      VARIMP <- C5imp(model,metric = 'splits')
      VARIMP<-t(VARIMP)
      VARIMP
      barplot(VARIMP,main = "VARIABLE IMPORTANCE",xlab = "Predictor variables")    
      
            })
    
    ## FLIGHT SUMMARY
    output$flightsummary <- renderPrint({
      summary(model2)
    })
    

    
    
    
# LAST TAB: OUTPUT PREDICTOR  
  output$userOutput <- renderText({
      
      airline_val1 <-data.frame(input$Airline_Carriers,input$Hour,input$Month, input$Day, input$`The Day of Week`)
#      head(airline_val2)
      names(airline_val1) <- c('airline','hour','MONTH','DAY_OF_MONTH','DAY_OF_WEEK')
      pred3 <<- predict(model2, airline_val1)
      disp <- delaydata[delaydata$delayinfo == pred3,2]
      paste("The Predicted Delay is :",disp)
      
    })
    
    output$userOutput2 <- renderText({
      
      airline_val2 <-data.frame(input$Airline_Carriers,input$Hour,input$Month, input$Day, input$`The Day of Week`,pred3)
      #      head(airline_val2)
      names(airline_val2) <- c('airline','hour','MONTH','DAY_OF_MONTH','DAY_OF_WEEK','DELAYGROUP')
      pred4 <<- predict(model, newdata = airline_val2, type="class")
      disp <- senti_def[senti_def$senti_score == pred4,"senti_mean"]
      paste("The Predicted Sentiment is :",disp)
    
    })
})
