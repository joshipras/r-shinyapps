library(dplyr)
library(shiny)
library(data.table)
library(ggplot2)
library(quantmod)
library(curl)
library(rsconnect)
library(shinytoastr)

# 
# source("http://bioconductor.org/biocLite.R")
# devtools::install_github("joshuaulrich/quantmod@144_getFX")
# setwd("~/Documents/extras/github-projects/useful shiny applications/currency exchange rate tracker/currency-exchange-rate-tracker2")

shinyServer(function(input, output) {

  output$maPlot <- renderPlot({
    
    currencies <- paste0("USD/",input$currency)
    to.date <- Sys.Date() 
    from.date <-  to.date - 149 
      
    # get conversion rates for the time interval
    
    getFX(currencies,
          from = from.date, to = to.date,
          env = .GlobalEnv,
          verbose = FALSE,
          warning = TRUE,
          auto.assign = TRUE)

    curr.time.series <- setDT(as.data.frame(get(paste0("USD",input$currency))), keep.rownames = TRUE)[]
    colnames( curr.time.series) <- c("Date","Rate")
    curr.time.series <-  curr.time.series %>% arrange(desc(Date))
    
    # Calculate moving averages: 
    curr.time.series.abs <- data.frame(curr.time.series$Date[1:30], as.data.frame( curr.time.series$Rate)[1:30,])
    curr.time.series.30.ma <- data.frame(curr.time.series$Date[1:30], as.data.frame(rollmean(curr.time.series$Rate, 30))[1:30,])
    curr.time.series.60.ma <- data.frame(curr.time.series$Date[1:30], rollmean( curr.time.series$Rate, 60)[1:30]) 
    curr.time.series.90.ma <- data.frame(curr.time.series$Date[1:30], as.data.frame(rollmean( curr.time.series$Rate, 90))[1:30,]) 
    moving.averages <- data.frame( curr.time.series.abs[,1], curr.time.series.30.ma[,2],  curr.time.series.60.ma[,2],  curr.time.series.90.ma[,2],  curr.time.series.abs[,2]) 
    colnames(moving.averages) <- c("Date", "30 Day", "60 Day", "90 Day","Current")
    

    
    # line plots of moving averages
    ma.plot <- ggplot(data=moving.averages, 
      aes(x=Date, y=`30 Day`, group=1)) + 
      geom_line(color="green4") +
      geom_line(aes(y = `60 Day`), colour="darkolivegreen3") +
      geom_line(aes(y = `90 Day`), colour="darkolivegreen1") +
      geom_line(aes(y = `Current`), colour="black") +
      ggtitle('Currency Moving Averages ') + 
      ylab(input$currency) +
      xlab("") +
      theme_bw() + 
      theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
      theme(axis.title=element_text(face="bold", size="12", color="darkgreen"))

    
    
    
    plot(ma.plot)
    
    # moving averages values from 1 day ago
    y_30d <- moving.averages[2,'30 Day']
    y_60d <- moving.averages[2,'60 Day']
    y_90d <- moving.averages[2,'90 Day']
    
    # moving averages values from current day 
    t_30d <- moving.averages[1,'30 Day']
    t_60d <- moving.averages[1,'60 Day']
    t_90d <- moving.averages[1,'90 Day']
    
    # If crossover occured, print conclusion
    if(y_30d < y_60d && t_30d >= t_60d){
      output$conclusion <- renderUI({"<b>Cross-Over occurred, upside momentum is increasing</b>"})
      } 
    
    if(y_30d < y_90d && t_30d >= t_90d){
      output$conclusion <- renderUI({print("<b>Cross-Over occurred, upside momentum is increasing</b>")})
      } 
    
    if(y_60d < y_90d && t_60d >= t_90d){
      output$conclusion <- renderUI({HTML("<b>Cross-Over occurred, upside momentum is increasing</b>")})
      } 
    
    })
})


