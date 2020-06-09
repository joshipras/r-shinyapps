
shinyUI(pageWithSidebar(

  # Application title
  headerPanel("MACD tracker"),

  sidebarPanel(
   
     selectInput("currency", "Currency:",
                choices = c("AUD","CAD","CHF","CNH","CZK","DKK","EUR","GBP",
                            "HKD","HUF","INR","JPY","MXN","NOK","NZD","PLN",
                            "SAR","SEK","SGD","THB","TRY","ZAR"))
     
     
  ),

  # Plot of moving averages
  mainPanel(
    HTML("<ul>
              <li>This app can be used to track convergence and divergence of 30, 60 and 90 day moving averages of currency conversion rates.</li>
              <li> <a href = \"https://en.wikipedia.org/wiki/MACD\">Moving Average Convergence Divergence</a> is a technical indicator developed by Gerald Appel in the late 1970s. It is supposed to reveal changes in the strength, direction, momentum, and duration of a trend in a time series.</li>
              <li>This app tracks moving averages of currency conversion rates to detect strong trend changes and to indicate momentum.</li>         
              <li>The idea is to track the relationship between moving averages of the currency conversion rates for time periods of 30 days, 60 days and 90 days.</li>
              <li>As the shorter term moving average diverges further from the longer term moving average it indicates that the upside momentum is increasing. Divergence signals the end of momentum or current trend.</li>
         </ul>"),

    plotOutput("maPlot"),
    
    
    htmlOutput("conclusion"),
    
    HTML("
          <hr>
          <ul>
              <li style=\"color:#A0A0A0\"> Copyright Prasanna Joshi, 2017. All rights reserved.
         </ul>")
  )
))