**App Functionality and Development:**

The R Shiny app developed for functional enrichment analysis utilizes two core functions from the TCGAbiolinks package: TCGAanalyze\_EAcomplete () and TCGA\_EAbarplot (). The app allows users to input gene lists, conduct enrichment analyses, and visualize results in an interactive and user-friendly manner. Key components of the app's functionality are:

- **Input**: Users can upload or manually input gene lists to perform the analysis.
- **Analysis**: The app uses TCGAanalyze\_EAcomplete () to perform comprehensive enrichment analysis, identifying significant pathways and processes associated with the genes.
- **Visualization**: Results are visualized using TCGA\_EAbarplot (), which generates bar plots of enriched pathways, categorized under Gene Ontology (GO), Biological Processes, Cellular Components, and Molecular Functions.

Challenges encountered during development included ensuring the smooth integration of these functions into a Shiny interface, package installation and troubleshooting performance issues when analyzing these large datasets. 
