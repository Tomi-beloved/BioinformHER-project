# Load necessary libraries
library(shiny)
library(shinythemes)
library(shinydashboard)
library(ggplot2)
library(shinyjs)

# Define UI for the application with shinydashboard
ui <- dashboardPage(
  skin = "blue",
  
  dashboardHeader(
    title = span(
      tags$img(src = "biocal.png", height = "35px", style = "margin-right: 2px;"),
      "Biocal Dashboard", 
      style = "font-family: 'League Spartan', sans-serif;"
    )
  ),
  dashboardSidebar(
    sidebarMenu(
      
      
      # V1 calculator version
      shiny::radioButtons(inputId = "version", label = "Calculator Version:", choiceNames = c("v1 (BC1)"), choiceValues = c("v1"), inline = T),
      
      menuItem("Home", tabName = "home", icon = icon("home")),
      menuItem("About", tabName = "about", icon = icon("info-circle")),
      menuItem("Calculator", tabName = "calculator", icon = icon("calculator")),
      menuItem("Contact", tabName = "contact", icon = icon("envelope"))
    )
  ),
  
  dashboardBody(
    useShinyjs(), # Include shinyjs for interactive features
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),  # Link to the CSS file
      tags$script(src = "script.js"),
      tags$style(HTML("
        @import url('https://fonts.googleapis.com/css2?family=League+Spartan:wght@400;700&family=Libre+Baskerville:wght@400;700&display=swap');
        
        body {
          font-family: 'Libre Baskerville', serif;
          background-color: #f4f6f9;
          color: #333;
        }
        
        .box-header {
          background-color: #007bff;
          color: #ffffff;
          font-family: 'League Spartan', sans-serif;
        }
        
        .box {
          border-radius: 12px;
          box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
        }
        
        .box-content {
          padding: 20px;
        }
        
        .footer {
          background-color: #ffffff;
          padding: 15px;
          text-align: center;
          border-top: 1px solid #e0e0e0;
          position: fixed;
          bottom: 0;
          width: 100%;
          font-family: 'Libre Baskerville', serif;
        }
        
        .footer a {
          color: #007bff;
          text-decoration: none;
          margin: 0 10px;
          font-family: 'League Spartan', sans-serif;
        }
        
        .footer a:hover {
          text-decoration: underline;
        }
        
        .shiny-input-container {
          margin-top: 10px;
        }
        
        .shiny-output-container {
          margin-top: 20px;
        }
        
        .shiny-input-container input, .shiny-input-container select {
          font-family: 'Libre Baskerville', serif;
          font-size: 14px;
        }
        
        .shiny-output-container h4 {
          font-family: 'League Spartan', sans-serif;
        }
        
        .note {
          display: none; /* Initially hide the note section */
        }
      "))
    ),
    
    tabItems(
      tabItem(tabName = "home",
              fluidRow(
                box(
                  title = "Welcome",
                  width = 12,
                  status = "primary",
                  solidHeader = TRUE,
                  HTML("<h2 style='font-family: \"League Spartan\", sans-serif;'>Welcome to the Biocal Calculator Dashboard!</h2>
                 <p>Welcome to the Biocal Calculator, a powerful and user-friendly web-based platform designed to assist laboratory scientists with common reagent preparation calculations. This was developed as part of a HackBio internship program, the Biocal Calculator aims to streamline daily tasks, reduce errors, and enhance efficiency in scientific research.It offers researchers quick access and a convenient user-friendly web-based platform, eliminating the need for complex software or coding knowledge allowing researchers to focus on more critical scientific tasks.</p>
                 <img src='https://via.placeholder.com/800x400.png?text=Dashboard+Overview' style='width:100%; border-radius: 12px;'>")
                )
              )
      ),
      
      tabItem(tabName = "about",
              fluidRow(
                box(
                  title = "About",
                  width = 12,
                  status = "info",
                  solidHeader = TRUE,
                  HTML("<p>The BioCal Calculator project was initiated as part of a HackBio internship program, where participants were tasked with developing R Shiny dashboards for bioinformatics applications. The goal was to provide a practical and user-friendly tool for laboratory scientists to streamline their daily tasks related to reagent preparation. By achieving these goals, the BioCal Calculator project aimed to make a positive impact on the bioinformatics community and contribute to the advancement of scientific research.</p>")
                )
              )
      ),
      
      tabItem(tabName = "calculator",
              fluidRow(
                box(
                  title = "Select Calculator",
                  width = 12,
                  status = "info",
                  solidHeader = TRUE,
                  tabBox(
                    id = "calculator_tabs",
                    width = 12,
                    tabPanel("Stock Solution Dilution",
                             fluidRow(
                               box(
                                 title = "Inputs",
                                 width = 4,
                                 status = "primary",
                                 numericInput("stock_conc", "Stock Concentration (M):", value = 1, min = 0.01, step = 0.01),
                                 numericInput("final_conc", "Desired Final Concentration (M):", value = 0.1, min = 0.01, step = 0.01),
                                 numericInput("final_volume", "Final Volume (L):", value = 1, min = 0.01, step = 0.01),
                                 actionButton("calculate_stock", "Calculate", class = "btn-primary")
                               ),
                               box(
                                 title = "Results",
                                 width = 8,
                                 status = "primary",
                                 textOutput("required_volume_stock"),
                                 plotOutput("dilution_plot_stock"),
                                 downloadButton("print_stock_result", "Print Result", class = "btn-secondary")
                               )
                             )
                    ),
                    
                    tabPanel("Serial Dilution",
                             fluidRow(
                               box(
                                 title = "Inputs",
                                 width = 4,
                                 status = "primary",
                                 numericInput("initial_conc", "Initial Concentration (M):", value = 1, min = 0.01, step = 0.01),
                                 numericInput("dilution_factor", "Dilution Factor:", value = 10, min = 1, step = 1),
                                 numericInput("num_dilutions", "Number of Dilutions:", value = 5, min = 1, step = 1),
                                 actionButton("calculate_serial", "Calculate", class = "btn-primary")
                               ),
                               box(
                                 title = "Results",
                                 width = 8,
                                 status = "primary",
                                 tableOutput("serial_dilution_table"),
                                 plotOutput("serial_dilution_plot"),
                                 downloadButton("print_serial_result", "Print Result", class = "btn-secondary")
                               )
                             )
                    ),
                    
                    tabPanel("DNA/RNA Concentration",
                             fluidRow(
                               box(
                                 title = "Inputs",
                                 width = 4,
                                 status = "primary",
                                 numericInput("absorbance", "Absorbance at 260 nm:", value = 0.1, min = 0, step = 0.01),
                                 selectInput("conversion_factor", "Select Conversion Factor:",
                                             choices = list("DNA (50 ng/μL per A260)" = 50, 
                                                            "RNA (40 ng/μL per A260)" = 40),
                                             selected = 50),
                                 actionButton("calculate_concentration", "Calculate", class = "btn-primary")
                               ),
                               box(
                                 title = "Results",
                                 width = 8,
                                 status = "primary",
                                 textOutput("concentration_result"),
                                 plotOutput("concentration_plot"),
                                 downloadButton("print_concentration_result", "Print Result", class = "btn-secondary")
                               )
                             )
                    ),
                    
                    tabPanel("Sedimentation Coefficient",
                             fluidRow(
                               box(
                                 title = "Inputs",
                                 width = 4,
                                 status = "primary",
                                 numericInput("sed_velocity", "Sedimentation Velocity (m/s):", value = 1e-5, min = 0, step = 1e-6),
                                 numericInput("ang_velocity", "Angular Velocity (rad/s):", value = 1e4, min = 0, step = 100),
                                 numericInput("rad_distance", "Radial Distance (m):", value = 0.05, min = 0.01, step = 0.01),
                                 actionButton("calculate_sedimentation", "Calculate", class = "btn-primary")
                               ),
                               box(
                                 title = "Results Panel",
                                 width = 4,
                                 status = "primary",
                                 textOutput("sedimentation_result"),
                                 downloadButton("print_sedimentation_result", "Print Result", class = "btn-secondary")
                               ),
                               box(
                                 title = "Graph Panel",
                                 width = 4,
                                 status = "primary",
                                 plotOutput("sedimentation_plot")
                               )
                             )
                    )
                  )
                )
              )
      ),
      
      
      tabItem(tabName = "contact",
              fluidRow(
                box(
                  title = "Contact",
                  width = 12,
                  status = "info",
                  solidHeader = TRUE,
                  HTML("<p>For any inquiries, please contact us at:</p>
                 <ul>
                   <li><a href='mailto:Oluwaseuntomilayo9@gmail.com'>Tomilayo Oluwaseun Fadairo</a></li><br> <li><a href='mailto:Anifowosesamuel54@gmail.com'>Akinjide Samuel Anifowose</a></li><br> <li><a href='mailto:opeoluwashodipe@gmail.com'>Opeoluwa Olutunde Shodipe</a></li><br> <li><a href='mailto:ndubungoabi2002@gmail.com'>Ndubueze Ngozika Abigail</a></li><br> <li><a href='mailto:nnekapeace85@gmail.com'>Nneka Peace</a></li><br>
                 </ul>")
                )
              )
      )
    ),
    
    tags$div(
      class = "note",
      id = "note_section",
      HTML("<div class='box'>
               <div class='box-header'>
                 <h3 class='box-title'>Notes on Using the Calculators</h3>
               </div>
               <div class='box-content'>
                 <p><strong>Stock Solution Dilution:</strong> Enter the stock concentration, desired final concentration, and final volume to calculate the required volume of stock solution.</p>
                 <p><strong>Serial Dilution:</strong> Specify the initial concentration, dilution factor, and the number of dilutions to generate a dilution series.</p>
                 <p><strong>DNA/RNA Concentration:</strong> Enter the absorbance at 260 nm and select the conversion factor (DNA or RNA) to calculate the concentration.</p>
                 <p><strong>Sedimentation Coefficient:</strong> Provide the sedimentation velocity, angular velocity, and radial distance to calculate the sedimentation coefficient.</p>
               </div>
             </div>")
    ),
    
    tags$div(
      class = "footer",
      HTML(
        "<p>Connect with us: 
      <a href='https://github.com/Tomi-beloved/hackbio-cancer-internship/blob/main/Stage%202%20task.md' target='_blank'>
        <img src='github.png' alt='GitHub' style='width:24px; height:24px;'>
      </a> 
    </p>"
    )
  )
))

# Define server logic required to perform calculations and render plots
server <- function(input, output, session) {
  
  
  # Show/hide notes section based on tab selection
  observe({
    if (input$calculator_tabs %in% c("Stock Solution Dilution", "Serial Dilution", "DNA/RNA Concentration", "Sedimentation Coefficient")) {
      shinyjs::show("note_section")
    } else {
      shinyjs::hide("note_section")
    }
  })
  
  # Stock Solution Dilution Calculator Logic
  calculate_stock_volume <- reactive({
    req(input$calculate_stock)
    stock_conc <- input$stock_conc
    final_conc <- input$final_conc
    final_volume <- input$final_volume
    required_volume <- (final_conc * final_volume) / stock_conc
    return(required_volume)
  })
  
  output$required_volume_stock <- renderText({
    req_vol_stock <- calculate_stock_volume()
    paste("Required Volume of Stock Solution:", round(req_vol_stock, 3), "L")
  })
  
  output$dilution_plot_stock <- renderPlot({
    req_vol_stock <- calculate_stock_volume()
    final_volume <- input$final_volume
    data_stock <- data.frame(
      Component = c("Stock Solution", "Diluent"),
      Volume = c(req_vol_stock, final_volume - req_vol_stock)
    )
    
    ggplot(data_stock, aes(x = Component, y = Volume, fill = Component)) +
      geom_bar(stat = "identity") +
      labs(title = "Dilution Visualization (Stock Solution)", y = "Volume (L)", x = "") +
      theme_minimal() +
      theme(legend.position = "bottom")
  })
  
  output$print_stock_result <- downloadHandler(
    filename = function() { paste("Stock_Solution_Result", Sys.Date(), ".pdf", sep = "") },
    content = function(file) {
      pdf(file)
      cat(paste("Required Volume of Stock Solution:", round(calculate_stock_volume(), 3), "L"), file = file)
      dev.off()
    }
  )
  
  # Serial Dilution Calculator Logic
  calculate_serial_dilutions <- reactive({
    req(input$calculate_serial)
    initial_conc <- input$initial_conc
    dilution_factor <- input$dilution_factor
    num_dilutions <- input$num_dilutions
    
    concentrations <- initial_conc / (dilution_factor ^ (0:(num_dilutions - 1)))
    data.frame(Dilution = 1:num_dilutions, Concentration = concentrations)
  })
  
  output$serial_dilution_table <- renderTable({
    calculate_serial_dilutions()
  })
  
  output$serial_dilution_plot <- renderPlot({
    dilution_data <- calculate_serial_dilutions()
    
    ggplot(dilution_data, aes(x = Dilution, y = Concentration)) +
      geom_line() +
      geom_point() +
      scale_y_log10() +
      labs(title = "Serial Dilution Plot", y = "Concentration (M)", x = "Dilution Step") +
      theme_minimal() +
      theme(legend.position = "bottom")
  })
  
  output$print_serial_result <- downloadHandler(
    filename = function() { paste("Serial_Dilution_Result", Sys.Date(), ".pdf", sep = "") },
    content = function(file) {
      pdf(file)
      cat("Serial Dilution Results:\n", file = file)
      cat(paste("Dilution", "Concentration (M)\n", sep = "\t"), file = file)
      write.table(calculate_serial_dilutions(), file, sep = "\t", row.names = FALSE, col.names = FALSE, append = TRUE)
      dev.off()
    }
  )
  
  # DNA/RNA Concentration Calculator Logic
  calculate_concentration <- reactive({
    req(input$calculate_concentration)
    absorbance <- input$absorbance
    conversion_factor <- as.numeric(input$conversion_factor)
    
    concentration <- absorbance * conversion_factor
    
    return(concentration)
  })
  
  output$concentration_result <- renderText({
    concentration <- calculate_concentration()
    paste("Concentration:", round(concentration, 2), "ng/μL")
  })
  
  output$concentration_plot <- renderPlot({
    concentration <- calculate_concentration()
    data <- data.frame(
      Type = c("Measured Concentration"),
      Value = c(concentration)
    )
    
    ggplot(data, aes(x = Type, y = Value, fill = Type)) +
      geom_bar(stat = "identity", width = 0.5) +
      labs(title = "DNA/RNA Concentration Visualization", y = "Concentration (ng/μL)", x = "") +
      theme_minimal() +
      scale_fill_manual(values = c("Measured Concentration" = "#007bff")) +
      geom_text(aes(label = round(Value, 2)), vjust = -0.5)
  })
  
  output$print_concentration_result <- downloadHandler(
    filename = function() { paste("Concentration_Result", Sys.Date(), ".pdf", sep = "") },
    content = function(file) {
      pdf(file)
      cat(paste("Concentration:", round(calculate_concentration(), 2), "ng/μL"), file = file)
      dev.off()
    }
  )
  
  # Sedimentation Coefficient Calculator Logic
  calculate_sedimentation_coefficient <- reactive({
    req(input$calculate_sedimentation)
    sed_velocity <- input$sed_velocity
    ang_velocity <- input$ang_velocity
    rad_distance <- input$rad_distance
    
    sedimentation_coefficient <- sed_velocity / (ang_velocity^2 * rad_distance)
    return(sedimentation_coefficient)
  })
  
  output$sedimentation_result <- renderText({
    sedimentation_coef <- calculate_sedimentation_coefficient()
    paste("Sedimentation Coefficient:", round(sedimentation_coef, 5), "S")
  })
  
  output$sedimentation_plot <- renderPlot({
    sedimentation_coef <- calculate_sedimentation_coefficient()
    data <- data.frame(
      Type = c("Sedimentation Coefficient"),
      Value = c(sedimentation_coef)
    )
    
    ggplot(data, aes(x = Type, y = Value, fill = Type)) +
      geom_bar(stat = "identity", width = 0.5) +
      labs(title = "Sedimentation Coefficient Visualization", y = "Coefficient (S)", x = "") +
      theme_minimal() +
      scale_fill_manual(values = c("Sedimentation Coefficient" = "#007bff")) +
      geom_text(aes(label = round(Value, 5)), vjust = -0.5)
  })
  
  output$print_sedimentation_result <- downloadHandler(
    filename = function() { paste("Sedimentation_Result", Sys.Date(), ".pdf", sep = "") },
    content = function(file) {
      pdf(file)
      cat(paste("Sedimentation Coefficient:", round(calculate_sedimentation_coefficient(), 5), "S"), file = file)
      dev.off()
    }
  )
}

# Run the application 
shinyApp(ui = ui, server = server, options= list(height = 1080))


