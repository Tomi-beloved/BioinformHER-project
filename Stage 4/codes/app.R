# Load required libraries
library(shiny)
library(shinythemes)
library(DT)  # For interactive data tables
library(TCGAbiolinks)

# Define UI for the app
ui <- fluidPage(
  theme = shinytheme("flatly"),
  
  # Custom CSS for title panel and footer
  tags$head(
    tags$style(HTML("
      .title-panel {
        background-color: #003366;  /* Dark blue color */
        padding: 20px;
        color: white;
        text-align: center;
        font-size: 32px;
        font-weight: bold;
      }
      .footer {
        text-align: center;
        padding: 10px;
        font-size: 14px;
        color: #555;  /* Light gray color */
        position: fixed;
        bottom: 0;
        width: 100%;
        background-color: #f9f9f9;  /* Light background for the footer */
        border-top: 1px solid #ddd;  /* Light border at the top of the footer */
      }
    "))
  ),
  
  # Header with a custom title panel
  div(class = "title-panel", "GO 1.0 - Gene Enrichment Analysis"),
  
  sidebarLayout(
    sidebarPanel(
      textAreaInput("gene_list", "Paste Gene List (One per line):", rows = 8, placeholder = "Paste your gene symbols or IDs here"),
      h4("Select Enrichment Types:"),  # Section header
      checkboxGroupInput("enrichmentTypes", "Enrichment Types:",
                         choices = list("Biological Process" = "BP", 
                                        "Cellular Component" = "CC", 
                                        "Molecular Function" = "MF", 
                                        "Pathway" = "Pathway"),
                         selected = "BP"),  # Default selected option
      actionButton("analyze", "Run Enrichment Analysis"),
      hr()
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Home",
                 fluidRow(
                   column(12,
                          h1("Welcome to GO 1.0", style = "text-align:center; margin-top:20px;"),
                          hr(),
                          p("Welcome to GO 1.0, a user-friendly web-based platform for gene-set enrichment analysis. It features an easy-to-use interface, which offers customizable visualization options, and allows printing results in formats like PDF or PNG.", 
                            style = "font-size:16px; text-align:center;"),
                          p("This platform provides valuable resources, including a guide on how to navigate through the website. Developed as part of the HackBio internship program, it is patterned after ShinyGO 8.0, aiming to simplify cancer gene-set enrichment analysis.", 
                            style = "font-size:16px; text-align:center;"),
                          p("Use the sidebar options to begin your analysis.", 
                            style = "font-size:16px; text-align:center;")
                   )
                 )),
        
        # About tab with updated content
        tabPanel("About",
                 fluidRow(
                   column(12,
                          h2("About", style = "margin-top:20px; text-align:center;"),
                          hr(),
                          h3("Initiation"),
                          p("This R Shiny app dashboard project was initiated as part of the HackBio internship program, where participants were tasked with developing R Shiny dashboards for bioinformatics applications on functional enrichment analysis using cancer genome atlas data.", 
                            style = "font-size:16px;"),
                          h3("Aims"),
                          p("The goal of this project is to create a user-friendly platform that simplifies gene set enrichment analysis and offers an intuitive interface for researchers. GO 1.0 facilitates efficient data analysis and interpretation, contributing to scientific research advancement in genomics and related fields.", 
                            style = "font-size:16px;"),
                          h3("Navigating the GO 1.0 website"),
                          p("GO 1.0 is an interactive web-based application for gene-set enrichment analysis and visualization, patterned after ShinyGO 8.0.", style = "font-size:16px;"),
                          h3("Below is a concise guide:"),
                          p("Users can upload a gene list or manually input gene symbols, IDs, or aliases. Supported species can be selected from a drop-down menu. Users can adjust enrichment analysis parameters such as FDR, pathway size, and select databases (e.g., GO terms, KEGG pathways). Results are displayed in tables and plots and can be downloaded in PDF or PNG formats.", 
                            style = "font-size:16px;")
                   )
                 )),
        
        # Results tab
        tabPanel("Results",
                 h4("Enrichment Analysis Results"),
                 DTOutput("resultsTable"),  # Use DT for better tables
                 plotOutput("enrichmentPlot")
        ),
        
        # Contact tab
        tabPanel("Contact",
                 fluidRow(
                   column(12,
                          h2("Contact Us", style = "margin-top:20px; text-align:center;"),
                          hr(),
                          p("For inquiries or feedback regarding GO 1.0, please contact us:", 
                            style = "font-size:16px;"),
                          tags$ul(
                            tags$li(a("Tomilayo Oluwaseun Fadairo", href = "mailto:Oluwaseuntomilayo9@gmail.com")),
                            tags$li(a("Akinjide Samuel Anifowose", href = "mailto:Anifowosesamuel54@gmail.com")),
                            tags$li(a("Opeoluwa Shodipe", href = "mailto:Opeoluwashodipe94@gmail.com")),
                            tags$li(a("Ndubueze Ngozika Abigail", href = "mailto:ndubungoabi2002@gmail.com")),
                            tags$li(a("Nwankwo Peace Nneka", href = "mailto:nnekapeace85@gmail.com"))
                          ),
                          p("We appreciate your feedback and look forward to hearing from you!", style = "font-size:16px;"),
                          hr()
                   )
                 ))
      )
    )
  ),
  
  # Footer
  div(class = "footer", "© 2024 Goal-getters. All rights reserved.")
)

