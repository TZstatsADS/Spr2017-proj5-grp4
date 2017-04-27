library(shiny)
library(plyr)
library(dplyr)
library(data.table)
library(rvest)
library(stringr)
library(tidyr)
library(RColorBrewer)
library(dplyr)
library(ggvis)
library(plotly)

load("hr.RData")

shinyUI(navbarPage("Who Will Leave",fluid = TRUE,
               
                   tabPanel("Home",
                            sidebarLayout(
                              div(class="side", sidebarPanel(width=0)),
                              mainPanel(width=12,
                                        img(src="HR1.png", style="width:100%")
                                        )
                            )
                          ),
                   tabPanel("Random Forest Prediction",
                            div(class="outer",
                                
                                tags$head(
                                  # Include our custom CSS
                                  includeCSS("styles.css"),
                                  includeScript("gomap.js")
                                ),
                                #   fluidRow(
                                #     column(3,
                                #   wellPanel(
                                #      sliderInput("satislevel", label = h3("Satisfaction Level"), min = 0,
                                #                  max = 1, value = 0.5),
                                #      numericInput("workaccid", label = h3("Previous Work Accidents"), value = 0))
                                #      
                                #      
                                #      
                                #      
                                #      
                                #      
                                #      
                                #      ),
                                #   hr(),
                                #   
                                # verbatimTextOutput("value2"),
                                # verbatimTextOutput("value3")
                                fluidPage(
                                  br(),
                                  fluidRow(
                                    column(3,
                                           wellPanel(
                                             h4("Select Your Employee's Conditions"),
                                             #fileInput("file", label = h3("File input")),
                                             #radioButtons("satislevel", label = h3("Satisfaction Level"), choices =list("Satisfy with the job"=1,"Dissatisfy with the job"=0),selected = 1),
                                             sliderInput("satis2", label = h5("Satisfaction Level"), min = 0, 
                                                         max = 1, value = 0.5),
                                             
                                             numericInput("workacc2", label = h5( "Work Accidents"),value = 0),
                                             numericInput("promt2", label = h5("Promotions in Last 5 Years"), value = 0),
                                             
                                             
                                             # radioButtons("salary", label = h3("Salary"),
                                             #            choices = list("High" = "high", "Medium" = "medium", "Low" = "low"),
                                             #            selected = 1),
                                             #selectInput("position", label = h3("Position"),
                                              #           choices = list("Accounting" = "accounting", "HR" = "hr", "IT" = "IT","Management" = "management","Marketing"="marketing","Product Manager" = "product_mng","R&D"="RandD","Sales"="sales","Support"="support","Technical"="technical"),
                                             #            selected = "sales"),
                                              numericInput("num3", label = h5("Number of Projects"), value = 0),
                                              numericInput("num4", label = h5("Average Monthly Working Hours"), value = 0),
                                              sliderInput("Evaluation", label = h5("Evaluation Score"), min = 0,
                                                               max = 1, value = 0.5),
                                             
                                             actionButton("action2", label = "Action")
                                             
                                           )
                                    ),
                                    br(),
                                    br(),
                                    br(),
                                    column(9,
                                           h1(textOutput("text1")),
                                           imageOutput("plot2", height = 300)
                                           
                                    )
                                  )
                                )
                                
                            )
                            
                   ),
                    tabPanel("Make a Prediction",
                            div(class="outer",
                                
                                tags$head(
                                  # Include our custom CSS
                                  includeCSS("styles.css"),
                                  includeScript("gomap.js")
                                ),
                              #   fluidRow(
                              #     column(3,
                              #   wellPanel(
                              #      sliderInput("satislevel", label = h3("Satisfaction Level"), min = 0,
                              #                  max = 1, value = 0.5),
                              #      numericInput("workaccid", label = h3("Previous Work Accidents"), value = 0))
                              #      
                              #      
                              #      
                              #      
                              #      
                              #      
                              #      
                              #      ),
                              #   hr(),
                              #   
                              # verbatimTextOutput("value2"),
                              # verbatimTextOutput("value3")
                              fluidPage(
                                br(),
                                fluidRow(
                                  column(3,
                                         wellPanel(
                                           h4("Select Your Employee's Conditions"),
                                           fileInput("file", label = h3("File input"),accept=c('text/csv',
                                                                                               'text/comma-separated-values,text/plain',
                                                                                               '.csv')),
                                           actionButton("goButton", "Go!"),
                                           radioButtons("satislevel", label = h3("Satisfaction Level"), choices =list("Satisfy with the job"=1,"Dissatisfy with the job"=0),selected = 1),
                                           radioButtons("workaccid", label = h3( "Work Accidents"),choices = list("Have"=1,"Don't Have"=0),selected=1),
                                           radioButtons("promt", label = h3("Promotions in Last 5 Years"), choices = list("Have"=1,"Don't Have"=0),selected=1)
                                           # radioButtons("salary", label = h3("Salary"),
                                           #            choices = list("High" = "high", "Medium" = "medium", "Low" = "low"),
                                           #            selected = 1),
                                           # selectInput("position", label = h3("Position"),
                                           #            choices = list("Accounting" = "accounting", "HR" = "hr", "IT" = "IT","Management" = "management","Marketing"="marketing","Product Manager" = "product_mng","R&D"="RandD","Sales"="sales","Support"="support","Technical"="technical"),
                                           #            selected = "sales"),
                                           # numericInput("num3", label = h3("Number of Projects"), value = 0),
                                           # numericInput("num4", label = h3("Average Monthly Working Hours"), value = 0),
                                           # sliderInput("slider2", label = h3("Evaluation Score"), min = 0,
                                           #                  max = 1, value = 0.5),
                                           
                                          
                                           
                                         )
                                  ),
                                  br(),
                                  br(),
                                  br(),
                                   column(9,
                                          #verbatimTextOutput("value")
                                         plotlyOutput("plot")

                                  )
                                )
                              )
                              
                                )
                               
                                )
                   
                                   
                            )
)

                    
                                
                            


                                
                                
