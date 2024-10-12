# Load required libraries
library(shiny)
library(shinythemes)
library(DT)
library(ggplot2)
library(visNetwork)
library(TCGAbiolinks)

# Dummy data for species annotation
species_data <- data.frame(
  scientific_name = c("Homo sapiens", "Mus musculus"),
  common_name = c("Human", "Mouse"),
  ncbi_taxonomy_id = c("9606", "10090"),
  stringsAsFactors = FALSE
)

# Define UI for the Shiny app
ui <- fluidPage(
  
  theme = shinytheme("flatly"), 
  
  # Add custom CSS to style the title panel with a dark blue background and white text
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
    "))
  ),
  
  # Header with title panel that stands alone  
  div(class = "title-panel", "GO 1.0 - Gene Enrichment Analysis"),
 
  # Sidebar Layout with a fluid row 
  sidebarLayout(
    sidebarPanel(
      fileInput("geneListFile", "Upload Gene List (CSV)", accept = ".csv"),
      checkboxInput("useDummyGenes", "Use Dummy Genes as Background", value = TRUE),
      checkboxInput("useDBGeneCount", "Use pathway DB for gene counts", value = FALSE),
      numericInput("fdrCutoff", "FDR Cutoff", value = 0.05, min = 0, max = 1, step = 0.01),
      selectInput("sortMethod", "Sort by:", choices = c("FDR", "Fold Enrichment", "Average Rank")),
      selectInput("speciesSelect", "Select Annotated Species:",
                  choices = species_data$scientific_name,
                  selected = "Homo sapiens"),
      selectInput("enrichmentType", "Select Enrichment Type:", 
                  choices = c("Gene Ontology", "Biological Process", "Cellular Components", 
                              "Molecular Functions", "Pathways"),
                  selected = "Gene Ontology"),
      hr(),
      selectInput("geneSet", "Choose a Gene Set", choices = c("Dummy Gene List")),
      numericInput("nPathways", "Pathways to Show", value = 20, min = 1, max = 100, step = 1),
      numericInput("minPathSize", "Pathway Size: Min", value = 2, min = 1, max = 5000),
      numericInput("maxPathSize", "Pathway Size: Max", value = 5000, min = 1, max = 5000),
      checkboxInput("removeRedundancy", "Remove redundancy", value = TRUE),
      checkboxInput("abbreviatePathways", "Abbreviate pathways", value = TRUE),
      checkboxInput("showPathwayIDs", "Show pathway IDs", value = FALSE),
      actionButton("runAnalysis", "Run Enrichment Analysis"),
      hr(),
      h5("Select and filter gene sets for enrichment analysis.")
    ),
    
    mainPanel(
      # Create a tabsetPanel that holds all the panels together
      tabsetPanel(
        
        # Home tab
        tabPanel("Home",
                 fluidRow(
                   column(12,
                          h1("Welcome to GO 1.0", style = "text-align:center; margin-top:20px;"),
                          hr(),
                          p("Welcome to GO 1.0, a user-friendly web-based platform for gene-set enrichment analysis. It features an easy-to-use interface, which offers customizable visualization options, and allows to print result in either of the below formats PDF and PNG.", 
                            style = "font-size:16px; text-align:center;"),
                          p("This platform provides valuable resources, including guide on how to navigate through the website. This was developed as partial fulfillment of the HackBio internship program, GO 1.0 was patterned after ShinyGO 8.0 and this aims to simplify cancer gene-set enrichment analysis.", 
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
                          p("The R Shiny app dashboard project was initiated as part of a HackBio internship program, 
                             where participants were tasked with developing R Shiny dashboards for bioinformatics applications 
                             on Functional Enrichment analysis based on cancer genome atlas databases.", 
                            style = "font-size:16px;"),
                          h3("Aims"),
                          p("The goal of this project is to create a user-friendly website that simplifies gene set enrichment 
                             analysis while offering an intuitive interface for researchers. The GO 1.0 website will facilitate 
                             efficient data analysis and interpretation, thus contributing to the advancement of scientific research 
                             in genomics and related fields.", 
                            style = "font-size:16px;"),
                          h3("Navigating the GO 1.0 website by Goal-getters team"),
                          p("GO 1.0 is an interactive web-based application for gene-set enrichment analysis and visualization patterned after ShinyGO 8.0.",
                            style = "font-size:16px;"),
                          h3("Below is a concise guide:"),
                          p("Users can upload a gene list or manually input gene symbols, IDs, or aliases. Supported species are selectable from a drop-down menu.
                            Adjust enrichment analysis parameters, such as the significance level (FDR), the minimum/maximum pathway size, and the databases to search against (e.g., GO terms, KEGG pathways).
                            Once genes are submitted, GO 1.0 automatically performs enrichment analysis, presenting the results as tables and plots.
                            View enriched Gene Ontology (GO) terms, pathways, biological processes, molecular functions, and cellular components.
                            Results are shown in bar plots and scatter plots, enabling users to explore relationships between genes and pathways.
                            Users can download enrichment results and visualizations in various formats (e.g.PDF, PNG) for further analysis.
                            The GO 1.0 app is easy to navigate, with visualization and options to help users interpret and explore functional enrichment data.", 
                            style = "font-size:16px;")
                   )
                 )),
        
        # Gene Characteristics tab
        tabPanel("Gene Characteristics", DTOutput("geneInfo")),
        
        # Protein Interactions tab
        tabPanel("Protein Interactions", visNetworkOutput("proteinNetwork")),
        
        # Results tab
        tabPanel("Results", 
                 h3("Enrichment Results", style = "margin-top:20px;"),
                 DTOutput("enrichmentTable"),
                 plotOutput("goPlot"),
                 # Download buttons for PDF and PNG
                 downloadButton("downloadPDF", "Download PDF"),
                 downloadButton("downloadPNG", "Download PNG")
        ),
        
        # Contact tab
        tabPanel("Contact",
                 fluidRow(
                   column(12,
                          h2("Contact Us", style = "margin-top:20px; text-align:center;"),
                          hr(),
                          p("For any inquiries or feedback regarding GO, please reach out to us:", 
                            style = "font-size:16px;"),
                          tags$ul(
                            tags$li(a("Tomilayo Oluwaseun Fadairo", href = "mailto:Oluwaseuntomilayo9@gmail.com")),
                            tags$li(a("Akinjide Samuel Anifowose", href = "mailto:Anifowosesamuel54@gmail.com")),
                            tags$li(a("Opeoluwa Shodipe", href = "mailto:Opeoluwashodipe94@gmail.com")),
                            tags$li(a("Ndubueze Ngozika Abigail", href = "mailto:ndubungoabi2002@gmail.com")),
                            tags$li(a("Nwankwo Peace Nneka", href = "mailto:nnekapeace85@gmail.com"))
                          )
                   )
                 ))
      )
    )
  ),
  
  # Footer
  div(class = "footer", "© 2024 Goal-getters. All rights reserved.")
)

