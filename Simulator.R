
# Load required libraries
library(shiny)
library(ggplot2)
library(readxl)
library(dplyr)

# Load data
data <- read_excel("DATA.xlsx")

# Define UI
ui <- fluidPage(
  titlePanel("AGI Profitability Simulator"),
  
  sidebarLayout(
    sidebarPanel(
      h4("Simulation Parameters"),
      numericInput("T", "Time (Years)", value = 10, min = 2, max = 50),
      hr(),
      
      h4("Revenue Parameters"),
      numericInput("markup", "Markup (%)", value = 250, step = 10),
      numericInput("growth_rate", "Annual Usage Growth Rate (%)", value = 40, step = 10),
      numericInput("tokens_per_year", "Tokens / Year", value = 5e13, step = 1e13),
      textOutput("profitPerToken"),
      hr(),
      
      h4("Cost Parameters"),
      numericInput("year", "Model Training Year", value = 2024, min = 2024, max = 2050),
      textOutput("modelCost"),
      textOutput("computeValue"),
      hr(),
      
      h4("Advanced Settings"),
      selectInput("number_format", "Training Precision", choices = c("FP32", "FP16"), selected = "FP16"),
      selectInput("price_performance", "Change in Compute Price-Performance", choices = c("Rapid", "Medium", "Slow"), selected = "Medium"),
      numericInput("delta", "Firm Discount Rate", value = 0.1, step = 0.01),
    ),
    
    mainPanel(
      plotOutput("profitPlot", height = "850px")
    )
  )
  
)

