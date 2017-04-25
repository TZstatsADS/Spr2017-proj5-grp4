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





hr <- as.data.frame(read.csv("HR_comma_sep.csv") )

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
            mode = 'lines+markers' ,line=list(color = 'rgb(205, 12, 24)', width = 2)) %>% layout(yaxis=list(range=c(0.5,1))) %>% layout(paper_bgcolor='transparent') %>% layout(plot_bgcolor='transparent')
    # ggplot(data=predict_long, aes(x=time, y=value, colour=variable))+
    #   geom_line()

}


shinyServer(function(input, output) {

  output$plot <- renderPlotly({hrpredict(input$satislevel,as.numeric(input$workaccid),input$promt)})

  
})







# Set up handles to database tables on app start
# db <- src_sqlite("movies.db")
# omdb <- tbl(db, "omdb")
# tomatoes <- tbl(db, "tomatoes")

# Join tables, filtering out those with <10 reviews, and select specified columns
# all_movies <- inner_join(omdb, tomatoes, by = "ID") %>%
#   filter(Reviews >= 10) %>%
#   select(ID, imdbID, Title, Year, Rating_m = Rating.x, Runtime, Genre, Released,
#          Director, Writer, imdbRating, imdbVotes, Language, Country, Oscars,
#          Rating = Rating.y, Meter, Reviews, Fresh, Rotten, userMeter, userRating, userReviews,
#          BoxOffice, Production)


# function(input, output, session) {
#   
#   # Filter the movies, returning a data frame
#   movies <- reactive({
#     # Due to dplyr issue #318, we need temp variables for input values
#     reviews <- input$reviews
#     oscars <- input$oscars
#     minyear <- input$year[1]
#     maxyear <- input$year[2]
#     minboxoffice <- input$boxoffice[1] * 1e6
#     maxboxoffice <- input$boxoffice[2] * 1e6
#     
#     # Apply filters
#     m <- all_movies %>%
#       filter(
#         Reviews >= reviews,
#         Oscars >= oscars,
#         Year >= minyear,
#         Year <= maxyear,
#         BoxOffice >= minboxoffice,
#         BoxOffice <= maxboxoffice
#       ) %>%
#       arrange(Oscars)
#     
#     # Optional: filter by genre
#     if (input$genre != "All") {
#       genre <- paste0("%", input$genre, "%")
#       m <- m %>% filter(Genre %like% genre)
#     }
#     # Optional: filter by director
#     if (!is.null(input$director) && input$director != "") {
#       director <- paste0("%", input$director, "%")
#       m <- m %>% filter(Director %like% director)
#     }
#     # Optional: filter by cast member
#     if (!is.null(input$cast) && input$cast != "") {
#       cast <- paste0("%", input$cast, "%")
#       m <- m %>% filter(Cast %like% cast)
#     }
#     
#     
#     m <- as.data.frame(m)
#     
#     # Add column which says whether the movie won any Oscars
#     # Be a little careful in case we have a zero-row data frame
#     m$has_oscar <- character(nrow(m))
#     m$has_oscar[m$Oscars == 0] <- "No"
#     m$has_oscar[m$Oscars >= 1] <- "Yes"
#     m
#   })
#   
#   # Function for generating tooltip text
#   movie_tooltip <- function(x) {
#     if (is.null(x)) return(NULL)
#     if (is.null(x$ID)) return(NULL)
#     
#     # Pick out the movie with this ID
#     all_movies <- isolate(movies())
#     movie <- all_movies[all_movies$ID == x$ID, ]
#     
#     paste0("<b>", movie$Title, "</b><br>",
#            movie$Year, "<br>",
#            "$", format(movie$BoxOffice, big.mark = ",", scientific = FALSE)
#     )
#   }
#   
#   # A reactive expression with the ggvis plot
#   vis <- reactive({
#     # Lables for axes
#     xvar_name <- names(axis_vars)[axis_vars == input$xvar]
#     yvar_name <- names(axis_vars)[axis_vars == input$yvar]
#     
#     # Normally we could do something like props(x = ~BoxOffice, y = ~Reviews),
#     # but since the inputs are strings, we need to do a little more work.
#     xvar <- prop("x", as.symbol(input$xvar))
#     yvar <- prop("y", as.symbol(input$yvar))
#     
#     movies %>%
#       ggvis(x = xvar, y = yvar) %>%
#       layer_points(size := 50, size.hover := 200,
#                    fillOpacity := 0.2, fillOpacity.hover := 0.5,
#                    stroke = ~has_oscar, key := ~ID) %>%
#       add_tooltip(movie_tooltip, "hover") %>%
#       add_axis("x", title = xvar_name) %>%
#       add_axis("y", title = yvar_name) %>%
#       add_legend("stroke", title = "Won Oscar", values = c("Yes", "No")) %>%
#       scale_nominal("stroke", domain = c("Yes", "No"),
#                     range = c("orange", "#aaa")) %>%
#       set_options(width = 500, height = 500)
#   })
#   
#   vis %>% bind_shiny("plot1")
#   
#   output$n_movies <- renderText({ nrow(movies()) })
# }
