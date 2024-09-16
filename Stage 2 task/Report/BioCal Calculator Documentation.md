# THE DOCUMENTATION OF FORMULAS AND LOGIC

The reasoning for each of the four calculators in R Shiny and the underlying mathematical formulas are explained below. The processes for configuring the reactive calculation, the underlying mathematical ideas, and the reasoning behind each calculator's implementation within the Shiny framework are all covered in the explanation.

## 1. Stock Solution Dilution Calculation

### Mathematical Formula
The following formula controls the dilution of the stock solution:
\[ C1 \times V1 = C2 \times V2 \]
Where: 
- C1 = Concentration of stock (known)
- V1 = Required (unknown) volume of stock solution
- C2 = Targeted ultimate concentration
- V2 = Final volume

The unknown volume can be solved by rearranging this as follows:
\[ V1 = \frac{C2 \times V2}{C1} \]

### R Shiny Implementation
**Inputs:**
- C1: Stock concentration (numeric input)
- C2: The desired amount (numeric input)
- V2: The final volume, entered as a number

**Reactive Calculation:**
Create a reactive function that applies the formula to compute V1:
```r
stock_volume <- reactive({
  C1 <- input$stock_concentration
  C2 <- input$final_concentration
  V2 <- input$final_volume
  V1 <- (C2 × V2) / C1
  return(V1)
})

```

**Text:** Show the stock solution's computed volume.

**Scene:** Make a bar graph that shows the ratio of the diluent (V2-V1) to the stock solution (V1):

output$stock_result <- renderText({
  paste("You need", round(stock_volume(), 2), "mL of stock solution.")
})
renderPlot({
  stock <- stock_volume()
  dilutent <- input$final_volume - stock
  barplot(c(stock, dilutent), names.arg = c("Stock Solution", "Diluent"), col = c("blue", "gray"), ylab = "Volume (mL)")
})

...

---

## 2. Serial Dilution Calculation

### Mathematical Formula
The following formula defines serial dilutions:
\[ C_n = \dfrac{C_0}{DF^n} \]
Where:
- C0 = Initial concentration
- DF = Dilution factor (the amount that the solution is diluted in each phase)
- n = The step of dilution (from 0)

Following each dilution stage, the concentration is determined using this formula.

### R Shiny Implementation
**Sources:**
- C0: Initial concentration (numeric input)
- DF: Dilution factor (input of numbers)
- n: The number of dilution stages (supplied as a numeric)

### Reactive Calculation
Create a data frame of concentrations for every dilution step by defining a reactive function:
```r
serial_dilution <- reactive({
  C0 <- input$initial_concentration
  DF <- input$dilution_factor
  # Additional logic for dilution calculations
})

```

---

# Results:

- **Table**: Show the dilution series as a tabular representation.
- **Plot**: To see the dilution, plot the concentration vs. dilution step.
```r
output$dilution_table <- renderTable({
  serial_dilution()
})
output$dilution_plot <- renderPlot({
  plot(serial_dilution()$Step, serial_dilution()$Concentration, type = "b", col = "blue", xlab = "Dilution Step", ylab = "Concentration")
})

```

---

## 3. DNA/RNA Concentration Calculation

### Mathematical Formula
Using conversion factors specific to each nucleic acid, the absorbance at 260 nm is used to compute the concentration of DNA or RNA:  
\[ \text{Absorbance} \times \text{Conversion Factor} = \text{Concentration} \]

- 50 ng/μL is the DNA conversion factor per A260.  
- 40 ng/μL is the RNA conversion factor per A260.

### R Shiny Implementation
**Inputs:**
- Absorbance: Numeric input for absorbance at 260 nm  
- Type: Selection input for RNA and DNA  

### Reactive Calculation:
Based on the selected type, define a reactive function that calculates the concentration.
```r
concentration <- reactive({
  absorbance <- input$absorbance
  conversion_factor <- if (input$type == "DNA") 50 else 40
  conc <- absorbance * conversion_factor
  return(conc)
})

```

---

# Results:
```r
**Text:** Present the determined concentration.  
**Plot:** Make a bar graph to show the determined concentration.

output$concentration_result <- renderText({
  paste("Concentration:", round(concentration(), 2), "ng/μL")
})
output$concentration_plot <- renderPlot({
  barplot(concentration(), names.arg = input$type, col = "green", ylab = "Concentration (ng/μL)")
})

```

---

## 4. Sedimentation Coefficient Calculation

### Mathematical Formula
The formula for calculating the sedimentation coefficient is:  
\[
s = \frac{v}{\omega^2 \times r}
\]
Where:  
- **s** = Coefficient of sedimentation (in Svedberg units)  
- **v** = Velocity of sedimentation (m/s)  
- **\(\omega\)** = Angular velocity (rad/s)  
- **r** = Radial length (meters)

### R Shiny Implementation

**Inputs:**
- **v**: Velocity of sedimentation (numeric input)  
- **\(\omega\)**: Angular velocity (numeric input)  
- **r**: Radial distance (numeric input)

### Reactive Calculation
Define a reactive function to compute the sedimentation coefficient:
```r
sedimentation_coefficient <- reactive({
  v <- input$velocity
  omega <- input$angular_velocity
  r <- input$radial_length
  s <- v / (omega^2 * r)
  return(s)
})

```

---

# Results:

**Text:**  
Show the sedimentation coefficient.

**Plot:**  
Make a bar graph to display the sedimentation coefficient.
```r
output$sedimentation_result <- renderText({
  paste("Sedimentation Coefficient:", round(sedimentation_coefficient(), 6), "Svedberg units")
})
output$sedimentation_plot <- renderPlot({
  barplot(sedimentation_coefficient(), names.arg = "Sedimentation Coefficient", col = "purple", ylab = "Coefficient (Svedberg units)")
})

```

---

# Extra Implementation Information

A "Print Result" button may be included with each calculator to allow users to download a PDF of the results:
```r
output$download <- downloadHandler(
  filename = function() { "results.pdf" },
  content = function(file) {
    pdf(file)
    print(text output)
    dev.off()
  }
)

```

---

# Dynamic Notes Section

When a user selects a calculator, a dynamic UI should display instructions:
```r
output$notes <- renderUI({
  if (input$calculator == "Stock Solution") {
    HTML("Instructions for Stock Solution Calculator...")
  } else if (input$calculator == "Serial Dilution") {
    HTML("Instructions for Serial Dilution Calculator...")
  }
})

