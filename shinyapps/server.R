library(shiny)
library(httr)	

library(VerificationMeasures)

setwd("~/")

# here is wherer we would load original data if we had it
#load("cpsOriginal.RData")

# load synthetic data
load("/synthetic-data/cpsSynthetic.RData")

modelVariables <- names(cpsSynthetic)
modelOperations = c('+', '-','*', '/')
modelDependentVariable = "income"

initialModelDependentVariable = "income"
initialUserSpecifiedModel = paste(modelDependentVariable, ' ~ ', 'age', '+', 'I(age^2)', '+', 'educ', '+', 'marital', '+', 'sex')
initialUserSpecifiedEpsilon = 0.9
initialUserSpecifiedUnit = 1.0
initialUserSpecifiedClauses = c('age', '+ I(age^2)', '+ educ', '+ marital', '+ sex')

server <- shinyServer(function(input, output, session) {
  
  # track names of elements inserted (so we can remove the newest first)
  insertedClauseNames <- character(0)
  insertedClauses <<- initialUserSpecifiedClauses
  
  userSpecifiedEpsilon = initialUserSpecifiedEpsilon
  userSpecifiedUnit = initialUserSpecifiedUnit
  userSpecifiedDependentVariable = initialModelDependentVariable
  userSpecifiedModel = initialUserSpecifiedModel
  
  output$userSpecifiedDependentVariable <- renderPrint({ 
    input$userSpecifiedDependentVariable 
  })
  
  output$uiDependentVariable <- renderUI({
    selectInput("userSpecifiedDependentVariable", "",
                choices = modelVariables, selected = userSpecifiedDependentVariable,
                width = "80%" )
  })
  
  
  observeEvent(input$insertBtn, {
    oper = isolate(input$userSpecifiedModelOperation)
    term = isolate(input$userSpecifiedModelTerm)
    modif = isolate(input$userSpecifiedModelModifier)
    if( modif == "^2"){
      term = paste0("I(",term,")",modif)
    }
    if( modif == "log"){
      term = paste0("log(",term,")")
    }
    # add the clause to the list of clauses
    newClause = paste(oper, term)
    insertedClauses <<- c(insertedClauses, newClause)
    # send a message to update the model
    termClauses = paste(insertedClauses, collapse=" ")
    updateModel = paste(input$userSpecifiedDependentVariable, ' ~ ', termClauses, collapse=" ")
    aMessage = list(value = updateModel)
    session$sendInputMessage("userSpecifiedModel", aMessage)
    
    btn <- input$insertBtn
    id <- paste0('rClause', btn)
    print(btn)
    insertUI(
      selector = "#regressionClauses",
      ui = tags$div(
        tags$p(newClause),
        id = id
      )
    )
    insertedClauseNames <<- c(id, insertedClauseNames)
  })
  
  
  observeEvent(input$removeBtn, {
    removeUI(
      ## pass in appropriate div id
      selector = paste0('#',insertedClauseNames[1])
    )
    insertedClauseNames <<- insertedClauseNames[-1]
    insertedClauses <<- insertedClauses[-length(insertedClauses)]
    # send a message to update the model
    termClauses = paste(insertedClauses, collapse=" ")
    updateModel = paste(input$userSpecifiedDependentVariable, ' ~ ', termClauses, collapse=" ")
    aMessage = list(value = updateModel)
    session$sendInputMessage("userSpecifiedModel", aMessage)
  })
  
  
  output$uiModelModifier <- renderUI({
    modifierList = c("   ", "^2", "log")
    selectInput("userSpecifiedModelModifier", "modifier", 
                choices = modifierList, selected = "   ", width = "30%" )
  })
  
  output$userSpecifiedModelModifier <- renderPrint({ 
    input$userSpecifiedModelModifier 
  })
  
  output$uiModelTerm <- renderUI({
    # remove the dependent variable from the list of possible terms
    currentList = unlist(lapply(modelVariables, 
                                function(x) if (x != input$userSpecifiedDependentVariable) { x }))
    currentList = append('   ', currentList)
    selectInput("userSpecifiedModelTerm", "term",
                choices = currentList, selected = "   ", width = "50%" )
  })
  
  output$userSpecifiedModelTerm <- renderPrint({ 
    input$userSpecifiedModelTerm 
  })
  
  output$uiModelOperation <- renderUI({
    currentList = append('   ', modelOperations)
    selectInput("userSpecifiedModelOperation", "operation",
                choices = currentList, selected = "   ", width = "30%" )
  })
  
  output$userSpecifiedModelOperation <- renderPrint({ 
    input$userSpecifiedModelOperation 
  })
  
  output$userSpecifiedJobDetail <- renderText({
    paste("<br>current model:<b>", input$userSpecifiedModel, 
          "</b><br>epsilon: <b>", input$userSpecifiedEpsilon, 
          "</b>&nbsp;outcome unit: <b>", input$userSpecifiedUnit, "</b><br><br>")
  })
  
  output$userSpecifiedEpsilon <- renderText({
    x <- input$userSpecifiedEpsilon
    print(x)
  })
  
  output$userSpecifiedUnit <- renderText({
    x <- input$userSpecifiedUnit
    print(x)
  })
  
  output$userSpecifiedModel <- renderText({
    x <- input$userSpecifiedModel
    print(x)
  })
  
  output$usermodelText <- renderText({
    as.character(input$my_usermodel)
  })
  
  observe({
    # reset the model whenever the userSpecifiedDependentVariable changes
    newModel = paste(input$userSpecifiedDependentVariable, ' ~ ')
    # throw out all the terms
    insertedClauses <<- character(0) 
    # Send an update to userSpecifiedModel to reset the value
    aMessage = list(value = newModel)
    session$sendInputMessage("userSpecifiedModel", aMessage)
  })
  
  
  observe({
    # Run whenever model reset to default button is pressed
    input$modelReset
    
    insertedClauses <<- initialUserSpecifiedClauses
    # Send an update to userSpecifiedModel to reset the value
    aMessage = list(value = initialUserSpecifiedModel)
    session$sendInputMessage("userSpecifiedModel", aMessage)
  })
  
  output$userRemoteResult <- renderText({
    # add a dependency on the go button
    input$remoteSubmitButton
    if (input$remoteSubmitButton == 0)
      return("")
    isolate({
      # generate a residual plot that we can upload along with the job
      theUserModel <- isolate(input$userSpecifiedModel)
      if (theUserModel!="") { # make sure there is a model
        reg = lm( theUserModel, data = cpsSynthetic)
        # Get predictions and residuals for the synthetic data
        y.hat <- predict(object=reg,newdata = cpsSynthetic)
        residuals <- cpsSynthetic$income-y.hat
        # Creating the output: synthetic data residual plot
        D <- cbind(y.hat, residuals)
        epsilon = isolate(input$userSpecifiedEpsilon)
        unit = isolate(input$userSpecifiedUnit)
        nplots = PriRP(D,epsilon,unit)
        # write the output image file
        png('synthetic_residuals.png', width = 1024, height = 768)
        title <- paste("Residuals for synthetic data with epsilon= ", epsilon, ", model: ", theUserModel, sep='')
        plot(nplots,pch="*",ylab="residuals", xlab=title)
        dev.off()
      }

      # now upload the job for remote processing
      actualimagefile <- paste(getwd(),'synthetic_residuals.png', sep = '/')
      url <- "https://synthetic.oit.duke.edu/app_install/remote_jobs"
      a_result <- POST(url, encode="multipart",  accept_json(), add_headers("charset=utf-8"),
                body = list(
                  job_submit_token = Sys.getenv("MAGIC_TOKEN"),
                  epsilon = input$userSpecifiedEpsilon,
                  output_unit = input$userSpecifiedUnit,
                  model = input$userSpecifiedModel,
                  syntheticfile = upload_file(actualimagefile, type="image/png")))
      transaction_status <- unlist(content(a_result))["status"]
      transaction_created_at <- unlist(content(a_result))["created_at"]
      
      paste("<br><b>Original data model verification job submitted</b>",
            "<br>date:",  format(Sys.time(), "%a %b %d %X %Y"), 
            "<br>model:<b>", input$userSpecifiedModel, 
            "</b><br>epsilon: <b>", input$userSpecifiedEpsilon, 
            "</b>&nbsp;outcome unit: <b>", input$userSpecifiedUnit, 
            "</b><br>remote job submit status: <b>",transaction_status, 
            "</b><br>remote job submit time: <b>",transaction_created_at,
            "</b><br>",
            "<p><a href='https://synthetic.oit.duke.edu/verify_jobs'>Click to view verification job results</a></p>"
            )
    })
  })
  
  output$userResidualPlot  <- renderPlot({
    # add a dependency on the go button
    input$goButton
    
    # isolate the dependency on input$userSpecifiedModel
    theUserModel <- isolate(input$userSpecifiedModel)
    if (theUserModel!="") { # make sure there is a model
      # fit the model to the synthetic data
      reg = lm( theUserModel, data = cpsSynthetic)
      
      # Get predictions and residuals for the original data
      y.hat <- predict(object=reg,newdata = cpsOriginal)
      residuals <- cpsOriginal$income-y.hat
      
      # Creating the output: private residual plot
      D <- cbind(y.hat, residuals)
      # epsilon <- 1.0
      # unit <- 1.0
      epsilon = isolate(input$userSpecifiedEpsilon)
      unit = isolate(input$userSpecifiedUnit)
      nplots = PriRP(D,epsilon,unit)
      title <- paste("Residuals for original data with epsilon= ", epsilon, ", model: ",theUserModel, sep='')
      plot(nplots,pch="+",ylab="residuals", xlab=title)
    }
  })
  
  
  output$userSyntheticResidualPlot  <- renderPlot({
    # add a dependency on the go button
    input$goButton
    
    # isolate the dependency on input$userSpecifiedModel
    theUserModel <- isolate(input$userSpecifiedModel)
    if (theUserModel!="") { # make sure there is a model
      reg = lm( theUserModel, data = cpsSynthetic)
      
      # Get predictions and residuals for the synthetic data
      y.hat <- predict(object=reg,newdata = cpsSynthetic)
      residuals <- cpsSynthetic$income-y.hat
      
      # Creating the output: synthetic data residual plot
      D <- cbind(y.hat, residuals)
      
      # epsilon <- 1.0
      # unit <- 1.0
      epsilon = isolate(input$userSpecifiedEpsilon)
      unit = isolate(input$userSpecifiedUnit)
      nplots = PriRP(D,epsilon,unit)
      title <- paste("Residuals for synthetic data with epsilon= ", epsilon, ", model: ", theUserModel, sep='')
      plot(nplots,pch="*",ylab="residuals", xlab=title)
    }
  })
  

  final_init_run_count = 0
  
  output$finalizeInit <- renderPrint({ 
    final_init_run_count 
  })
  
  observe({
    #
    # keep setting the default model until we have finished initializing.
    # it takes a couple rounds for the reactive elements to stabilize
    # so we use a hidden object in the UI to keep track of how many times
    # we have run this code to get the default model in place at initialization 
    # time
    # 
    input$finalizeInit
    if ( final_init_run_count < 3 ) {
      final_init_run_count = final_init_run_count + 1
      insertedClauses <<- initialUserSpecifiedClauses
      # Send an update to userSpecifiedModel to reset the value
      aMessage = list(value = initialUserSpecifiedModel)
      session$sendInputMessage("userSpecifiedModel", aMessage)
      aMessage = list(value = final_init_run_count)
      session$sendInputMessage("finalizeInit", aMessage)
    }
  })


  
})
