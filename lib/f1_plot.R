library(dplyr)
library(plotly)

# Here, hr dataframe is the one after data processing

hr1 <- data.frame(work = hr$Work_accident, prom = hr$promotion_last_5years, 
                  satisfy = hr$satisfy, left = hr$left, time = hr$time_spend_company)
hr2 <- subset(hr1, left != 0)
hr2<-hr2[,-4]

f1_plot<-function(satislevel, workaccid, promt){
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
          color = ~as.factor(years), colors = 'Paired',
          marker = list(size = ~prob*50, opacity = 0.5))%>%
    layout(title = 'Who will stay',
           xaxis = list(title = 'Years', range = c(0,9)),
           yaxis = list(title = 'Probability of Stay'),
           showlegend = FALSE)
}
