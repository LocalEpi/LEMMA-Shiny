#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# library(shiny)

ui <- shiny::navbarPage(
    "LEMMA (Local Epidemic Modeling for Management and Action)",   
    tabPanel("Model Structure", 
             # includeMarkdown(path = normalizePath(path = paste0(path.package("LEMMA"),"/shiny/src/SEIRModel.md")))
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
                              # includeMarkdown(path = normalizePath(path = paste0(path.package("LEMMA"),"/shiny/src/excel_input.md")))
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
                              tableOutput("table")
                       )
                   )
               )
    ),
    # --------------------------------------------------------------------------------
    # navbar: something 1
    # --------------------------------------------------------------------------------
    tabPanel("debugging", 
             fluidRow(
                 tableOutput("files")
             )
    ),
    # --------------------------------------------------------------------------------
    # navbar: something 2
    # --------------------------------------------------------------------------------
    navbarMenu("subpanels", 
               tabPanel("panel 4a", "four-a"),
               tabPanel("panel 4b", "four-b"),
               tabPanel("panel 4c", "four-c")
    )
)

shinyUI(ui)

# # Define UI for application that draws a histogram
# shinyUI(fluidPage(
# 
#     # Application title
#     titlePanel("Old Faithful Geyser Data"),
# 
#     # Sidebar with a slider input for number of bins
#     sidebarLayout(
#         sidebarPanel(
#             sliderInput("bins",
#                         "Number of bins:",
#                         min = 1,
#                         max = 50,
#                         value = 30)
#         ),
# 
#         # Show a plot of the generated distribution
#         mainPanel(
#             plotOutput("distPlot"),
#             textOutput("textout")
#         )
#     )
# ))