# Define server logic
server <- function(input, output) {
  
  observeEvent(input$analyze, {
    req(input$gene_list)  # Ensure a gene list is provided
    
    # Split pasted gene list into a vector
    geneData <- strsplit(input$gene_list, "\n")[[1]]
    geneData <- trimws(geneData)  # Trim any extra spaces
    
    # Prepare for enrichment results storage
    EA_result <- list()
    
    # Run analyses based on selected types
    if ("BP" %in% input$enrichmentTypes) {
      EA_result$ResBP <- TCGAanalyze_EAcomplete(
        TFname = "DEA genes", 
        RegulonList = geneData  
      )$ResBP
    }
    
    if ("CC" %in% input$enrichmentTypes) {
      EA_result$ResCC <- TCGAanalyze_EAcomplete(
        TFname = "DEA genes", 
        RegulonList = geneData
      )$ResCC
    }
    
    if ("MF" %in% input$enrichmentTypes) {
      EA_result$ResMF <- TCGAanalyze_EAcomplete(
        TFname = "DEA genes", 
        RegulonList = geneData
      )$ResMF
    }
    
    if ("Pathway" %in% input$enrichmentTypes) {
      EA_result$ResPat <- TCGAanalyze_EAcomplete(
        TFname = "DEA genes", 
        RegulonList = geneData
      )$ResPat
    }
    
    # Display results in a table
    output$resultsTable <- renderDT({
      resultsToDisplay <- list()
      
      if ("BP" %in% input$enrichmentTypes && !is.null(EA_result$ResBP)) {
        resultsToDisplay$BP <- as.data.frame(EA_result$ResBP)
      }
      
      if ("CC" %in% input$enrichmentTypes && !is.null(EA_result$ResCC)) {
        resultsToDisplay$CC <- as.data.frame(EA_result$ResCC)
      }
      
      if ("MF" %in% input$enrichmentTypes && !is.null(EA_result$ResMF)) {
        resultsToDisplay$MF <- as.data.frame(EA_result$ResMF)
      }
      
      if ("Pathway" %in% input$enrichmentTypes && !is.null(EA_result$ResPat)) {
        resultsToDisplay$Pathway <- as.data.frame(EA_result$ResPat)
      }
      
      # Combine results into a single data frame, fill missing values with NA
      combinedResults <- Reduce(function(x, y) merge(x, y, all = TRUE), resultsToDisplay)
      
      # Render the combined results table using DT
      datatable(combinedResults, options = list(pageLength = 10, scrollX = TRUE))
    })
    
    # Plotting the enrichment analysis results (simplified example)
    output$enrichmentPlot <- renderPlot({
      req(EA_result)
      
      # Check if there are valid results for the barplot
      barplot_data <- as.data.frame(table(unlist(EA_result)))
      
      # Only plot if there is valid data
      if (nrow(barplot_data) > 0 && all(is.finite(barplot_data$Freq))) {
        barplot(
          height = barplot_data$Freq,
          names.arg = barplot_data$Var1,
          las = 2,  # Make the labels vertical
          col = "blue",
          main = "Enrichment Analysis Results",
          xlab = "Frequency",
          ylab = "Terms"
        )
      } else {
        # If there's no valid data, show a message
        plot.new()
        text(0.5, 0.5, "No valid enrichment data to display.", cex = 1.5)
      }
    })
  })
}


# Run the application
shinyApp(ui = ui, server = server)