# Define server logic
server <- function(input, output) {
  
  get_price_performance_column <- function(number_format, price_performance) {
    paste0(number_format, "_", price_performance)
  }
  
  calculate_profit <- function(T, markup, delta, C, year, number_format, price_performance, growth_rate, tokens_per_year) {
    t <- seq(0, T)
    inf_flop <- data[data$Year == year, "INF_FLOP", drop = TRUE]
    debug_info <- data.frame(Year = integer(), INF_FLOP = double(), Compute_Value = double(), O = double(), Revenue = double(), Revenue_Divided_By_Markup = double(), Units = double())
    
    O <- sapply(t, function(t_year) {
        current_year <- year + t_year
        price_performance_column <- get_price_performance_column(number_format, price_performance)
        compute_value <- data[data$Year == current_year, price_performance_column, drop = TRUE]

        if (length(inf_flop) == 0 || is.na(inf_flop) || length(compute_value) == 0 || is.na(compute_value)) {
          return(NA)
          } else {
            operational_cost <- inf_flop / compute_value
            revenue <- operational_cost * (markup / 100)
            revenue_divided_by_markup <- revenue / (markup / 100)
            units <- tokens_per_year * (1 + (growth_rate / 100))^(current_year - 2024)
            debug_info <<- rbind(debug_info, data.frame(Year = current_year, INF_FLOP = inf_flop, Compute_Value = compute_value, O = operational_cost, Revenue = revenue, Revenue_Divided_By_Markup = revenue_divided_by_markup, Units = units))
            return(operational_cost)
            }
        })

    if (any(is.na(O))) {
      return(list(profit = NA, debug_info = debug_info))
      }

    revenue_values <- debug_info$Revenue
    units_values <- debug_info$Units
    P <- sum((revenue_values - O) * units_values / (1 + delta)^t) - C
    assign("debug_info", debug_info, envir = .GlobalEnv)
    
    return(list(profit = P, debug_info = debug_info))
    }
  
  get_initial_fixed_cost <- reactive({
    cost_column <- paste0("C_", input$number_format, "_", input$price_performance)
    year <- input$year
    cost_value <- data[data$Year == year, cost_column, drop = TRUE]  # Drop = TRUE to get a vector instead of data frame
    
    if (length(cost_value) == 0 || is.na(cost_value)) {
      return(NA)  
      } else {
        return(cost_value)
        }
    })
  
  output$computeValue <- renderText({
    projected_flop <- data[data$Year == input$year, "Projected_FLOP", drop = TRUE]
    if (length(projected_flop) == 0 || is.na(projected_flop)) {
      return("Projected FLOP: N/A")
    }
    paste("Projected FLOP: ", formatC(projected_flop, format = "e", digits = 2))
    })
  
  output$modelCost <- renderText({
    initial_cost <- get_initial_fixed_cost()
    paste("  Training Cost: $", scales::comma(initial_cost))
    })
  
  output$profitPerToken <- renderText({
    initial_cost <- get_initial_fixed_cost()
    if (is.na(initial_cost)) {
      return("Profit per Token: N/A")
      }
    results <- calculate_profit(input$T, input$markup, input$delta, initial_cost, input$year, input$number_format, input$price_performance, input$growth_rate, input$tokens_per_year)
    profit_per_token <- results$profit / (input$tokens_per_year * (1 + (input$growth_rate / 100))^input$T)
    
    net_earnings <- results$debug_info$Revenue - results$debug_info$O
    max_net_earnings <- max(net_earnings, na.rm = TRUE)
    min_net_earnings <- min(net_earnings, na.rm = TRUE)
    
    paste(
      "Profit per Token:",
      "[ $", formatC(min_net_earnings, format = "f", digits = 8),
      " - $",
      formatC(max_net_earnings, format = "f", digits = 8), "]"
      )
    })
  
  # Generate plot
  output$profitPlot <- renderPlot({
    initial_cost <- get_initial_fixed_cost()
    
    if (is.na(initial_cost)) {
      return(NULL)
    }
    
    t_values <- seq(0, input$T, by = 1)
    results <- lapply(t_values, calculate_profit, 
                            markup = input$markup,
                            delta = input$delta,
                            C = initial_cost,
                            year = input$year,
                            number_format = input$number_format,
                            price_performance = input$price_performance,
                            growth_rate = input$growth_rate,
                            tokens_per_year = input$tokens_per_year
    )

    profit_values <- sapply(results, function(res) res$profit)
    df <- data.frame(Year = input$year + t_values, Profit = profit_values)
    cumulative_profit <- sum(df$Profit, na.rm = TRUE)
    
    profit_color <- ifelse(cumulative_profit > 0, "lightgreen", "lightcoral")
    assign("df", df, envir = .GlobalEnv)
    
    ggplot(df, aes(x = Year, y = Profit)) +
      geom_area(data = subset(df, Profit > 0), aes(y = Profit), fill = "lightgreen", alpha = 0.5) +
      geom_area(data = subset(df, Profit < 0), aes(y = Profit), fill = "lightcoral", alpha = 0.5) +
      geom_line(color = "blue", size = 1) +
      geom_point(color = "blue", size = 2) +
      geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
      labs(x = "Year", y = "Profit ($)") +
      scale_x_continuous(breaks = seq(input$year, input$year + input$T, by = 1)) +
      scale_y_continuous(labels = scales::dollar_format()) +
      theme_classic(base_size = 15) +
      theme(
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
        axis.title.x = element_text(margin = margin(t = 15)),
        panel.grid.major = element_line(size = 0.5, linetype = 'solid', colour = "grey80"),
        panel.grid.minor = element_blank()
      ) +
      geom_label(aes(x = max(df$Year), y = min(df$Profit) + 0.0005 * diff(range(df$Profit))), 
                 label = paste("Net Present Value: $", scales::comma(cumulative_profit)), 
                 hjust = 1, vjust = 0, size = 7, 
                 color = ifelse(cumulative_profit > 0, "darkgreen", "darkred"), 
                 fill = "white", label.size = 0,
                 label.padding = unit(0.5, "lines"),
                 label.r = unit(0.15, "lines")) +
      theme(plot.margin = margin(10, 10, 20, 10))
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
