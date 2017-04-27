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
#hr <- load(input$file)
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
            data.frame(satisfy=satislevel, Work_accident=workaccid, promotion_last_5years=promt)
    )

    fit1<-survfit(hr.cox, newdata = new)
    predict<-data.frame(fit1$surv)
    predict$time<-1:8
    predict_long<-melt(predict, id = "time")
    
    
    hr1 <- data.frame(work = hr$Work_accident, prom = hr$promotion_last_5years, 
                      satisfy = hr$satisfy, left = hr$left, time = hr$time_spend_company)
    hr2 <- subset(hr1, left != 1)
    hr2<-hr2[,-4]
    hr3 <- filter(hr2, work == workaccid, prom == promt, satisfy == satislevel)
    total <- nrow(hr3)
    stay <- c(total,rep(NA, 7))
    for (i in 2:8){
      if(sum(hr3$time == 3) !=0){
        stay[i] <- stay[i-1] - sum(hr3$time == i)
      }else{
        stay[i] <- stay[i-1]
      }
    }
    
    prob <- stay/total
    n<-sum(prob !=0)
    df<-data.frame(years = 1:n, prob = prob[1:n], pop = stay[1:n])
    plot_ly(df, x = ~years, y = ~prob, type = 'scatter', mode = 'markers',
            marker = list( size=30,opacity = 0.5)
    )%>%add_lines(x=predict_long$time,y=predict_long$value,  type = 'scatter' ,
                                            mode = 'lines+markers' ,line=list(color = 'rgb(205, 12, 24)', width = 2)) %>% layout( title = 'Who will stay',xaxis = list(title = 'Years', range = c(0,9)),yaxis=list(title = 'Probability of Stay',range=c(0,1.5)) ,showlegend = FALSE) %>% layout(paper_bgcolor='transparent') %>% layout(plot_bgcolor='transparent')
    
    # plot_ly(x = xx$years, y = xx$prob, type = 'scatter', mode = 'markers',
    #         color = as.factor(xx$years), colors = 'Paired',
    #         marker = list(size = xx$prob*50, opacity = 0.5))%>%
    #   layout(title = 'Who will stay',
    #          xaxis = list(title = 'Years', range = c(0,9)),
    #          yaxis = list(title = 'Probability of Stay'),
    #          showlegend = FALSE)
 

}

#size = ~prob*50,
shinyServer(function(input, output) {

  output$plot <- renderPlotly({hrpredict(satislevel=as.numeric(input$satislevel),workaccid=as.numeric(input$workaccid),promt=as.numeric(input$promt))})

  
})




# predict_long<-melt(predict, id = "time")
# plot_ly(x=predict_long$time,y=predict_long$value, type = 'scatter' ,
#         mode = 'lines+markers' ,line=list(color = 'rgb(205, 12, 24)', width = 2)) %>% layout(yaxis=list(range=c(0,1))) %>% layout(paper_bgcolor='transparent') %>% layout(plot_bgcolor='transparent')
# ggplot(data=predict_long, aes(x=time, y=value, colour=variable))+
#   geom_line()


