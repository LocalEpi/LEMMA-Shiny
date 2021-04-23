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
        tabPanel("Model Structure", 
                 includeMarkdown(path = "src/SEIRModel.md")
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
                    width = 6,
                    shinyWidgets::multiInput(
                        inputId = "forecast_select_county", label = "California Counties:",
                        choices = CA_counties,
                        selected = "Alameda", width = "100%"
                    ),
                    actionButton(inputId = "forecast_select_county_selall",label = "Select all"),
                    actionButton(inputId = "forecast_select_county_sel0",label = "Select none"),
                    hr(),
                    actionButton("forecast_run", "Run Forecasts", class = "btn btn-primary btn-lg btn-block"),
                    hr(),
                    downloadButton("forecast_download_pdf_out", "Download PDF output"),
                    downloadButton("forecast_download_xlsx_out", "Download Excel output")
                ),
                column(
                    width = 6,
                    includeMarkdown(path = "src/forecasts.md")
                )
            )
        ),
        # --------------------------------------------------------------------------------
        # tabPanel: Scenarios
        # --------------------------------------------------------------------------------
        tabPanel(
            "Scenarios",
            includeMarkdown(path = "src/SEIRModel.md")
        )
        # # --------------------------------------------------------------------------------
        # # navbar: Forecasting
        # # --------------------------------------------------------------------------------
        # navbarMenu("Forecasts", 
        #            tabPanel("panel 4a", "four-a"),
        #            tabPanel("panel 4b", "four-b"),
        #            tabPanel("panel 4c", "four-c")
        # )
    )
)


# ui <- shiny::navbarPage(
#     "LEMMA (Local Epidemic Modeling for Management and Action)",   
#     tabPanel("Model Structure", 
#              # includeMarkdown(path = normalizePath(path = paste0(path.package("LEMMA"),"/shiny/src/SEIRModel.md")))
#              includeMarkdown(path = "src/SEIRModel.md")
#     ),
#     # --------------------------------------------------------------------------------
#     # navbar: Excel interface
#     # --------------------------------------------------------------------------------
#     navbarMenu("Excel Interface", 
#                # --------------------------------------------------------------------------------
#                # tabPanel: data input
#                # --------------------------------------------------------------------------------
#                tabPanel(
#                    title = "Data input", value = "xlsx-a",
#                    fluidRow(
#                        column(4,
#                               fileInput("upload", "Upload a spreadsheet"),
#                               textOutput("xlsx_check_txt"),
#                               br(),
#                               HTML(r"(<label class="control-label" id="upload-label" for="upload">Download template spreadsheet</label>)"),
#                               br(),
#                               downloadButton("download_template", "Download")
#                        ),
#                        column(8,
#                               includeMarkdown(path = "src/excel_input.md")
#                        )
#                    )
#                ),
#                # --------------------------------------------------------------------------------
#                # tabPanel: run LEMMA
#                # --------------------------------------------------------------------------------
#                tabPanel(
#                    title = "Run LEMMA",value =  "xlsx-b",
#                    fluidRow(
#                        column(4,
#                               actionButton("LEMMA_xlsx", "Run LEMMA", class = "btn btn-primary btn-lg btn-block"),
#                               hr(),
#                               downloadButton("download_pdf_out", "Download PDF output"),
#                               downloadButton("download_xlsx_out", "Download Excel output")
#                        ),
#                        column(8,
#                               includeMarkdown(path = "src/excel_output.md")
#                        )
#                    )
#                )
#     ),
#     # --------------------------------------------------------------------------------
#     # navbar: something 1
#     # --------------------------------------------------------------------------------
#     tabPanel("debugging", 
#              fluidRow(
#                  tableOutput("files")
#              )
#     ),
#     # --------------------------------------------------------------------------------
#     # navbar: something 2
#     # --------------------------------------------------------------------------------
#     navbarMenu("subpanels", 
#                tabPanel("panel 4a", "four-a"),
#                tabPanel("panel 4b", "four-b"),
#                tabPanel("panel 4c", "four-c")
#     )
# )
# 
# shinyUI(ui)