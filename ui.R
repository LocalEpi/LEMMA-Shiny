#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#


# library(shiny)

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

ui <- tagList(
    shinyjs::useShinyjs(),
    shinyFeedback::useShinyFeedback(),
    shiny::navbarPage(
        "LEMMA (Local Epidemic Modeling for Management and Action)",   
        tabPanel("LEMMA Model", 
                 fluidRow(
                     column(2),
                     column(
                         8,
                         includeMarkdown("src/SEIRModel.md")
                     ),
                     column(2)
                 )
        ),
        # --------------------------------------------------------------------------------
        # navbar: Excel interface
        # --------------------------------------------------------------------------------
        navbarMenu("Excel Interface", 
                   # --------------------------------------------------------------------------------
                   # tabPanel: data input
                   # --------------------------------------------------------------------------------
                   tabPanel(
                       title = "Data input", value = "xlsx-a",
                       fluidRow(
                           column(4,
                                  fileInput("upload", "Upload a spreadsheet"),
                                  textOutput("xlsx_check_txt"),
                                  br(),
                                  HTML(r"(<label class="control-label" id="upload-label" for="upload">Download template spreadsheet</label>)"),
                                  br(),
                                  downloadButton("download_template", "Download")
                           ),
                           column(8,
                                  includeMarkdown(path = "src/excel_input.md")
                           )
                       )
                   ),
                   # --------------------------------------------------------------------------------
                   # tabPanel: run LEMMA
                   # --------------------------------------------------------------------------------
                   tabPanel(
                       title = "Run LEMMA",value =  "xlsx-b",
                       fluidRow(
                           column(4,
                                  actionButton("LEMMA_xlsx", "Run LEMMA", class = "btn btn-primary btn-lg btn-block"),
                                  hr(),
                                  downloadButton("download_pdf_out", "Download PDF output"),
                                  downloadButton("download_xlsx_out", "Download Excel output")
                           ),
                           column(8,
                                  includeMarkdown(path = "src/excel_output.md")
                           )
                       )
                   )
        ),
        # --------------------------------------------------------------------------------
        # tabPanel: Forecasts
        # --------------------------------------------------------------------------------
        tabPanel(
            title = "Forecasts",
            fluidRow(
                column(
                    
                    width = 4,
                    # shinyWidgets::multiInput(
                    #     inputId = "forecast_select_county", label = "California Counties:",
                    #     choices = CA_counties,
                    #     selected = "Alameda", width = "100%"
                    # ),
                    selectInput(
                        inputId = "forecast_select_county",
                        label = "California Counties:",
                        choices = as.list(CA_counties),
                        selected = "Alameda"
                    ),
                    # actionButton(inputId = "forecast_select_county_selall",label = "Select all"),
                    # actionButton(inputId = "forecast_select_county_sel0",label = "Select none"),
                    hr(),
                    actionButton("forecast_run", "Run Forecasts", class = "btn btn-primary btn-lg btn-block"),
                    hr(),
                    downloadButton("forecast_download_pdf_out", "Download PDF output"),
                    downloadButton("forecast_download_xlsx_out", "Download Excel output")
                ),
                column(
                    width = 8,
                    includeMarkdown(path = "src/forecasts.md")
                )
            )
        ),
        # --------------------------------------------------------------------------------
        # tabPanel: Scenarios
        # --------------------------------------------------------------------------------
        tabPanel(
            "Scenarios",
            fluidRow(
                column(
                    width = 4,
                    selectInput(
                        inputId = "scenarios_select_county",
                        label = "California Counties:",
                        choices = as.list(CA_counties),
                        selected = "Alameda"
                    ),
                    hr(),
                    HTML("<b>Vaccine uptake % (ages 12-15)</b>",.noWS = "outside"),
                    uiOutput("scenarios_young_uptake"),
                    HTML("<b>Vaccine uptake % (ages 16-64)</b>",.noWS = "outside"),
                    uiOutput("scenarios_middle_uptake"),
                    HTML("<b>Vaccine uptake % (ages 65+)</b>",.noWS = "outside"),
                    uiOutput("scenarios_elder_uptake"),
                    # numericInput("scenarios_young_uptake", "Vaccine uptake (ages 12-15)",value = 0.25,min = 0,max = 1),
                    sliderInput("scenarios_uk", "UK variant growth rate (%)",
                                min = 0,max = 1,value = 0),
                    sliderInput("scenarios_br", "BR variant growth rate (%)",
                                min = 0,max = 1,value = 0),
                    sliderInput("scenarios_reopen", "Reopening (%)",
                                min = 0.5,max = 1,value = 0.75),
                    sliderInput("scenarios_mrna_day", "Daily change in available doses (mRNA vaccines)",
                                min = -5e3,max = 5e3,value = 0,step=1e2),
                    sliderInput("scenarios_jj_day", "Daily change in available doses (J&J vaccine)",
                                min = -5e3,max = 5e3,value = 0,step=1e2),
                    hr(),
                    actionButton("scenarios_run", "Run Scenario", class = "btn btn-primary btn-lg btn-block"),
                    hr(),
                    downloadButton("scenarios_download_pdf_out", "Download PDF output"),
                    downloadButton("scenarios_download_xlsx_out", "Download Excel output")
                ),
                column(
                    width = 8,
                    includeMarkdown(path = "src/scenarios.md")
                )
            )
        ) # end scenarios tabpanel

    ) # end navbarpage 
) # end ui definition