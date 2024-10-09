# Load required libraries
library(shiny)
library(shinythemes)
library(TCGAbiolinks)
library(pathview)
library(biomaRt)
library(ReactomePA)
library(visNetwork)
library(clusterProfiler)
library(org.Hs.eg.db)
library(ggplot2)
library(plotly)
library(DT)
library(igraph)

# Dummy data for species annotation (can be replaced with actual data source)
species_data <- data.frame(
  id = 1:4,
  scientific_name = c("Homo sapiens", "Mus musculus", "Danio rerio", "Saccharomyces cerevisiae"),
  common_name = c("Human", "Mouse", "Zebrafish", "Baker's yeast"),
  ncbi_taxonomy_id = c("9606", "10090", "7955", "4932"),
  stringsAsFactors = FALSE
)

# Define UI for the Shiny app
ui <- fluidPage(
  
  theme = shinytheme("flatly"),  # Applying a flatly theme for a clean, professional look
  
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
      selectInput("speciesSelect", "Select Annotated Species:",
                  choices = species_data$scientific_name,
                  selected = "Homo sapiens"),
      
      selectInput("enrichmentType", "Select Enrichment Type:", 
                  choices = c("Gene Ontology", "Biological Process", "Cellular Components", 
                              "Molecular Functions", "Pathways"),
                  selected = "Gene Ontology"),
      hr(),
      selectInput("geneSet", "Choose a Gene Set", choices = c("Example Gene List", "Another Gene List")),
      numericInput("fdrCutoff", "FDR Cutoff", value = 0.05, min = 0, max = 1, step = 0.01),
      numericInput("nPathways", "Pathways to Show", value = 20, min = 1, max = 100, step = 1),
      numericInput("minPathSize", "Pathway Size: Min", value = 2, min = 1, max = 5000),
      numericInput("maxPathSize", "Pathway Size: Max", value = 5000, min = 1, max = 5000),
      checkboxInput("removeRedundancy", "Remove redundancy", value = TRUE),
      checkboxInput("abbreviatePathways", "Abbreviate pathways", value = TRUE),
      checkboxInput("useDBforCounts", "Use pathway DB for gene counts", value = FALSE),
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
                 plotOutput("plotResults")),
        
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
server <- function(input, output, session) {
  
  # Predefined gene sets
  geneSets <- list(
    "Example Gene List" = c("TP53", "BRCA1", "EGFR", "MYC", "KRAS", "PTEN"),
    "Another Gene List" = c("CDK2", "CCND1", "GATA3", "CDH1", "MTOR", "RB1")
  )
  
  # Reactive function to retrieve the selected gene list
  geneList <- reactive({
    req(input$geneSet)
    geneSets[[input$geneSet]]
  })
  
  # Perform GO and Pathway enrichment analysis with default cutoffs and user inputs
  enrichmentResults <- eventReactive(input$runAnalysis, {
    req(geneList())
    
    # Convert gene symbols to Entrez IDs
    mart <- useMart("ensembl", dataset = "hsapiens_gene_ensembl")
    gene_info <- getBM(attributes = c('hgnc_symbol', 'entrezgene_id'), 
                       filters = 'hgnc_symbol', 
                       values = geneList(), 
                       mart = mart)
    
    geneIDs <- gene_info$entrezgene_id
    
    # Perform enrichment analysis
    enrichResult <- enrichGO(
      gene = geneIDs,
      OrgDb = org.Hs.eg.db,
      ont = "BP",  # Perform enrichment based on Biological Process (BP)
      pAdjustMethod = "BH",
      pvalueCutoff = input$fdrCutoff,
      qvalueCutoff = input$fdrCutoff,
      readable = TRUE
    )
    
    return(enrichResult)
  })
  
  # Output enrichment plot in the Results tab
  output$plotResults <- renderPlot({
    req(enrichmentResults())
    barplot(enrichmentResults(), showCategory = input$nPathways)
  })
  
  # Gene characteristics table output
  output$geneInfo <- renderDT({
    req(geneList())
    gene_info <- data.frame(Gene = geneList(), Symbol = geneList(), stringsAsFactors = FALSE)
    datatable(gene_info, options = list(pageLength = 5))
  })
  
  # Protein interaction network output
  output$proteinNetwork <- renderVisNetwork({
    req(geneList())
    
    # Placeholder network (replace with actual protein-protein interaction network data)
    nodes <- data.frame(id = 1:6, label = geneList(), stringsAsFactors = FALSE)
    edges <- data.frame(from = c(1,2,3,4,5), to = c(2,3,4,5,6))
    
    visNetwork(nodes, edges) %>%
      visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE)
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
