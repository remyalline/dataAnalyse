#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(carData)
library(ggplot2)
library(dplyr)
library(plotly)
library(dplyr)
# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("OUR APP TITLE TO CHANGE"),
  navbarPage("Navbar!",id="tabx",
                  
                  tabPanel("Trains",
                           sidebarLayout(
                             sidebarPanel(
                               selectInput("ylabel1", "ylabel for first graph (sums):",
                                           choices= list("total_num_trips","num_late_at_departure","num_arriving_late","avg_delay_all_departing","avg_delay_all_arriving","num_of_canceled_trains","num_greater_60_min_late")),
                               selectInput("ylabel2", "ylabel for secound graph (avg):",
                                           choices= list("num_late_at_departure","num_arriving_late","avg_delay_all_departing","avg_delay_all_departing")),
                               selectInput("xlabel", "Xlabel:",
                                           choices= list("year","service","departure_station","arrival_station","journey_time_avg")),
                               selectInput("pielabel", "label for the third graph",
                                           choices= list("num_of_canceled_trains","Delay causes"))),
                               mainPanel(
                           
                           
                           
                           
                           plotlyOutput("plotly1"),
                                        plotlyOutput("plotly2"),
                                        plotlyOutput("plotly3"),
                                        plotlyOutput("plotly4")))),
                  
              
                  
                  tabPanel("planes",
                           sidebarLayout(
                             sidebarPanel(
                               selectInput("ylabel1planes", "label for first graph (sums):",
                                                      choices= list("DISTANCE","delayed","number of flights")),
                                selectInput("ylabel2planes", "ylabel for secound graph (avg):",
                                                      choices= list("DISTANCE","DURATION","DEPARTURE_DELAY","ARRIVAL_DELAY")),
                                selectInput("xlabelplanes", "Xlabel:",
                                                      choices= list("ORIGIN_AIRPORT","DESTINATION_AIRPORT","AIRLINE"))),
                             mainPanel(
                                      plotlyOutput("plotly1planes"),
                                      plotlyOutput("plotly2planes")))),
                  tabPanel("map",plotlyOutput("plotlymap") )
      )
    
    

  )


