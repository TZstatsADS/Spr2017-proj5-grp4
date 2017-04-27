# Add these two before the plot function, and replace your plot_ly function
# with below p

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
        xaxis = list(title = 'Years', range=c(0,8.5)),
        yaxis = list(title = 'Probability of Stay',range=c(0,1.1)))%>%
layout(paper_bgcolor='transparent')%>%
layout(plot_bgcolor='transparent')
