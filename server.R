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
library(openxlsx)
library(markdown)
library(parallel)
library(aws.s3)
library(LEMMA) # must be installed like this for shinyapps to work devtools::install_github(repo = "LocalEpi/LEMMA")
library(LEMMA.forecasts) # must be installed like this for shinyapps to work devtools::install_github(repo = "LocalEpi/LEMMA-Forecasts",subdir = "LEMMA.forecasts")

expected_sheets <- c(
    "Parameters with Distributions","Interventions","Model Inputs","Data",
    "Vaccine Distribution","Vaccine Doses - Observed","Vaccine Doses - Future","Variants",
    "PUI Details","Internal"
)

CA_counties <- c(
    "Los Angeles", "San Diego", "Orange", "Riverside", "San Bernardino", "Santa Clara",
    "Alameda", "Sacramento", "Contra Costa", "Fresno", "San Francisco", "Kern",
    "Ventura", "San Mateo", "San Joaquin", "Stanislaus", "Sonoma", "Tulare",
    "Santa Barbara", "Solano", "Monterey", "Placer", "San Luis Obispo", "Santa Cruz",
    "Merced", "Marin", "Butte", "Yolo", "El Dorado", "Imperial",
    "Shasta", "Madera", "Kings", "Napa", "Humboldt", "Nevada",
    "Mendocino", "Yuba", "Lake", "Tehama", "San Benito", "Tuolumne",
    "Siskiyou", "Del Norte", "Colusa"
)

# LEMMA_forecast <- new.env()
# source(
#     file = "https://raw.githubusercontent.com/LocalEpi/LEMMA-Forecasts/master/Code/GetCountyData.R",
#     local = LEMMA_forecast
# )
# source(
#     file = "https://raw.githubusercontent.com/LocalEpi/LEMMA-Forecasts/master/Code/RunCountiesFromBeginning.R",
#     local = LEMMA_forecast
# )

