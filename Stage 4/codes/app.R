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
  
  # Header with a title panel
  navbarPage("ShinyGO 1.0 - Gene Enrichment Analysis",
             
             # Home tab
             tabPanel("Home",
                      fluidRow(
                        column(12,
                               h1("Welcome to ShinyGO 1.0", style = "text-align:center; margin-top:20px;"),
                               hr(),
                               p("Welcome to GO 1.0, a user-friendly web-based platform for gene-set enrichment analysis. It features an easy-to-use interface, which offers customizable visualization options, and allows to print result in either of the below formats CVS, PDF and PNG.", 
                                 style = "font-size:16px; text-align:center;"),
                               p("This platform provides valuable resources, including guide on how to navigate through the website. This was developed as partial fulfillment of the HackBio internship program, GO 1.0 was patterned after ShinyGO 8.0 and this aims to simplify cancer gene-set enrichment analysis.", 
                                 style = "font-size:16px; text-align:center;"),
                               p("Use the sidebar options to begin your analysis.", 
                                 style = "font-size:16px; text-align:center;")
                        )
                      )),
             
             # About tab with updated content
             tabPanel("About ShinyGo",
                      fluidRow(
                        column(12,
                               h2("About ShinyGO", style = "margin-top:20px; text-align:center;"),
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
                                 style = "font-size:16px;")
                        )
                      )),
             
             # Contact tab
             tabPanel("Contact",
                      fluidRow(
                        column(12,
                               h2("Contact Us", style = "margin-top:20px; text-align:center;"),
                               hr(),
                               p("For any inquiries or feedback regarding ShinyGO, please reach out to us:", 
                                 style = "font-size:16px;"),
                               tags$ul(
                                 tags$li(a("Tomilayo Oluwaseun Fadairo", href = "mailto:Oluwaseuntomilayo9@gmail.com")),
                                 tags$li(a("Akinjide Samuel Anifowose", href = "mailto:Anifowosesamuel54@gmail.com")),
                                 tags$li(a("Opeoluwa Shodipe", href = "mailto:Opeoluwashodipe94@gmail.com")),
                                 tags$li(a("Ndubueze Ngozika Abigail", href = "mailto:ndubungoabi2002@gmail.com")),
                                 tags$li(a("Nwankwo Peace Nneka", href = "mailto:nnekapeace85@gmail.com"))
                               )
                        )
                      )),
             
             # Gene Characteristics tab
             tabPanel("Gene Characteristics", DTOutput("geneInfo")),
             
             # Protein Interactions tab
             tabPanel("Protein Interactions", visNetworkOutput("proteinNetwork"))
  ),
  
  # Sidebar Layout
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
    
    # Main content area
    mainPanel(
      tabsetPanel(
        tabPanel("Results", 
                 h3("Enrichment Results", style = "margin-top:20px;"),
                 plotOutput("plotResults"))
      )
    )
  )
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
    
    # Check if gene_info is empty
    if (nrow(gene_info) == 0) {
      showNotification("No genes found for the selected gene set.", type = "error")
      return(NULL)
    }
    
    entrez_ids <- gene_info$entrezgene_id
    
    # Retrieve TCGA data with sample type filtering and limit the number of samples
    query <- GDCquery(project = "TCGA-BRCA",  
                      data.category = "Transcriptome Profiling",
                      sample.type = "Primary Tumor",  
                      experimental.strategy = "RNA-Seq",  
                      access = "open",
                      workflow.type = "STAR - Counts")  
    
    GDCdownload(query)
    data <- GDCprepare(query)
    
    # Limit the data to a smaller subset for testing
    set.seed(42)
    sample_indices <- sample(nrow(data), min(5, nrow(data)))  
    limited_data <- data[sample_indices, ]
    
    limited_gene_indices <- sample(1:ncol(limited_data), min(50, ncol(limited_data)))  
    limited_data <- limited_data[, limited_gene_indices]
    
    pvalCutoff <- input$fdrCutoff
    minSize <- input$minPathSize
    maxSize <- input$maxPathSize
    
    # Perform functional enrichment analysis using TCGAanalyze_EAcomplete and TCGA_EAbarplot
    results <- TCGAanalyze_EAcomplete(data = limited_data, gene.list = entrez_ids, pvalueCutoff = pvalCutoff)
    
    list(results = results, gene_info = gene_info)
  })
  
  # Render gene characteristics table
  output$geneInfo <- renderDT({
    req(enrichmentResults())
    gene_info <- enrichmentResults()$gene_info
    gene_df <- data.frame(GeneSymbol = geneList(), EntrezID = gene_info$entrezgene_id, stringsAsFactors = FALSE)
    datatable(gene_df)
  })
  
  # Render protein interactions using visNetwork
  output$proteinNetwork <- renderVisNetwork({
    edges <- data.frame(from = c("TP53", "BRCA1", "EGFR"), to = c("MYC", "PTEN", "KRAS"), value = c(1, 1, 1))
    nodes <- data.frame(id = c("TP53", "BRCA1", "EGFR", "MYC", "PTEN", "KRAS"),
                        label = c("TP53", "BRCA1", "EGFR", "MYC", "PTEN", "KRAS"),
                        group = c(1, 1, 1, 2, 2, 2),
                        value = c(10, 20, 30, 40, 50, 60))
    
    visNetwork(nodes, edges) %>%
      visEdges(arrows = 'to') %>%
      visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE)
  })
  
  # Render enrichment results plot
  output$plotResults <- renderPlot({
    req(enrichmentResults())
    results <- enrichmentResults()$results
    
    # Barplot for the enriched pathways
    TCGA_EAbarplot(results, showCategory = input$nPathways, fontSize = 8, color = "p.adjust")
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