# Define server logic for the Shiny app
server <- function(input, output) {
  
  # Use `TCGAbiolinks` reactively to save resources
  tcgaData <- eventReactive(input$runTCGAQuery, {
    GDCquery(project = "TCGA-BRCA", 
             data.category = "Transcriptome Profiling", 
             data.type = "Gene Expression Quantification", 
             workflow.type = "HTSeq - Counts")
  })
  
  observeEvent(tcgaData(), {
    GDCdownload(tcgaData())
    data <- GDCprepare(tcgaData())
  })
  
  # Dummy gene set for testing
  geneSets <- list("Sample Gene List" = c("TP53", "BRCA1", "EGFR"))
  
  # Reactive function to retrieve gene list from uploaded file or predefined set
  geneList <- reactive({
    if (is.null(input$geneListFile)) {
      return(geneSets[["Sample Gene List"]])
    } else {
      return(read.csv(input$geneListFile$datapath, stringsAsFactors = FALSE)$GeneSymbol)
    }
  })
  
  # Populate Gene Characteristics table
  output$geneInfo <- renderDT({
    gene_data <- data.frame(
      Gene = geneList(),
      Description = c("Tumor suppressor", "DNA repair", "Receptor tyrosine kinase"),
      Chromosome = c("17p13.1", "17q21.31", "7p11.2"),
      stringsAsFactors = FALSE
    )
    datatable(gene_data, options = list(pageLength = 5))
  })
  
  # Create Protein Interaction Network
  output$proteinNetwork <- renderVisNetwork({
    nodes <- data.frame(id = geneList(), label = geneList(), group = "Gene")
    edges <- data.frame(
      from = sample(geneList(), 5, replace = TRUE),
      to = sample(geneList(), 5, replace = TRUE)
    )
    visNetwork(nodes, edges) %>%
      visNodes(size = 10) %>%
      visEdges(arrows = "to") %>%
      visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE)
  })
  
  # Perform enrichment analysis when the button is pressed
  enrichmentData <- reactiveVal() # Store enrichment data reactively
  observeEvent(input$runAnalysis, {
    
    # Create dummy pathways data frame for demonstration
    pathways <- data.frame(
      Pathway = paste("Pathway", 1:5),
      Overlap = sample(1:5, 5, replace = TRUE),
      TotalGenes = sample(10:20, 5, replace = TRUE)
    )
    
    # Perform enrichment calculation
    pathways$PValue <- phyper(pathways$Overlap - 1, pathways$TotalGenes, 100 - pathways$TotalGenes, length(geneList()), lower.tail = FALSE)
    pathways$FDR <- p.adjust(pathways$PValue, method = "BH")
    pathways <- pathways[pathways$FDR < input$fdrCutoff, ]
    
    # Save the data for downloading
    enrichmentData(pathways)
    
    # Output results table
    output$enrichmentTable <- renderDT({
      datatable(pathways, options = list(pageLength = 5))
    })
    
    # Output plot of top GO terms
    output$goPlot <- renderPlot({
      ggplot(pathways, aes(x = reorder(Pathway, -FDR), y = FDR)) +
        geom_bar(stat = "identity") +
        coord_flip() +
        labs(x = "Pathway", y = "FDR", title = "Enrichment Analysis Results") +
        theme_minimal()
    })
  })
  
  # Download handler for the enrichment table as PDF
  output$downloadPDF <- downloadHandler(
    filename = function() { paste("enrichment_results", Sys.Date(), ".pdf", sep = "") },
    content = function(file) {
      write.csv(enrichmentData(), file, row.names = FALSE)
    }
  )
  
  # Download handler for the plot as PNG
  output$downloadPNG <- downloadHandler(
    filename = function() { paste("enrichment_plot", Sys.Date(), ".png", sep = "") },
    content = function(file) {
      # Define server logic for the Shiny app
server <- function(input, output) {
  
  # Use `TCGAbiolinks` reactively to save resources
  tcgaData <- eventReactive(input$runTCGAQuery, {
    GDCquery(project = "TCGA-BRCA", 
             data.category = "Transcriptome Profiling", 
             data.type = "Gene Expression Quantification", 
             workflow.type = "HTSeq - Counts")
  })
  
  observeEvent(tcgaData(), {
    GDCdownload(tcgaData())
    data <- GDCprepare(tcgaData())
  })
  
  # Dummy gene set for testing
  geneSets <- list("Sample Gene List" = c("TP53", "BRCA1", "EGFR"))
  
  # Reactive function to retrieve gene list from uploaded file or predefined set
  geneList <- reactive({
    if (is.null(input$geneListFile)) {
      return(geneSets[["Sample Gene List"]])
    } else {
      return(read.csv(input$geneListFile$datapath, stringsAsFactors = FALSE)$GeneSymbol)
    }
  })
  
  # Populate Gene Characteristics table
  output$geneInfo <- renderDT({
    gene_data <- data.frame(
      Gene = geneList(),
      Description = c("Tumor suppressor", "DNA repair", "Receptor tyrosine kinase"),
      Chromosome = c("17p13.1", "17q21.31", "7p11.2"),
      stringsAsFactors = FALSE
    )
    datatable(gene_data, options = list(pageLength = 5))
  })
  
  # Create Protein Interaction Network
  output$proteinNetwork <- renderVisNetwork({
    nodes <- data.frame(id = geneList(), label = geneList(), group = "Gene")
    edges <- data.frame(
      from = sample(geneList(), 5, replace = TRUE),
      to = sample(geneList(), 5, replace = TRUE)
    )
    visNetwork(nodes, edges) %>%
      visNodes(size = 10) %>%
      visEdges(arrows = "to") %>%
      visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE)
  })
  
  # Perform enrichment analysis when the button is pressed
  enrichmentData <- reactiveVal() # Store enrichment data reactively
  observeEvent(input$runAnalysis, {
    
    # Create dummy pathways data frame for demonstration
    pathways <- data.frame(
      Pathway = paste("Pathway", 1:5),
      Overlap = sample(1:5, 5, replace = TRUE),
      TotalGenes = sample(10:20, 5, replace = TRUE)
    )
    
    # Perform enrichment calculation
    pathways$PValue <- phyper(pathways$Overlap - 1, pathways$TotalGenes, 100 - pathways$TotalGenes, length(geneList()), lower.tail = FALSE)
    pathways$FDR <- p.adjust(pathways$PValue, method = "BH")
    pathways <- pathways[pathways$FDR < input$fdrCutoff, ]
    
    # Save the data for downloading
    enrichmentData(pathways)
    
    # Output results table
    output$enrichmentTable <- renderDT({
      datatable(pathways, options = list(pageLength = 5))
    })
    
    # Output plot of top GO terms
    output$goPlot <- renderPlot({
      ggplot(pathways, aes(x = reorder(Pathway, -FDR), y = FDR)) +
        geom_bar(stat = "identity") +
        coord_flip() +
        labs(x = "Pathway", y = "FDR", title = "Enrichment Analysis Results") +
        theme_minimal()
    })
  })
  
  # Download handler for the enrichment table as CSV
  output$downloadCSV <- downloadHandler(
    filename = function() { paste("enrichment_results", Sys.Date(), ".csv", sep = "") },
    content = function(file) {
      write.csv(enrichmentData(), file, row.names = FALSE)
    }
  )
  
  # Download handler for the plot as PNG
  output$downloadPNG <- downloadHandler(
    filename = function() { paste("enrichment_plot", Sys.Date(), ".png", sep = "") },
    content = function(file) {
      # Save the plot as a PNG file
      ggsave(file, plot = last_plot(), device = "png", width = 8, height = 6)
    }
  )
}

      # Save the plot as a PNG file
      ggsave(file, plot = last_plot(), device = "png", width = 8, height = 6)
    }
  )
}



# Run the application 
shinyApp(ui = ui, server = server)
