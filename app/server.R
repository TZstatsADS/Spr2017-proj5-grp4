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




#load("hr.RData")
#hr <- as.data.frame(read.csv("HR_comma_sep.csv") )
#hr <- input$file
hrpredict <- function(hr,satislevel,workaccid,promt){
    # hr<-list()
    # hr$satisfaction_level<-rr()$satisfaction_level
    # hr$last_evaluation<-rr()$last_evaluation
    # hr$left<-rr()$left
    # hr$number_project<-rr()$number_project
    # hr$average_montly_hours<-rr()$average_montly_hours
    # hr$time_spend_company<-as.numeric(rr()$time_spend_company)
    # #hr$Work_accident<-rr()$Work_accident
    # #hr$promotion_last_5years<-rr()$promotion_last_5years
    # hr$sales<-rr()$sales
    # hr$salary<-rr()$salary
    # hr<-as.data.frame(hr)

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
    m<-length(unique(hr$time_spend_company))
    predict$time<-1:m
    predict_long<-melt(predict, id = "time")


    hr1 <- data.frame(work = hr$Work_accident, prom = hr$promotion_last_5years,
                      satisfy = hr$satisfy, left = hr$left, time = hr$time_spend_company)
    hr2 <- subset(hr1, left != 1)
    hr2<-hr2[,-4]
    hr3 <- filter(hr2, work == workaccid, prom == promt, satisfy == satislevel)
    total <- nrow(hr3)
    stay <- c(total,rep(NA, m-1))
    for (i in 2:m){
      if(sum(hr3$time == 3) !=0){
        stay[i] <- stay[i-1] - sum(hr3$time == i)
      }else{
        stay[i] <- stay[i-1]
      }
    }
    
    if(total!=0){
      prob <- stay/total
    }else{
        prob<-rep(0,m)
    }
    
    n<-sum(prob !=0)
    df<-data.frame(years = 1:n, prob = prob[1:n], pop = stay[1:n])
    upper<-fit1$upper
    lower<-fit1$lower
    plot_ly(predict_long, x = ~time) %>%
      add_lines(y = ~value,
                line = list(color = 'rgba(7, 164, 181, 1)'),
                name = 'Predict Line') %>%
      add_ribbons(ymin = lower,
                  ymax = upper,
                  line = list(color = 'rgba(7, 164, 181, 0.05)'),
                  fillcolor = 'rgba(7, 164, 181, 0.2)',
                  name = '95% Confidence Interval') %>%
      add_markers(x=df$years, y = df$prob, showlegend = FALSE,
                  marker = list(size = df$pop/max(df$pop)*30,opacity = 0.2, color = 'rgb(255, 25, 24)'),
                  text = ~paste('Current Employees:', df$pop),
                  name = 'True Value') %>%
      layout(title = 'Who will stay',
             xaxis = list(title = 'Years', range=c(0,m+0.5)),
             yaxis = list(title = 'Probability of Stay',range=c(0,1.1)))%>%
      layout(paper_bgcolor='transparent')%>%
      layout(plot_bgcolor='transparent')
    
    
    # plot_ly(df, x = ~years, y = ~prob, type = 'scatter', mode = 'markers',
    #         marker = list( size=30,opacity = 0.5)
    # )%>%add_lines(x=predict_long$time,y=predict_long$value,  type = 'scatter' ,
    #                                         mode = 'lines+markers' ,line=list(color = 'rgb(205, 12, 24)', width = 2)) %>% layout( title = 'Who will stay',xaxis = list(title = 'Years', range = c(0,9)),yaxis=list(title = 'Probability of Stay',range=c(0,1.5)) ,showlegend = FALSE) %>% layout(paper_bgcolor='transparent') %>% layout(plot_bgcolor='transparent')

    # plot_ly(x = xx$years, y = xx$prob, type = 'scatter', mode = 'markers',
    #         color = as.factor(xx$years), colors = 'Paired',
    #         marker = list(size = xx$prob*50, opacity = 0.5))%>%
    #   layout(title = 'Who will stay',
    #          xaxis = list(title = 'Years', range = c(0,9)),
    #          yaxis = list(title = 'Probability of Stay'),
    #          showlegend = FALSE)
 

 }


load("hr.RData")
pred<-matrix(NA,nrow =1,ncol= ncol(hr))
colnames(pred)<-colnames(hr)
hr_zhu<-hr
hr_zhu$left <- as.factor(hr_zhu$left)
hr_zhu$salary <- ordered(hr_zhu$salary, c("low", "medium", "high"))
pred <- hr_zhu[1,]
randomforest.Model <- randomForest(left~ .,hr_zhu,ntree=25)
thisrf.predict<-3


shinyServer(function(input, output) {
  
  # hr <- reactive({
  #   infile <- input$datafile
  #   if (is.null(infile)) {
  #     # User has not uploaded a file yet
  #     return(NULL)
  #   }
  #   read.csv(infile$datapath)
  # })
  output$plot <- renderPlotly({
    input$goButton
    inFile <- isolate(input$file)
    
    if (is.null(inFile)) return(NULL)
    hr <- read.csv(inFile$datapath, header = TRUE)
    hrpredict(hr,satislevel=as.numeric(input$satislevel),workaccid=as.numeric(input$workaccid),promt=as.numeric(input$promt))})


  output$text1<-renderText({ 
    "Will you stay?"
  }) 
    output$plot2<- 
      renderImage({
        return(list(
          src = "www/dec.png",
          contentType = "image/png",
          width = 600,
          height = 400,
          alt = "dec"
        ))
      }, deleteFile = F)

  observeEvent(input$action2,{
    pred[1]<- input$satis2
    #pred[2]<- input$Evaluation
    pred[3]<-input$proj2
    pred[4]<-input$hrs2
    pred[6]<- input$workacc2
    pred[8]<- input$promt2
    pred[10] <- ordered(input$salary2, c("low", "medium", "high"))

    
    
    thisrf.predict <- predict(randomforest.Model,pred)
    
    if(thisrf.predict == 1){
      output$text1<-renderText({ 
        "I'm gonna leave! Bye Bye~"
      })
      output$plot2<- 
        renderImage({
          return(list(
            src = "www/quit.png",
            contentType = "image/png",
            width = 600,
            height = 400,
            alt = "quit"
          ))
        }, deleteFile = F)
      
    }
    else if(thisrf.predict == 0){
      output$text1<-renderText({ 
        "I'm gonna stay! Ha Ha~"
      })
      output$plot2 <- 
        renderImage({
          return(list(
            src = "www/stay.png",
            contentType = "image/png",
            width = 600,
            height = 400,
            alt = "stay"
          ))
        }, deleteFile = F)
      
      
    }
  })
})




# predict_long<-melt(predict, id = "time")
# plot_ly(x=predict_long$time,y=predict_long$value, type = 'scatter' ,
#         mode = 'lines+markers' ,line=list(color = 'rgb(205, 12, 24)', width = 2)) %>% layout(yaxis=list(range=c(0,1))) %>% layout(paper_bgcolor='transparent') %>% layout(plot_bgcolor='transparent')
# ggplot(data=predict_long, aes(x=time, y=value, colour=variable))+
#   geom_line()


