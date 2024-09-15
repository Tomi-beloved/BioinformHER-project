**THE DOCUMENTATION OF FORMULAS AND LOGIC**

The reasoning for each of the four calculators in **R Shiny** and the underlying mathematical formulas are explained below. The processes for configuring the reactive calculation, the underlying mathematical ideas, and the reasoning behind each calculator's implementation within the Shiny framework are all covered in the explanation.

 

**1. Stock Solution Dilution Calculation**

**Mathematical Formula** The following formula controls the dilution of the stock solution: C1 times V1 equals C2 times V2 Where: -&#x20;

C1 = Concentration of stock (known)

V1 = Required (unknown) volume of stock solution

C2 = Targeted ultimate concentration = Final volume - V2.

The unknown volume can be solved by rearranging this as follows: 、V1 = \dfrac{C2 \×V2}{C1} R Shiny Implementation

**Inputs**: - C1: Stock concentration (numeric input). C2: The desired amount (a numeric input).V2: The final volume, entered as a number.****

**Reactive Calculation: - **Create a reactive function that applies the formula to compute V\_1.{{{r stock\_volume \\- reactive({     C1 \\- input$stock\_concentration    C2 \\- input$final\_concentration    V2 \\- input$final\_volume    V1 \\- (C2 ×V2) / C1     return(V1) })****

**Text**: Show the stock solution's computed volume. Scene: Make a bar graph that shows the ratio of the diluent (V2-V1) to the stock solution (V1).{{{r output$stock\_result \\- renderText({ paste("You need", round(stock\_volume(), 2), "mL of stock solution.")  })renderPlot({ stock \\- stock\_volume() , dilutent \\- input) - output$stock\_plotBarplot(c(stock, diluent), names.arg = c("Stock Solution", "Diluent"), $final\_volume - stock; col = c("blue", "gray"), ylab = Volume (mL))

 

**2.  Serial Dilution Calculation**

 **Mathematical Formula** The following formula defines serial dilutions: Cn = \dfrac{C\_0}{DF^n} Where: The initial concentration, C0. - DF = Dilution factor (the amount that the solution is diluted in each phase) - πn = The step of dilution (from 0). Following each dilution stage, the concentration is determined using this formula. R Shiny Implementation **Sources**: Initial concentration (numeric input) is C0. - DF: Dilution factor (input of numbers). n: The number of dilution stages (supplied as a numeric).

**Reactive Calculation: - **Create a data frame of concentrations for every dilution step by defining a reactive function.{{{r serial\_dilution \\- reactive({     C0 \\- input$initial\_concentration     DF \\- input$dilution\_fact                                        ****

**Results: - Table: **Show the dilution series as a tabular representation.-

**Plot: **To see the dilution, plot the concentration vs. dilution step.{{{r output$dilution\_table \\- renderTable({ serial\_dilution() \\})plot(serial\_dilution()$Step, serial\_dilution()) is output$dilution\_plot <- renderPlot({ $Concentration, type = "b", col = "blue"), xlab = "Dilution Step", ylab = "Concentration", \\){\~ ---

**3. DNA/RNA Concentration Calculation**

**Mathematical Formula **Utilizing conversion factors unique to each nucleic acid, the absorbance at 260 nm is used to compute the concentration of DNA or RNA: \text{Absorbance} \× \text{Conversion Factor} = \text{Concentration} - 50 ng/μL is the DNA conversion factor per A260. - 40 ng/μL is the RNA conversion factor according to A260 R Shiny Im'plementation 1. Inputs: - Absorbance: Numerical input for absorbance at 260 nm.-****

**Type:** Selection input for RNA and DNA selection.&#x20;

**Reactive Calculation:** - Based on the selected type, define a reactive function that calculates the concentration.{}{r concentration {-reactive({    absorbance {-input$absorbance    conversion\_factor {-if (input$type == "DNA") 50 else 40     conc {-absorbance  conversion\_factor    return(conc) })

**Results**. Text: **Present the determined concentration.

**Plot**: **Make a bar graph to show the determined concentration.{{{r output$concentration\_result \\- renderText({    paste("Concentration:", round(concentration(), 2), "ng/μL")  })output$concentration\_plot \\- renderPlot({ barplot(concentration(), names.arg = input$type, col = "green", ylab = "Concentration (ng/μL)") }){\~ ---

 

**4. Sedimentation Coefficient Calculation**

**Mathematical Formula** The formula for calculating the sedimentation coefficient is ခs = \dfrac{v}{\omega² \× r}. Where: - πs = Coefficient of sedimentation (in Svedberg units) - v = Velocity of sedimentation (m/s) Angular velocity (rad/s) = π\omega - ခr= Radial length (meters) R Shiny Implementation****

**Inputs:v:** Velocity of sedimentation (a numeric input).- ω: The angle of travel (a numerical input).r: Radial distance (supplied as a number).&#x20;

 **Reactive Calculation: -** Establish a reactive function that is used to determine the sedimentation coefficient.{{{r   sedimentation\_coefficient \\- reactive({     v \\- input$velocity      omega \\- input$angular\_velocity              \       \                             s \\- v / (omega²  r)&#x20;

The sedimentation coefficient is displayed in Text

** Plot**: **To illustrate the computed concentration, make a bar graph.Output$concentration\_result {{{r \\- renderText({       paste("Concentration:", round(concentration(), 2), "ng/μL")    })       output$concentration\_plot \\- renderPlot({       barplot(concentration(), names.arg = input$type, col = "green",           ylab = "Concentration (ng/μL)")    }) The formula for calculating the sedimentation coefficient is ခs = \dfrac{v}{\omega^2 \times r}. Where: - πs = Coefficient of sedimentation (in Svedberg units) - v = Velocity of sedimentation (m/s) Angular velocity (rad/s) = π\omega - ခr = Radial length (meters) R Shiny Implementation.

 The first input is the sedimentation velocity (a numerical input denoted as v).- ω: The angle of travel (a numerical input).r: Radial distance (supplied as a number).

 

**Reactive Calculation Plot:** Compile the sedimentation coefficient into a bar graph.{{{r  output$sedimentation\_result \\- renderText({     paste("Sedimentation Coefficient:", round(sedimentation\_coefficient(), 6), "Svedberg units")  })            output$sedimentation\_plot \\- renderPlot({        barplot(sedimentation\_coefficient(), names.arg = "Sedimentation Coefficient",** Results: Text:** Present the determined concentration.

**Plot:** Make a bar graph to show the determined concentration.{{{r output$concentration\_result \\- renderText({    paste("Concentration:", round(concentration(), 2), "ng/μL")  })output$concentration\_plot \\- renderPlot({ barplot(concentration(), names.arg = input$type, col = "green", ylab = "Concentration (ng/μL)") }){\~&#x20;

 

 

**4.Sedimentation Coefficient Calculation**

**Reactive Formula** The formula for calculating the sedimentation coefficient is ခs = \dfrac{v}{\omega² \× r}. Where: - πs = Coefficient of sedimentation (in Svedberg units) - v = Velocity of sedimentation (m/s) Angular velocity (rad/s) = π\omega - ခr = Radial length (meters) R Shiny Implementation&#x20;

**Inputs:v: **Velocity of sedimentation (a numeric input).- ω: The angle of travel (a numerical input).r: Radial distance (supplied as a number).

 

**Reactive Calculation**: **- Establish a reactive function that is used to determine the sedimentation coefficient.{{{r   sedimentation\_coefficient \\- reactive({     v \\- input$velocity      omega \\- input$angular\_velocity              \      \                             s \\- v / (omega²  r)         

                               

**Results: - Text:** Show the sedimentation coefficient.

**Plot:** To see the sedimentation coefficient, make a bar graph.{{{r  output$sedimentation\_result \\- renderText({     paste("Sedimentation Coefficient:", round(sedimentation\_coefficient(), 6), "Svedberg units")  })output$sedimentation\_plot <- renderPlot({ barplot(sedimentation\_coefficient(), names.arg = "Sedimentation Coefficient", col = "purple", ylab = "Coefficient (Svedberg units)") }){\~ --- Extra Implementation Information:A "Print Result" button that enables users to obtain a PDF of the results may be included with each calculator:\[{}{r output$download \\- downloadHandler(}   filename = function() { "results.pdf" },   content = function(file) {         pdf(file)       print(textOutput)      dev.off()    }  ){\~ 2.

** Dynamic Notes Section**: **When a user chooses a certain calculator, a dynamic user interface ({uiOutput}) should be used to display instructions.output$notes \\- render {}{rUI({      if (input$calculator == "Stock Solution") {       HTML("Instructions for Stock Solution Calculator...")    } else if (input$calculator == "Serial Dilution") {            HTML("Instructions for Serial Dilution Calculator...")                                                                   