server <- function(input, output, session) {
    
    # --------------------------------------------------------------------------------
    #
    #   Excel Interface tab
    # 
    # --------------------------------------------------------------------------------
    
    # inputs
    LEMMA_inputs <- reactiveVal()
    observeEvent(input$upload, {
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
        shinybusy::show_modal_spinner(spin = "fading-circle",text = "Running LEMMA")
        # id <- showNotification("Running LEMMA", duration = NULL, closeButton = FALSE,type = "message")
        # on.exit(removeNotification(id), add = TRUE)
        LEMMA_excel_run(LEMMA:::CredibilityIntervalData(inputs = LEMMA_inputs(),fit.to.data = NULL))
        shinyjs::enable("LEMMA_xlsx")
        shinybusy::remove_modal_spinner()
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
    

    # --------------------------------------------------------------------------------
    # 
    #   Forecasting tab
    # 
    # --------------------------------------------------------------------------------
    
    # Forecasting
    forecast_done <- reactiveVal(value = FALSE)
    forecast_dir <- reactiveVal(value = NULL)
    observeEvent(input$forecast_run, {
        
        remote <- FALSE

        req(length(input$forecast_select_county) > 0)
        shinyjs::disable("forecast_run")
        shinybusy::show_modal_spinner(spin = "fading-circle",text = "Running LEMMA forecasts")

        ncounty <- length(input$forecast_select_county)
        writedir <- tempdir(check = TRUE)
        forecast_dir(writedir)
        if (length(list.dirs(writedir)) > 1) {
            unlink(
                x = paste0(writedir,"/Forecasts"),recursive = TRUE
            )
        }

        id1 <- showNotification("Downloading case data", duration = NULL, closeButton = FALSE,type = "message")
        on.exit(removeNotification(id1), add = TRUE)

        county.dt <- LEMMA.forecasts:::GetCountyData(remote = remote)
        max.date <- LEMMA.forecasts:::Get1(county.dt[!is.na(hosp.conf), max(date), by = "county"]$V1)

        id2 <- showNotification("Downloading vaccination data", duration = NULL, closeButton = FALSE,type = "message")
        on.exit(removeNotification(id2), add = TRUE)

        doses.dt <- LEMMA.forecasts:::GetDosesData(remote = remote)

        id3 <- showNotification("Running LEMMA forecasts", duration = NULL, closeButton = FALSE,type = "message")
        on.exit(removeNotification(id3), add = TRUE)

        out <- LEMMA.forecasts::RunOneCounty(
            county1 = input$forecast_select_county, county.dt = county.dt,doses.dt = doses.dt,remote = remote,writedir = writedir
        )

        forecast_done(TRUE)
        shinyjs::enable("forecast_run")
        shinybusy::remove_modal_spinner()
    })
    
    # output: downloald excel output
    output$forecast_download_pdf_out <- downloadHandler(
        filename = function() {
            return("forecast_pdf.zip")
        },
        content = function(file) {
            
            req(forecast_done())
            req(forecast_dir())
            
            all_files <- list.files(paste0(forecast_dir(), "/Forecasts"))
            pdf_files <- grep(pattern = ".pdf$",x = all_files)
            req(length(pdf_files)>0)
            utils::zip(
                zipfile = file,files = paste0(forecast_dir(),"/Forecasts/",all_files[pdf_files]),flags = "-j"
            )
            
            # openxlsx::write.xlsx(LEMMA_excel_out(), file = file)
        },
        contentType = "application/zip"
    )
    
    # output: downloald pdf output
    output$forecast_download_xlsx_out <- downloadHandler(
        filename = function() {
            return("forecast_xlsx.zip")
        },
        content = function(file) {
            
            req(forecast_done())
            req(forecast_dir())
            
            all_files <- list.files(paste0(forecast_dir(), "/Forecasts"))
            xlsx_files <- grep(pattern = ".xlsx$",x = all_files)
            req(length(xlsx_files)>0)
            utils::zip(
                zipfile = file,files = paste0(forecast_dir(),"/Forecasts/",all_files[xlsx_files]),flags = "-j"
            )
            
        },
        contentType = "application/zip"
    )
    
    
    # --------------------------------------------------------------------------------
    # 
    #   Scenarios tab
    # 
    # --------------------------------------------------------------------------------
    
    # messy but no other way to get this to work.
    # the reactive values are what we want: https://stackoverflow.com/questions/41706201/shiny-numericinput-does-not-respect-min-and-max-values
    
    # 1 young
    scenarios_uptake_vals <- reactiveValues(val_young = 25, val_middle = 75, val_elder = 85, min = 0, max = 100)
    
    scenarios_young_uptake_value <- reactive({
        if(!is.null(input$scenarios_young_uptake)){
            if(input$scenarios_young_uptake < scenarios_uptake_vals$min) return(scenarios_uptake_vals$min)
            if(input$scenarios_young_uptake > scenarios_uptake_vals$max) return(scenarios_uptake_vals$max)     
            return(input$scenarios_young_uptake)
        }else{
            return(scenarios_uptake_vals$val_young)
        }
    })
    
    output$scenarios_young_uptake <- renderUI(numericInput("scenarios_young_uptake", "", min = scenarios_uptake_vals$min, 
                                             max = scenarios_uptake_vals$max, value = scenarios_young_uptake_value()))
    
    # 2. middle
    scenarios_middle_uptake_value <- reactive({
        if(!is.null(input$scenarios_middle_uptake)){
            if(input$scenarios_middle_uptake < scenarios_uptake_vals$min) return(scenarios_uptake_vals$min)
            if(input$scenarios_middle_uptake > scenarios_uptake_vals$max) return(scenarios_uptake_vals$max)     
            return(input$scenarios_middle_uptake)
        }else{
            return(scenarios_uptake_vals$val_middle)
        }
    })
    
    output$scenarios_middle_uptake <- renderUI(numericInput("scenarios_middle_uptake", "", min = scenarios_uptake_vals$min, 
                                                           max = scenarios_uptake_vals$max, value = scenarios_middle_uptake_value()))
    
    # 3. elderly
    scenarios_elder_uptake_value <- reactive({
        if(!is.null(input$scenarios_elder_uptake)){
            if(input$scenarios_elder_uptake < scenarios_uptake_vals$min) return(scenarios_uptake_vals$min)
            if(input$scenarios_elder_uptake > scenarios_uptake_vals$max) return(scenarios_uptake_vals$max)     
            return(input$scenarios_elder_uptake)
        }else{
            return(scenarios_uptake_vals$val_elder)
        }
    })
    
    output$scenarios_elder_uptake <- renderUI(numericInput("scenarios_elder_uptake", "", min = scenarios_uptake_vals$min, 
                                                           max = scenarios_uptake_vals$max, value = scenarios_elder_uptake_value()))
    
    # scenarios
    scenarios_done <- reactiveVal(value = FALSE)
    scenarios_dir <- reactiveVal(value = NULL)
    observeEvent(input$scenarios_run, {
        
        remote <- FALSE
        # browser()

        shinyjs::disable("scenarios_run")
        shinybusy::show_modal_spinner(spin = "fading-circle",text = "Running LEMMA scenarios")
        
        ncounty <- length(input$forecast_select_county)
        writedir <- tempdir(check = TRUE)
        scenarios_dir(writedir)
        if (length(list.dirs(writedir)) > 1) {
            unlink(
                x = paste0(writedir,"/Scenarios"),recursive = TRUE
            )
        }
        
        id1 <- showNotification("Downloading case data", duration = NULL, closeButton = FALSE,type = "message")
        on.exit(removeNotification(id1), add = TRUE)
        
        county.dt <- LEMMA.forecasts:::GetCountyData(remote = remote)
        max.date <- LEMMA.forecasts:::Get1(county.dt[!is.na(hosp.conf), max(date), by = "county"]$V1)
        
        id2 <- showNotification("Downloading vaccination data", duration = NULL, closeButton = FALSE,type = "message")
        on.exit(removeNotification(id2), add = TRUE)
        
        doses.dt <- LEMMA.forecasts:::GetDosesData(remote = remote)
        
        id3 <- showNotification("Running LEMMA scenarios", duration = NULL, closeButton = FALSE,type = "message")
        on.exit(removeNotification(id3), add = TRUE)
        
        # get user input vaccine data
        vaxx_uptake <- c(scenarios_young_uptake_value(),scenarios_middle_uptake_value(),scenarios_elder_uptake_value())
        
        uk_growth <- input$scenarios_uk + 1
        br_growth <- input$scenarios_br + 1
        
        out <- LEMMA.forecasts:::RunOneCounty_scen_input(
            county1 = input$forecast_select_county, county.dt = county.dt,doses.dt = doses.dt,
            k_uptake = "notused",k_ukgrowth = uk_growth,k_brgrowth = br_growth,k_max_open = input$scenarios_reopen,
            vaccine_uptake = vaxx_uptake, vaccine_dosing_jj = input$scenarios_jj_day, vaccine_dosing_mrna = input$scenarios_mrna_day,
            remote = remote,writedir = writedir
        )
        
        scenarios_done(TRUE)
        shinyjs::enable("scenarios_run")
        shinybusy::remove_modal_spinner()
    })
    
    # output: downloald excel output
    output$scenarios_download_pdf_out <- downloadHandler(
        filename = function() {
            return("scenarios_pdf.zip")
        },
        content = function(file) {
            
            req(scenarios_done())
            req(scenarios_dir())
            
            all_files <- list.files(paste0(scenarios_dir(), "/Scenarios"))
            pdf_files <- grep(pattern = ".pdf$",x = all_files)
            req(length(pdf_files)>0)
            utils::zip(
                zipfile = file,files = paste0(scenarios_dir(),"/Scenarios/",all_files[pdf_files]),flags = "-j"
            )
            
            # openxlsx::write.xlsx(LEMMA_excel_out(), file = file)
        },
        contentType = "application/zip"
    )
    
    # output: downloald pdf output
    output$scenarios_download_xlsx_out <- downloadHandler(
        filename = function() {
            return("scenarios_xlsx.zip")
        },
        content = function(file) {
            
            req(scenarios_done())
            req(scenarios_dir())
            
            all_files <- list.files(paste0(scenarios_dir(), "/Scenarios"))
            xlsx_files <- grep(pattern = ".xlsx$",x = all_files)
            req(length(xlsx_files)>0)
            utils::zip(
                zipfile = file,files = paste0(scenarios_dir(),"/Scenarios/",all_files[xlsx_files]),flags = "-j"
            )
            
        },
        contentType = "application/zip"
    )
    
}