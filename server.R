#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tools)
library(data.table)
library(readxl)
library(markdown)
library(LEMMA)

expected_sheets <- c(
    "Parameters with Distributions","Interventions","Model Inputs","Data",
    "Vaccine Distribution","Vaccine Doses - Observed","Vaccine Doses - Future","Variants",
    "PUI Details","Internal"
)

LEMMA_forecast <- new.env()
source(
    file = "https://raw.githubusercontent.com/LocalEpi/LEMMA-Forecasts/master/Code/GetCountyData.R",
    local = LEMMA_forecast
)
source(
    file = "https://raw.githubusercontent.com/LocalEpi/LEMMA-Forecasts/master/Code/RunCountiesFromBeginning.R",
    local = LEMMA_forecast
)

server <- function(input, output, session) {
    
    # --------------------------------------------------------------------------------
    # reactive elements
    # --------------------------------------------------------------------------------
    
    # # reactive: excel upload
    # xlsx_input <- reactive({
    #     req(input$upload)
    #     ext <- tools::file_ext(input$upload$name)
    #     if(ext != "xlsx"){
    #         validate("Invalid file; Please upload a .xlsx file")
    #     }
    #     sheets <- readxl::excel_sheets(path = normalizePath(input$upload$datapath))
    #     if(!identical(expected_sheets,sheets)){
    #         validate(cat("Invalid file; File needs 10 named sheets: ",paste0(expected_sheets,collapse = ", ")))
    #     }
    #     id <- showNotification("Reading data", duration = NULL, closeButton = FALSE,type = "message")
    #     on.exit(removeNotification(id), add = TRUE)
    #     LEMMA:::ReadInputs(path = input$upload$datapath)
    # })
    # 
    # # reactive: inputs
    # LEMMA_inputs <- reactive({
    #     req(xlsx_input())
    #     id <- showNotification("Generating LEMMA parameters", duration = NULL, closeButton = FALSE,type = "message")
    #     on.exit(removeNotification(id), add = TRUE)
    #     LEMMA:::ProcessSheets(xlsx_input())
    # })
    
    # inputs
    LEMMA_inputs <- reactiveVal()
    observeEvent(input$upload, {
        # browser()
        # req(input$upload)
        
        ext <- tools::file_ext(input$upload$name)
        shinyFeedback::feedback(inputId = "upload",show = ext != "xlsx",text = "Invalid file; Please upload a .xlsx file",color = "red")
        if (ext != "xlsx") {
            # validate("Invalid file; Please upload a .xlsx file")
            req(FALSE)
        }
        # shinyFeedback::feedback(inputId = "upload",show = {ext != "xlsx"},text = "Invalid file; Please upload a .xlsx file",color = "red")

        sheets <- readxl::excel_sheets(path = normalizePath(input$upload$datapath))
        shinyFeedback::feedback(inputId = "upload",show = !identical(expected_sheets, sheets),text = "Invalid file; File needs 10 named sheets",color = "red")
        if (!identical(expected_sheets, sheets)) {
            req(FALSE)
            # validate( cat("Invalid file; File needs 10 named sheets: ",paste0(expected_sheets,collapse = ", ")))
        }
        
        id1 <- showNotification("Reading data", duration = NULL, closeButton = FALSE,type = "message")
        on.exit(removeNotification(id1), add = TRUE)
        input <- LEMMA:::ReadInputs(path = input$upload$datapath)
        
        id2 <- showNotification("Generating LEMMA parameters", duration = NULL, closeButton = FALSE,type = "message")
        on.exit(removeNotification(id2), add = TRUE)
        
        LEMMA_inputs(LEMMA:::ProcessSheets(input))
    })
    
    
    # reactive: LEMMA run from excel upload
    LEMMA_excel_run <- reactiveVal()
    observeEvent(input$LEMMA_xlsx, {
        req(LEMMA_inputs())
        shinyjs::disable("LEMMA_xlsx")
        id <- showNotification("Running LEMMA", duration = NULL, closeButton = FALSE,type = "message")
        on.exit(removeNotification(id), add = TRUE)
        LEMMA_excel_run(LEMMA:::CredibilityIntervalData(inputs = LEMMA_inputs(),fit.to.data = NULL))
        shinyjs::enable("LEMMA_xlsx")
    })
    
    # reactive: LEMMA excel output
    LEMMA_excel_out <- reactive({
        req(LEMMA_excel_run())
        id <- showNotification("Creating .xlsx output file", duration = NULL, closeButton = FALSE,type = "message")
        on.exit(removeNotification(id), add = TRUE)
        LEMMA:::GetExcelOutputData(LEMMA_excel_run()$projection, LEMMA_excel_run()$fit.to.data, LEMMA_excel_run()$inputs)
    })
    
    # --------------------------------------------------------------------------------
    # output elements
    # --------------------------------------------------------------------------------
    
    # output: checker to let users know excel uploaded
    output$xlsx_check_txt <- renderText({
        req(LEMMA_inputs())
        paste0("File successfully uploaded, size ",signif(input$upload$size/1e3,digits = 6),"Kb")
    })
    
    # output: download the sample template
    output$download_template <- downloadHandler(
        filename = function() {
            return("example.xlsx")
        },
        content = function(file) {
            file.copy(from = normalizePath(path = paste0(path.package("LEMMA"),"/extdata/template.xlsx")),to = file)
        },
        contentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    )
    
    # output: downloald excel output
    output$download_xlsx_out <- downloadHandler(
        filename = function() {
            return("output.xlsx")
        },
        content = function(file) {
            req(LEMMA_excel_out())
            openxlsx::write.xlsx(LEMMA_excel_out(), file = file)
        },
        contentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    )
    
    # output: downloald pdf output
    output$download_pdf_out <- downloadHandler(
        filename = function() {
            return("output.pdf")
        },
        content = function(file) {
            req(LEMMA_excel_run())
            id <- showNotification("Creating .pdf output file", duration = NULL, closeButton = FALSE,type = "message")
            on.exit(removeNotification(id), add = TRUE)
            
            devlist <- grDevices::dev.list()
            sapply(devlist[names(devlist) == "pdf"], grDevices::dev.off) 
            
            grDevices::pdf(file = file, width = 9.350, height = 7.225)
            
            plots <- LEMMA:::GetPdfOutputPlots(fit = LEMMA_excel_run()$fit.extended, projection = LEMMA_excel_run()$projection, inputs = LEMMA_excel_run()$inputs)
            
            grDevices::dev.off()
        },
        contentType = "application/pdf"
    )
    
    # # DEBUGGING
    # output$table <- renderTable({
    #     LEMMA_excel_run()$projection
    # })
}