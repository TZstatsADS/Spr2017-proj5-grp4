library(ggvis)
library(dplyr)
if (FALSE) library(RSQLite)
library(ggplot2)
library(plotly)
if (!require("corrplot")) install.packages('corrplot')
if (!require("survival")) install.packages('survival')
if (!require("survminer")) install.packages('survminer')


library(randomForest)
library(randomForestSRC)
library(caret)
library(randomForest)
library(corrplot)
library(dplyr) 
library("survival")
library("survminer")
library("ggplot2")
library("reshape2")




load("hr.RData")
#hr <- as.data.frame(read.csv("HR_comma_sep.csv") )

hrpredict <- function(satislevel,workaccid,promt){
    hr$left <- factor(hr$left)
    satisfy<-rep(0,nrow(hr))
    satisfy[hr$satisfaction_level>= 0.5]<- 1
    hr$satisfy<-satisfy

    evaluate<-rep(0,nrow(hr))
    evaluate[hr$last_evaluation>= 0.6 & hr$last_evaluation<= 0.8]<- 1
    evaluate[hr$last_evaluation > 0.8] <-2
    hr$evaluate<-evaluate

    monthly.hours<-rep(0,nrow(hr))
    monthly.hours[hr$average_montly_hours>= 160 & hr$average_montly_hours<= 240]<- 1
    monthly.hours[hr$average_montly_hours > 240] <-2
    hr$monthly.hours<-monthly.hours

    hr$left<-as.numeric(hr$left)
    hr.cox <- coxph(Surv(time_spend_company, left) ~ satisfy+promotion_last_5years+Work_accident, data = hr)

    
    
    
    new <- with(hr,
            data.frame(satisfy=ifelse(satislevel>=0.5,1,0), Work_accident=workaccid, promotion_last_5years=promt)
    )

    fit1<-survfit(hr.cox, newdata = new)
    predict<-data.frame(fit1$surv)
    predict$time<-1:8

    predict_long<-melt(predict, id = "time")
    plot_ly(x=predict_long$time,y=predict_long$value, type = 'scatter' ,
            mode = 'lines+markers' ,line=list(color = 'rgb(205, 12, 24)', width = 2)) %>% layout(yaxis=list(range=c(0,1))) %>% layout(paper_bgcolor='transparent') %>% layout(plot_bgcolor='transparent')
    # ggplot(data=predict_long, aes(x=time, y=value, colour=variable))+
    #   geom_line()

}


shinyServer(function(input, output) {

  output$plot <- renderPlotly({hrpredict(input$satislevel,as.numeric(input$workaccid),input$promt)})

  
})







