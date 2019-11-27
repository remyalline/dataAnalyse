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
# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("survey on vote intention in UK 1997-2001"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
        selectInput("ylabel", "ylabel:",
                    choices= names(BEPS)),
        selectInput("xlabel", "xlabel:",
                    choices= names(BEPS)),
        selectInput("ylabel2", "ylabel histogramme:",
                    choices= names(BEPS))

        
          
        ),
   
      
       
         
      
      # Show a plot of the generated distribution
      mainPanel(
         plotOutput("distPlot"),
         plotOutput("PiePlot")
      )
   ))


# Define server logic required to draw a histogram
server <- function(input, output) {
   data("BEPS")
   data1<-reactive({input$ylabel})
   data2<-reactive({input$xlabel})
   data3<-reactive({input$ylabel2})
   data4<-reactive({"age"})
   output$distPlot <- renderPlot({
      # generate bins based on input$bins from ui.R
     plot(get(data1())~get(data2()),
     data=BEPS)
     


      # draw the histogram with the specified number of bins
      
   })
   
   output$PiePlot <- renderPlot({
     
     x<-input$ylabel2
     print(x)
     mytable <- table(BEPS[,x])
 
     lbls <- paste(names(mytable), "\n", mytable, sep="")
     pie(mytable, labels = lbls,
         main=sprintf("Pie Chart of \"%s\"\n (with sample sizes)",x))
     
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