# Define server logic required to draw a histogram
server <- function(input, output) {
  
  
  output$plotly1 <- renderPlotly({
    input$tabx
    plot_ly(df, x = ~eval(as.name(input$xlabel)), y = ~eval(as.name(input$ylabel1)), type = 'bar', name = 'Sum',
            transforms=
              list(list
                   (type='aggregate',groups=as.name(input$xlabel),
                     aggregations=list(list(target='y',func='sum',enabled=T))))) %>%
      layout(yaxis = list(title = input$ylabel1),xaxis = list(title = input$xlabel), barmode = 'group')
  })
  
  output$plotly2 <- renderPlotly({
    input$tabx
    x<-input$xlabel
    y<-input$ylabel
    df2=df
    df2[y] <- df2[y]/dim(df2[y])[1]
    plot_ly(df, x = ~eval(as.name(input$xlabel)), y = ~eval(as.name(input$ylabel2)), type = 'bar', name = 'Sum',
            transforms=
              list(list
                   (type='aggregate',groups=as.name(input$xlabel),
                     aggregations=list(list(target='y',func='avg',enabled=T))))) %>%
      layout(yaxis = list(title = input$ylabel2),xaxis = list(title = input$xlabel), barmode = 'group')
    
    

    
    
    
  })
  output$plotly3 <- renderPlotly({
    input$tabx
    
    plot_ly(df, x = ~eval(as.name(input$xlabel)), y = ~delay_cause_rail_infrastructure, type = 'bar', name = 'cause_rail_infrastructure',
            transforms=
              list(list
                   (type='aggregate',groups=as.name(input$xlabel),
                     aggregations=list(list(target='y',func='sum',enabled=T))))) %>%
      add_trace(y = ~delay_cause_rolling_stock, name = 'cause_rolling_stock') %>%
      add_trace(y = ~delay_cause_travelers, name = 'cause_travelers') %>%
      add_trace(y = ~delay_cause_station_management, name = 'cause_station_management') %>%
      add_trace(y = ~delay_cause_traffic_management, name = 'cause_traffic_management') %>%
      add_trace(y = ~delay_cause_external_cause, name = 'cause_external_cause') %>%
      layout(yaxis = list(title = 'Count'), barmode = 'stack')
    
    
  })
  
  output$plotlymap <- renderPlotly({
    input$tabx
    geo <- list(
      scope = 'north america',
      projection = list(type = 'azimuthal equal area'),
      showland = TRUE,
      landcolor = toRGB("gray95"),
      countrycolor = toRGB("gray80")
    )
    plot_geo(locationmode = 'USA-states', color = I("red")) %>%
      add_markers(
        data = dftraffic, x = ~LATITUDE_ARRIVAL, y = ~LONGITUDE_ARRIVAL, text = ~AIRPORT,
         hoverinfo = "text", alpha = 0.5
      ) %>%
      add_segments(
        data = dftraffic,
        x = ~LONGITUDE_ORIGIN, xend = ~LONGITUDE_ARRIVAL,
        y = ~LATITUDE_ORIGIN, yend = ~LATITUDE_ARRIVAL,
        alpha = 0.3, size = I(1), hoverinfo = "none"
      ) %>%
      layout(
        title = ' flight paths<br>(Hover for airport names)',
        geo = geo, showlegend = FALSE, height=800
      )
    
    
  })
  
  
  output$plotly4 <- renderPlotly({
    input$tabx
    
    total=df
    total$percentageofcancel=(total$num_of_canceled_trains/total$total_num_trips)*100
    total$percentageofcancel[is.infinite(total$percentageofcancel)] <- 0
    total$percentageofnotcancel=100-total$percentageofcancel
    
    plot_ly(total, x = ~eval(as.name(input$xlabel)), y = ~percentageofcancel, type = 'bar', name = '(%) canceled trains',
            transforms=
              list(list
                   (type='aggregate',groups=as.name(input$xlabel),
                     aggregations=list(list(target='y',func='sum',enabled=T))))) %>%
      add_trace(y = ~percentageofnotcancel, name = '(%) not canceled trains') %>%
      layout(yaxis = list(title = 'Count'), barmode = 'stack')
    
    
  })
  
  





  output$plotly2planes <- renderPlotly({
  input$tabx
  
  if (input$xlabelplanes=="ORIGIN_AIRPORT")
  {
    dataused<-planesbyorisavg
  }
  else if (input$xlabelplanes=="DESTINATION_AIRPORT")
  {
    dataused<-planesbydestavg
  }
  else
  {
    dataused<-planesbyairavg
  }
  plot_ly(dataused, x =  ~eval(Group.1), y = ~eval(as.name(input$ylabel2planes)), type = 'bar', name = 'Sum') %>%
      layout(yaxis = list(title = input$ylabel2planes),xaxis = list(title = input$xlabelplanes), barmode = 'group')
    
  
  
})
  
  
  output$plotly1planes <- renderPlotly({
    input$tabx
    
    if (input$xlabelplanes=="ORIGIN_AIRPORT")
    {
      dataused<-planesbyorisum
    }
    else if (input$xlabelplanes=="DESTINATION_AIRPORT")
    {
      dataused<-planesbydestsum
    }
    else
    {
      dataused<-planesbyairsum
    }
    plot_ly(dataused, x =  ~eval(Group.1), y = ~eval(as.name(input$ylabel1planes)), type = 'bar', name = 'Sum') %>%
      layout(yaxis = list(title = input$ylabel2planes),xaxis = list(title = input$xlabelplanes), barmode = 'group')
    
    
    
  })


}




# Run the application 
shinyApp(ui = ui, server = server)

