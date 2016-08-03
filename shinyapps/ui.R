
library(shiny)
library(shinyjs)

ui <- shinyUI(fluidPage(
  useShinyjs(),
  # Application title
  titlePanel("Linear regression model"),
  # Show a plot of the generated distribution
  wellPanel( 
    HTML("<h4>process the model</h4>"),
    # hide this input since the user is supposed to build models from the menus rather than typing
    shinyjs::hidden(textInput("userSpecifiedModel", "")), 
    shinyjs::hidden(textInput("finalizeInit", "")), 
    actionButton("goButton", "model residuals for synthetic data"),
    actionButton("remoteSubmitButton", "verify against original data"),
    htmlOutput("userRemoteResult")
  ),
  wellPanel(
    
    #tags$div(id = 'regressionClauses'),
    fluidRow( column(1, HTML("<h4>design<br>the<br>model</h4>") ), 
              column(11,
                     htmlOutput("userSpecifiedJobDetail")
              )
    ),
    fluidRow(
      column(3, wellPanel(HTML("<h5>dependent<br>variable</h5>"), 
                          uiOutput("uiDependentVariable"),
                          HTML("<hr>"),
                          actionButton("modelReset", "Reset to default model"))
      ),
      column(2, wellPanel(HTML("<h5>independent<br>variable clauses</h5>"), HTML("<hr>"),
                          actionButton('insertBtn', 'Add clause'),HTML("<hr>"),
                          actionButton('removeBtn', 'Remove clause') )
      ),
      column(3,  wellPanel(HTML("<h5>define <br> new clause</h5>"), 
                           uiOutput("uiModelOperation"), 
                           uiOutput("uiModelTerm"), 
                           uiOutput("uiModelModifier") )
      ),  column(4,
                 wellPanel(
                   HTML("<hr>"),
                   sliderInput("userSpecifiedEpsilon", "epsilon", 0.01, 1.0, 0.9, width = '100%' ),
                   numericInput("userSpecifiedUnit", "outcome unit: ", 1.0, min = 1.0, max = 100.0, width = '30%'))
      )
    ),
    
    
    plotOutput("userSyntheticResidualPlot")
    # plotOutput("userResidualPlot")
  )
))
