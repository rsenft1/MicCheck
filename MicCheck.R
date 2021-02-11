library(shiny)
library(stringr)
library(shinyjs)

# Read in our metadata file
Metadata = read.delim(
  "Metadata_new.txt",
  header = TRUE,
  stringsAsFactors = FALSE,
  quote = "",
  sep = "\t",
  na = ""
)
examples = read.delim(
  "examples_new.txt",
  header = TRUE,
  stringsAsFactors = FALSE,
  quote = "",
  sep = "\t",
  na = ""
)
#Get of Na values in the examples and replace them with a blank space
Nalist <- c("None","NONE", "NA", "N/A", "n/a","na", "No example")
for (i in 1:length(examples)){
  if (examples[i] %in% Nalist){
    examples[i] <- gsub(paste(Nalist, collapse = '|'), " ", examples[i])
  }
}
#examples <- gsub(paste(Nalist, collapse = '|'), " ", examples)
  

#For outputting checkboxes in app:
checkBox = "&#9744; "

#function for making the .tsv contents into checklist output:
appendChecklist <- function(input, myCol, showExamples) {
  output <- ""
  if(showExamples==TRUE){
    for (i in 1:length(myCol)) {
      output <- paste(output, checkBox, na.omit(Metadata[[myCol]]), "&nbsp; &nbsp;", "<em style=color:CornflowerBlue>", na.omit(examples[[myCol]]), "</em>", "<br>")
      #output <- append(output, paste(checkBox, na.omit(Metadata[[myCol]]), "&nbsp; &nbsp;", "<em style=color:CornflowerBlue>", na.omit(examples[[myCol]]), "</em>", "<br>"))
    }
  }
  else{
    for (i in 1:length(myCol)) {
      output <- paste(output, checkBox, na.omit(Metadata[[myCol]]), "<br>")
      #output <- append(output, paste(checkBox, na.omit(Metadata[[myCol]]), "<br>"))
    }
  }
  finalOutput <- append(input,output)
  return(str_replace_all(finalOutput,"\"",""))
}
checkNull <- function(input){
  if(!is.null(input)){
    return(input)
  }
  else{
    return("no_input")
  }
}
getModalityName <- function(input){
  if (!is.null(input)) {
    if (input == "WF") {
      scope = "Widefield"
    }
    else if (input == "SConfocal") {
      scope = "Spinning Disk Confocal"
    }
    else if (input == "PConfocal") {
      scope = "Laser-scanning Confocal"
    }
    else if (input == "MPhoton") {
      scope = "Multiphoton"
    }
    else{
      scope = "Microscope"
    }
  }
  return(scope)
}
sortItems <-function(str_list){
  sortedlist <- c()
  hold <- c()
  for(item in str_list){
    if(grepl("***", item, fixed=TRUE)){
      hold <- append(hold, item)
    }
    else{
      sortedlist <- append(sortedlist, item)
    }
  }
  return(append(sortedlist,hold))
}
#note: requires pander library, #install.packages(pander), (tinytex library) #install.packages("tinytex") #tinytex::install_tinytex()
# If your .tsv file is displaying with quotes around the text, this is likely something excel did. Copy paste into notepad and save again and it should work.
# Cannot use xelatex on shiny.io
#~~~~~~~~~~~~~~~~~
# User interface
#~~~~~~~~~~~~~~~~~
ui <- fluidPage(
  useShinyjs(),
  titlePanel("Microscopy Metadata Checklist Generator (MicCheck)"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("For more information, see Montero-Llopis et al., 2021."),
      ####################
      #Questions
      ####################
      # Q1: Modality
      radioButtons(
        "Q1",
        "1. Which image modality are you using?",
        c(
          "Widefield" = "WF",
          "Spinning Disk Confocal" = "SConfocal",
          "Point Scanning Confocal" = "PConfocal",
          "Multiphoton" = "MPhoton"
        ),
        selected = character(0)
      ),
      # Q1b: WF wheels/cubes
        checkboxGroupInput(
          "Q1b",
          "Did you use excitation/emission filter wheels or filter cubes?",
          choiceNames = list("Filter Wheel", "Filter Cube"),
          choiceValues = list("wheel", "cube"),
          selected=character(0)
        ),
      # Q1c: WF laser vs LED
      checkboxGroupInput(
        "Q1c",
        "What light source(s) did you use to illuminate your sample?",
        choiceNames = list("Non-laser light source (e.g., LED,  metal halide)", "Lasers"),
        choiceValues = list("LEDs", "Lasers"),
        selected=character(0)
      ),
      # Q2: Uni-meta-related
      radioButtons(
        "Q2",
        "2. Did you acquire transmitted light images (e.g., phase contrast, brightfield, DIC)?",
        c("Yes" = "Y",
          "No" = "N"),
        selected = character(0)
      ),
      radioButtons(
        "Q3",
        "3. Did you use additional magnification (e.g., optovar, relay lens)?",
        c("Yes" = "Y",
          "No" = "N"),
        selected = character(0)
      ),
      # Application-related
      checkboxGroupInput(
        "Q4",
        "4. Did you perform any of these multidimensional acquisitions?",
        choiceNames = list("Multi-color", "Z-stack", "Time-lapse"),
        choiceValues = list("multi-color", "z-stack", "time-lapse")
      ),
      radioButtons(
        "Q5",
        "5. Did you do a multi-point acquisition (e.g., revisiting different positions in a time-lapse)?",
        c("Yes" = "Y", "No" = "N"),
        selected = character(0)
      ),
      radioButtons(
        "Q6",
        "6. Did you do tiling, scan large area, or mosaic acquisition?",
        c("Yes" = "Y", "No" = "N"),
        selected = character(0)
      ),
      radioButtons(
        "Q7",
        "7. Did you do live cell imaging?",
        c("Yes" = "Y",
          "No, my sample is fixed" = "N"),
        selected = character(0)
      ),
      checkboxGroupInput(
        "Q8",
        "8. What kind of fluoropohore(s) did you use in your sample?",
        choiceNames = list("Fluorescent protein", "Fluorescent dye/organic dye"),
        choiceValues = list("FP", "Dye")
      ),
      radioButtons(
        "Q9",
        "9. Did you use any transfection reagents to express the fusion protein of interest in your sample?",
        c("Yes" = "Y", "No" = "N"),
        selected = character(0)
      ),
      radioButtons(
        "Q10",
        "10. Did you use use microscopes in a core facility?",
        c("Yes" = "Y", "No" = "N"),
        selected = character(0)
      ),
      helpText("App developed by Rebecca Senft (2021)."),
      width = 5
    ),
    ####################
    # Main Panel
    ####################
    mainPanel(
      #Styles:
      tags$head(tags$style("#newline{font-size: 10px;")),
      tags$head(
        tags$style(
          "#title{color: black;
                                 font-size: 20px;
                                 font-style: bold;
                                 text-align: center;
                                 }"
        )
      ),
     
      tags$head(
        tags$style(
          "#c1,#c2,#c3,#c4,#c5,#c5,#c6,#c7,#c8,#cModality{color: white;
                           font-style: bold;
                           background-color: black;
                           text-align: center;
                           }"
        )
      ),
      # Checklist output:
      htmlOutput("title"),
      #htmlOutput("newline"),
      helpText("***Asterisks indicate optional items."),
      textOutput("c1"),
      htmlOutput("Stand_motorized"),
      textOutput("cModality"),
      htmlOutput("nonWF_Stand_motorized"),
      textOutput("c2"),
      htmlOutput("Illumination"),
      textOutput("c3"),
      htmlOutput("WaveSelection"),
      textOutput("c4"),
      htmlOutput("Optics"),
      textOutput("c5"),
      htmlOutput("Detector"),
      textOutput("c6"),
      htmlOutput("Software"),
      textOutput("c7"),
      htmlOutput("SampleContent"),
      textOutput("c8"),
      htmlOutput("Acknowledgements"),
      htmlOutput("newline2"),
      downloadButton("download", "Download Checklist"),
      actionButton("myToggle", "Show Examples"),
      htmlOutput("newline3"),
      width = 7
    )
  )
)
#~~~~~~~~~~~~~~~~~
# Server side
#~~~~~~~~~~~~~~~~~
scope = "Microscope"
### Reactive observe toggle Examples
server <- function(input, output, session) {
  myToggle <- reactiveVal(FALSE)
  observeEvent(input$myToggle, {
    myToggle(!myToggle())
  })
### Reactive observe Q1 WF selection to display Q1b
  hide("Q1b",anim = FALSE)
  hide("Q1c",anim = FALSE)
  observeEvent(input$Q1, {
    if(checkNull(input$Q1=="WF")){
      show("Q1b", anim = TRUE)
      reset("Q1b")
      show("Q1c", anim=TRUE)
      reset
      output$cModality <- NULL
    }
    else if(checkNull(input$Q1)=="SConfocal"){
      hide("Q1b",anim = TRUE)
      show("Q1c", anim=TRUE)
      reset("Q1c")
      output$cModality <- renderText({
        paste0(getModalityName(input$Q1),"-Specific Hardware and Settings")
      })
      
    }
    else{
      hide("Q1b",anim = TRUE)
      hide("Q1c",anim = TRUE)
      output$cModality <- renderText({
        paste0(getModalityName(input$Q1),"-Specific Hardware and Settings")
      })
    }
  })
### Title generation  
  output$title <- renderUI({
    HTML(paste("Microscopy Metadata Checklist <br>"))
  })
  output$newline<- renderUI({
    HTML(paste("<br>"))
  
  })
  output$newline2<- renderUI({
    HTML(paste("<br>"))
  })
  output$newline3<- renderUI({
    HTML(paste("<br> <br>"))
  })
  output$c1 <- renderText({
    paste("Microscope Stand and Motorized Components")
  })
  output$c2 <- renderText({
    paste("Illumination")
  })
  output$c3 <- renderText({
    paste("Wavelength Selection")
  })
  output$c4 <- renderText({
    paste("Optics")
  })
  output$c5 <- renderText({
    paste("Detection")
  })
  output$c6 <- renderText({
    paste("Acquisition Software")
  })
  output$c7 <- renderText({
    paste("Sample Preparation")
  })
  output$c8 <- renderText({
    paste("Acknowledgements")
  })

#### Conditional checklist categories
  
  ##### Stand and Motorized Equipment
  
  output$Stand_motorized <- renderUI({
    all = ""
    all <- appendChecklist(all, "all_Stand", myToggle())
    if (length(input$Q4)>0 | checkNull(input$Q5)=="Y" | checkNull(input$Q6)=="Y"){
      all <-appendChecklist(all, "Zstack_multiPoint_timeLapse_Stand", myToggle()) 
    }
    if ("wheel" %in% checkNull(input$Q1b) | (checkNull(input$Q1)!="no_input" & checkNull(input$Q1)!="WF")){
      all <-appendChecklist(all, "emissionWheel_Stand", myToggle()) 
    }
    HTML(paste(sortItems(all)))
  })
  output$nonWF_Stand_motorized <- renderUI({
    all = ""
    if (checkNull(input$Q1)=="SConfocal") {
      all <-appendChecklist(all, "Sconfocal_Stand", myToggle()) 
    }
    if (checkNull(input$Q1)=="PConfocal") {
      all <-appendChecklist(all, "Pconfocal_Stand", myToggle()) 
    }
    if (checkNull(input$Q1)=="MPhoton") {
      all <-appendChecklist(all, "Mphoton_Stand", myToggle()) 
    }
    HTML(paste(sortItems(all)))
  })
  
  ##### Illumination
  
  output$Illumination <- renderUI({
    all = ""
    if (checkNull(input$Q1)=="WF" & "LEDs" %in% checkNull(input$Q1c)) {
        all <- appendChecklist(all, "WF_nolaser_Illumination", myToggle())
    }
    if (checkNull(input$Q1)=="WF" & "Lasers" %in% checkNull(input$Q1c)) {
      all <- appendChecklist(all, "WF_laser_Illumination", myToggle())
    } 
    if (checkNull(input$Q1)=="SConfocal" & "Lasers" %in% checkNull(input$Q1c)) {
      all <- appendChecklist(all, "Sconfocal_laser_Illumination", myToggle())
    } 
    if (checkNull(input$Q1)=="SConfocal" & "LEDs" %in% checkNull(input$Q1c)) {
      all <- appendChecklist(all, "Sconfocal_LED_Illumination", myToggle())
    } 
    if (checkNull(input$Q1)=="PConfocal") {
      all <- appendChecklist(all, "Pconfocal_Illumination", myToggle())
    }
    if (checkNull(input$Q1)=="MPhoton") {
      all <- appendChecklist(all, "Mphoton_Illumination", myToggle())
    }
    HTML(paste(sortItems(all)))
  })
  
  ##### Wavelength Selection
  
  output$WaveSelection <- renderUI({
    all = ""
    all <- appendChecklist(all, "All_Wave", myToggle())
    if (checkNull(input$Q1)=="WF" & "cube" %in% checkNull(input$Q1b)) {
      all <- appendChecklist(all, "WF_filterCube_Wave", myToggle())
    }
    HTML(paste(sortItems(all)))
  })
  
  ##### Optics
  
  output$Optics <- renderUI({
    all = ""
    all <- appendChecklist(all, "all_Optics", myToggle())
    if (checkNull(input$Q2)=="Y") {
      all <- appendChecklist(all, "transmitted_Optics", myToggle())
    }
    if (checkNull(input$Q3)=="Y") {
      all <- appendChecklist(all, "mag_Optics", myToggle())
    }
    HTML(paste(sortItems(all)))
  })
  
  ##### Detector
  
  output$Detector <- renderUI({
    all = ""
    if (checkNull(input$Q1)=="WF") {
      all <- appendChecklist(all, "WF_Detection", myToggle())
    }
    if (checkNull(input$Q1)=="SConfocal") {
      all <- appendChecklist(all, "Sconfocal_Detection", myToggle())
    }
    if (checkNull(input$Q1)=="PConfocal") {
      all <- appendChecklist(all, "Pconfocal_Detection", myToggle())
    }
    if (checkNull(input$Q1)=="MPhoton") {
      all <- appendChecklist(all, "Mphoton_Detection", myToggle())
    }
    HTML(paste(sortItems(all)))
  })
  
  ##### Software
  
  output$Software <- renderUI({
    all = ""
    all <- appendChecklist(all, "all_Software", myToggle())
    if (length(input$Q4)>0) {
      all <- appendChecklist(all, "multiDim_Software", myToggle())
    }
    if ("multi-color" %in% checkNull(input$Q4)) {
      all <- appendChecklist(all, "multiColor_Software", myToggle())
    }
    if ("z-stack" %in% checkNull(input$Q4)) {
      all <- appendChecklist(all, "Z_stack_Software", myToggle())
    }
    if ("time-lapse" %in% checkNull(input$Q4)) {
      all <- appendChecklist(all, "timeLapse_Software", myToggle())
    }
    if(checkNull(input$Q6)=="Y"){
      all <- appendChecklist(all, "tile_Software", myToggle())
    }
    HTML(paste(sortItems(all)))
  })
  
  ##### Sample-related
  
  output$SampleContent <- renderUI({
    all = ""
    all <- appendChecklist(all, "all_Sample", myToggle())
    if (checkNull(input$Q7)=="Y") {
      all <- appendChecklist(all, "live_Sample", myToggle())
    } 
    else if(checkNull(input$Q7)=="N"){
      all <- appendChecklist(all, "fixed_Sample", myToggle())
    }
    if ("FP" %in% checkNull(input$Q8)) {
      all <- appendChecklist(all, "FP_Sample", myToggle())
    }
    if ("Dye" %in% checkNull(input$Q8)) {
      all <- appendChecklist(all, "dye_Sample", myToggle())
    }
    if (checkNull(input$Q9)=="Y") {
      all <- appendChecklist(all, "transfect_Sample", myToggle())
    }
    HTML(paste(sortItems(all)))
  })
  
  ##### Acknowledgements
  
  output$Acknowledgements <- renderUI({
    all = ""
    if (checkNull(input$Q10)=="Y") {
      all <- appendChecklist(all, "core_Ack", myToggle())
    }
    HTML(paste(sortItems(all)))
  })
  #################
  # Download
  ################
  output$download = downloadHandler(
    filename = 'report.pdf',
    content = function(file) {
      params <- list(Metadata = Metadata, 
                     examples= examples,
                     modality = getModalityName(checkNull(input$Q1)),
                     Q1 = checkNull(input$Q1),
                     Q1b = checkNull(input$Q1b),
                     Q1c = checkNull(input$Q1c),
                     Q2 = checkNull(input$Q2),
                     Q3 = checkNull(input$Q3),
                     Q4 = checkNull(input$Q4),
                     Q5 = checkNull(input$Q5),
                     Q6 = checkNull(input$Q6),
                     Q7 = checkNull(input$Q7),
                     Q8 = checkNull(input$Q8),
                     Q9 = checkNull(input$Q9),
                     Q10 = checkNull(input$Q10),
                     showExamples=myToggle())
        src <- normalizePath('report.Rmd')
        src2 <- normalizePath('checkbox.png')
        # temporarily switch to the temp dir, in case you do not have write
        # permission to the current working directory
        owd <- setwd(tempdir())
        on.exit(setwd(owd))
        file.copy(src, 'report.Rmd', overwrite = TRUE)
        file.copy(src2, 'checkbox.png', overwrite = TRUE)
        
        id <- showNotification("Rendering checklist...",
                               duration = NULL,
                               closeButton = FALSE)
        on.exit(removeNotification(id), add = TRUE)
        
        library(rmarkdown)
        out <- render('report.Rmd', params=params, envir = new.env()) #add , pdf_document() here if you want default latex font
        file.rename(out, file)
    }
  )
}
shinyApp(ui = ui, server = server)
