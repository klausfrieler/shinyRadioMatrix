#' Creates a single row for radioMatrixInput
#'
#' @param rowID character string. Unique ID for the row. It should be unique within 
#'   a given 'radioMatrixInput', since it is used when identifying the value user
#'   has selected. It will be put into the \code{name} attribute of the
#'   corresponding \code{<tr>} tag, as well as in the \code{name} attributes of
#'   the radio button inputs in this row.
#' @param rowLLabel character string. A label displayed in the leftmost point of the row.
#' @param rowRLabel character string. A label displayed in the rightmost point of the row.
#' @param choiceNames,choiceValues List of names and values, respectively, that 
#'   are displayed to the user in the app and correspond to the each choice (for 
#'   this reason, the objects 'choiceNames' and 'choiceValues' must have the 
#'   same length). If either of these arguments is provided, then the other must 
#'   be provided and choices must not be provided. The advantage of using both of 
#'   these over a named list for choices is that the object 'choiceNames' allows 
#'   any type of UI object to be passed through (tag objects, icons, HTML code, 
#'   ...), instead of just simple text.
#' @param selected The initially selected values (if not specified then defaults 
#'   to \code{NULL}).
#' @param labelsWidth List of two valid values of CSS length unit. Each element 
#'   has to be a properly formatted CSS unit of length (e.g., (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}), specifying the minimum (first value) and 
#'   maximum (second value) width of the labels columns. The valid elements will 
#'   be written to the \code{style} attribute of the labels \code{td} tags.
#'
#' @return HTML markup for a table row with radio buttons inputs inside each
#'   cell
#'
#' @keywords internal
#'
#' @noRd
#'
generateRadioRow <- function(rowID, rowLLabel, rowRLabel, choiceNames, choiceValues,
                             selected = NULL, labelsWidth = list(NULL, NULL), 
                             RLabelStyle = NULL,
                             LLabelStyle = NULL,
                             choiceStyle = NULL, 
                             LLabPos = 0,
                             RLabPos = length(choiceNames)){
  row_name <- get_most_inner_child(rowID)
  row_dat <- mapply(choiceNames, choiceValues, FUN = function(name, value){

    inputTag <- shiny::tags$input(type = "radio", 
                                  name = row_name,
                                  title = value, # to provide tooltips with the value
                                  value = value)
    if (value %in% selected)
      inputTag$attribs$checked <- "checked"

    if(!is.null(choiceStyle)) shiny::tags$td(inputTag, style = choiceStyle) else shiny::tags$td(inputTag)
  }, SIMPLIFY = FALSE, USE.NAMES = FALSE)

  #browser()
  if(!is.null(labelsWidth[[1]])){
    LLabelStyle <- paste0(c(LLabelStyle, sprintf("min-width:%s", labelsWidth[[1]])), collapse = ";")
  }
  llab <- if (is.null(LLabelStyle)) shiny::tags$td(rowLLabel) else shiny::tags$td(rowLLabel, style = LLabelStyle)
  
  if(!is.null(labelsWidth[[2]])){
    RLabelStyle <- paste0(c(RLabelStyle, sprintf("min-width:%s;text-align:left", labelsWidth[[2]])), collapse = ";")
  }
  rlab <- if (!is.null(rowRLabel)) if (is.null(RLabelStyle)) shiny::tags$td(rowRLabel) else shiny::tags$td(rowRLabel, style = RLabelStyle)
  
  # row_dat <- list(shiny::tags$td(rowID),
  #                 if (is.null(LLabelStyle)) shiny::tags$td(rowLLabel) else shiny::tags$td(rowLLabel, style = LLabelStyle),
  #                 row_dat,
  #                 if (!is.null(rowRLabel)) if (is.null(RLabelStyle)) shiny::tags$td(rowRLabel) else shiny::tags$td(rowRLabel, style = RLabelStyle)
  # )
  l <- length(row_dat)
  LLabPos <- max(min(LLabPos, l), 0)
  row_dat <- append(row_dat, list(llab), LLabPos)
  l <- length(row_dat)
  RLabPos <- max(min(RLabPos, l), 0)
  row_dat <- append(row_dat, list(rlab), RLabPos)
  
  shiny::tags$tr(name = row_name,
                 class = "shiny-radiomatrix-row", # used for CSS styling
                 list(shiny::tags$td(rowID), 
                      row_dat))
}


#' Generate the header row of radioMatrixInput
#'
#' @param choiceNames character. Names displayed on top of the assignment matrix.
#' @param rowLLabels character. Vector (or a matrix with one column) of labels that 
#'   displayed in the leftmost point of each row. The column name of the matrix 
#'   could be displayed in the header of the assignment matrix.
#' @param rowRLabels character. Vector (or a matrix with one column) of labels that 
#'   displayed in the rightmost point of each row. The column name of the matrix 
#'   could be displayed in the header of the assignment matrix. Using this argument 
#'   is optional. But it allows to create Likert scales, potentially with several 
#'   scales arranged in a matrix.
#' @param rowIDsName single character that defines the header of the ID column in the
#'   input matrix.
#'   
#' @return HTML markup for the header table row
#'
#' @keywords internal
#'
#' @noRd
#'
generateRadioMatrixHeader <- function(choiceNames, 
                                      rowLLabels, 
                                      rowRLabels,
                                      rowIDsName, 
                                      LLabPos = 0,
                                      RLabPos = length(choiceNames) + 1){
  #browser()
  if(!is.null(rowRLabels)){
    rRName <- ifelse(is.matrix(rowRLabels), colnames(rowRLabels), "")
    rLName <- ifelse(is.matrix(rowLLabels), colnames(rowLLabels), "")
    header <- lapply(c(rowIDsName, rLName, choiceNames, rRName),
                     function(n){ shiny::tags$td(n)})
  } else {
    rLName <- ifelse(is.matrix(rowLLabels), colnames(rowLLabels), "")
    header <- lapply(c(rowIDsName, rLName, choiceNames),
                     function(n){ shiny::tags$td(n)})
  }
  header <- move_elements(header, from = c(2, length(header)), to = c(LLabPos + 2, RLabPos + 2))
  shiny::tags$tr(header)
}

move_elements <- function(vec_or_list, from, to){
  v <- vec_or_list
  l <- length(v)
  #browser()
  # print(sprintf("Entering with from = %s, to = %s", paste(from, collapse = ", "), paste(to, collapse = ", ")))
  if(length(from) != length(to)){
    stop(sprintf("Length of start and end position do not match"))
  }
  if(length(from) > 1){
    for(i in seq_along(from)){
      v <- move_elements(v, from[i], to[i])  
      #print(sprintf("New v: %s", paste(unlist(v), collapse = " ")))
    } 
    return(v)
  }
  if(l == 0) return(v)
  if(from < 1 || from > l){
    return(v)
    #stop(sprintf("Invalid start position: %s", paste(from, collapse = "")))
  }
  if(to < 1){
    to <- 1
  }
  if (to > l){
    #remove from list
    to <- l
  }
  if(from == to) return(v)
  if(from > to) {
    to <- to - 1
  }
  idz <- as.list(1:length(v))
  idz <- append(idz, idz[[from]], to)
  if(from > to + 1) {
    from <- from + 1
  }
  #browser()
  idz[[from]] <- NULL
  v[unlist(idz)]
}

get_most_inner_child <- function(shiny_tag){
  ch <- shiny_tag$children
  while(length(ch$children)) ch <- ch$children
  as.character(unname(unlist(ch)))
}
#' Generate complete HTML markup for radioMatrixInput
#'
#' @param inputId The input slot that will be used to access the value.
#' @param rowIDs character. Vector of row identifiers that will be used to find
#'   values that the user has selected. In the output, the component will return
#'   a named list of values, each name corresponding to the row id, and the
#'   value - to the value user has selected in this row.
#' @param rowLLabels character. Vector (or a matrix with one column) of labels that 
#'   displayed in the leftmost point of each row. The column name of the matrix 
#'   could be displayed in the header of the assignment matrix.
#' @param rowRLabels character. Vector (or a matrix with one column) of labels that 
#'   displayed in the rightmost point of each row. The column name of the matrix 
#'   could be displayed in the header of the assignment matrix. Using this argument 
#'   is optional. But it allows to create Likert scales, potentially with several 
#'   scales arranged in a matrix.
#' @param selected Vector of the initially selected values (if not specified then 
#'   defaults to \code{NULL}).
#' @param rowIDsName single character that defines the header of the ID column in the
#'   input matrix.
#' @param choiceNames,choiceValues List of names and values, respectively, that 
#'   are displayed to the user in the app and correspond to the each choice (for 
#'   this reason, the objects 'choiceNames' and 'choiceValues' must have the 
#'   same length). If either of these arguments is provided, then the other must 
#'   be provided and choices must not be provided. The advantage of using both of 
#'   these over a named list for choices is that the object 'choiceNames' allows 
#'   any type of UI object to be passed through (tag objects, icons, HTML code, 
#'   ...), instead of just simple text.
#' @param labelsWidth List of two valid values of CSS length unit. Each element 
#'   has to be a properly formatted CSS unit of length (e.g., (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}), specifying the minimum (first value) and 
#'   maximum (second value) width of the labels columns. The valid elements will 
#'   be written to the \code{style} attribute of the labels \code{td} tags.
#' @param session copied from \code{shiny:::generateOptions}
#'
#' @keywords internal
#'
#' @noRd
#'
generateRadioMatrix <- function (inputId, 
                                 rowIDs, 
                                 rowLLabels, 
                                 rowRLabels = NULL,
                                 choiceNames = NULL, 
                                 choiceValues = NULL,
                                 selected = NULL,
                                 rowIDsName = "ID",
                                 labelsWidth = list(NULL, NULL),
                                 LLabelStyle = NULL,
                                 RLabelStyle = NULL,
                                 choiceStyle = NULL,
                                 LLabPos = 0,
                                 RLabPos = length(choiceNames),                                 
                                 session = shiny::getDefaultReactiveDomain()){
  header <- generateRadioMatrixHeader(choiceNames, rowLLabels, rowRLabels, rowIDsName, LLabPos = LLabPos, RLabPos = RLabPos)
  rows <- lapply(1:length(rowIDs), function(i){
    generateRadioRow(
      rowID = rowIDs[[i]], 
      rowLLabel = rowLLabels[[i]], 
      rowRLabel = rowRLabels[[i]],
      choiceNames = choiceNames, 
      choiceValues = choiceValues,
      selected = if (is.null(selected)) selected else selected[[i]],
      labelsWidth = labelsWidth,
      LLabelStyle = LLabelStyle,
      RLabelStyle = RLabelStyle,
      choiceStyle = choiceStyle,
      LLabPos = LLabPos,
      RLabPos = RLabPos
    )
  })

  table <- shiny::tags$table(header, rows)

  shiny::div(class = "shiny-radiomatrix", table)
}

#' @param inputId The input slot that will be used to access the value.
#' @param rowIDs character. Vector of row identifiers that will be used to find
#'   values that the user has selected. In the output, the component will return
#'   a named list of values, each name corresponding to the row id, and the
#'   value - to the value user has selected in this row.
#' @param rowLLabels character. Vector (or a matrix with one column) of labels that 
#'   displayed in the leftmost point of each row. The column name of the matrix 
#'   could be displayed in the header of the assignment matrix.
#' @param rowRLabels character. Vector (or a matrix with one column) of labels that 
#'   displayed in the rightmost point of each row. The column name of the matrix 
#'   could be displayed in the header of the assignment matrix. Using this argument 
#'   is optional. But it allows to create Likert scales, potentially with several 
#'   scales arranged in a matrix.
#' @param choices List of values to select from (if elements of the list are
#'   named then that name rather than the value is displayed to the user). If
#'   this argument is provided, then choiceNames and choiceValues must not be
#'   provided, and vice-versa. The values should be strings; other types (such
#'   as logicals and numbers) will be coerced to strings.
#' @param selected Vector of the initially selected values (if not specified then 
#'   defaults to \code{NULL}).
#' @param choiceNames,choiceValues List of names and values, respectively, that 
#'   are displayed to the user in the app and correspond to the each choice (for 
#'   this reason, the objects 'choiceNames' and 'choiceValues' must have the 
#'   same length). If either of these arguments is provided, then the other must 
#'   be provided and choices must not be provided. The advantage of using both of 
#'   these over a named list for choices is that the object 'choiceNames' allows 
#'   any type of UI object to be passed through (tag objects, icons, HTML code, 
#'   ...), instead of just simple text.
#' @param rowIDsName single character that defines the header of the ID column in the
#'   input matrix.
#' @param labelsWidth List of two valid values of CSS length unit. Each element 
#'   has to be a properly formatted CSS unit of length (e.g., (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}), specifying the minimum (first value) and 
#'   maximum (second value) width of the labels columns. The valid elements will 
#'   be written to the \code{style} attribute of the labels \code{td} tags.
#'
#' @keywords internal
#'
#' @noRd
#'
validateParams <- function(rowIDs, 
                           rowLLabels, 
                           rowRLabels, 
                           selected, 
                           choiceNames, 
                           rowIDsName, 
                           labelsWidth){

  cv.inv <- ifelse(!is.null(rowRLabels), c("rowLLabels", "rowRLabels"), c("rowLLabels"))
  for (i_i in 1 : length(cv.inv)){
    if (!any((length(get(cv.inv[i_i])) >= 1 && !is.list(get(cv.inv[i_i]))),
             (length(dim(get(cv.inv[i_i]))) == 2 && dim(get(cv.inv[i_i]))[2L] == 1))) {
      stop("'", cv.inv[i_i], "' must be a a vector or a matrix with at least one column.")
    }
  }

  if (length(dim(rowLLabels)) == 2 && dim(rowLLabels)[2L] == 1) {
    rowLLabels <- array(t(rowLLabels))
  }

  if (length(dim(rowRLabels)) == 2 && dim(rowRLabels)[2L] == 1) {
    rowRLabels <- array(t(rowRLabels))
  }

  if (!is.null(rowRLabels) & !is.null(selected)) {
    checks <- list(rowIDs, rowLLabels, rowRLabels, selected)
  } else {
    if (is.null(rowRLabels) & is.null(selected)) {
      checks <- list(rowIDs, rowLLabels)
    } else {
      if (!is.null(rowRLabels)) {
        checks <- list(rowIDs, rowLLabels, rowRLabels)
      } else {
        checks <- list(rowIDs, rowLLabels, selected)
      }
    }
  }

  lengths <- sapply(checks, length)

  if (length(unique(lengths)) > 1) {
    stop("All elements of the object 'rowIDs', 'rowLabels' and 'selected' must be ", 
         "of the same length!")
  }

  if (length(rowIDs) < 1 ){
    stop("The assignment matrix should contain at least one row. ", 
         "The object 'rowIDs' has to be a vector with at least one element.")
  }

  if(length(unique(rowIDs)) < length(rowIDs)){
    stop(paste("Some elements of the object 'rowIDs' are not unique. ",
               "The following values are duplicated:", rowIDs[duplicated(rowIDs)]), ".")
  }

  if (length(choiceNames) < 1){
    stop("There should be at least one columns in the assignment matrix. ",
         "The object 'choiceNames' has to be a vector with at least one element.")
  }

  if (length(labelsWidth) != 2){
    stop("The object 'labelsWidth' must be a list or vector with two elements.")
  }
  
  if (!(is.character(rowIDsName) && length(rowIDsName) == 1)){
    stop("The object 'rowIDsName' must be a character with a single element.")
  }

  pattern <-
    "^(auto|inherit|calc\\(.*\\)|((\\.\\d+)|(\\d+(\\.\\d+)?))(%|in|cm|mm|ch|em|ex|rem|pt|pc|px|vh|vw|vmin|vmax))$"
  
  is.cssu <- function(x) (is.character(x) && grepl(pattern, x))
  lwNull <- sapply(labelsWidth, is.null)
  lwCssU <- sapply(labelsWidth, is.cssu)
  lwTest <- !(lwNull | lwCssU)
  if (any(lwTest)){
    stop("The object 'labelsWidth' can only contain NULLs or ", 
         "properly formatted CSS units of length!")
  }

}


#' Create radioMatrixInput
#'
#' @param inputId The input slot that will be used to access the value.
#' @param rowIDs character. Vector of row identifiers that will be used to find
#'   values that the user has selected. In the output, the component will return
#'   a named list of values, each name corresponding to the row id, and the
#'   value - to the value user has selected in this row.
#' @param rowLLabels character. Vector (or a matrix with one column) of labels that 
#'   displayed in the leftmost point of each row. The column name of the matrix 
#'   could be displayed in the header of the assignment matrix.
#' @param rowRLabels character. Vector (or a matrix with one column) of labels that 
#'   displayed in the rightmost point of each row. The column name of the matrix 
#'   could be displayed in the header of the assignment matrix. Using this argument 
#'   is optional. But it allows to create Likert scales, potentially with several 
#'   scales arranged in a matrix.
#' @param choices List of values to select from (if elements of the list are
#'   named then that name rather than the value is displayed to the user). If
#'   this argument is provided, then choiceNames and choiceValues must not be
#'   provided, and vice-versa. The values should be strings; other types (such
#'   as logicals and numbers) will be coerced to strings.
#' @param selected Vector of the initially selected values (if not specified then 
#'   defaults to \code{NULL}).
#' @param choiceNames,choiceValues List of names and values, respectively, that 
#'   are displayed to the user in the app and correspond to the each choice (for 
#'   this reason, the objects 'choiceNames' and 'choiceValues' must have the 
#'   same length). If either of these arguments is provided, then the other must 
#'   be provided and choices must not be provided. The advantage of using both of 
#'   these over a named list for choices is that the object 'choiceNames' allows 
#'   any type of UI object to be passed through (tag objects, icons, HTML code, 
#'   ...), instead of just simple text.
#' @param rowIDsName single character that defines the header of the ID column in the
#'   input matrix.
#' @param labelsWidth List of two valid values of CSS length unit. Each element 
#'   has to be a properly formatted CSS unit of length (e.g., \code{'10\%'},
#'   \code{'40px'}, \code{'auto'}), specifying the minimum (first value) and 
#'   maximum (second value) width of the labels columns. The valid elements will 
#'   be written to the \code{style} attribute of the labels \code{td} tags.
#'
#' @return HTML markup for radioMatrixInput
#'
#' @examples
#' library(shiny)
#' library(shinyRadioMatrix)
#'
#'
#' ## Only run examples in interactive R sessions
#' if (interactive()) {
#'
#'   data(exTaxonList)
#'   data(exPftList)
#'
#'   ui <- fluidPage(
#'     radioMatrixInput(inputId = "rmi01", rowIDs = head(exTaxonList$Var),
#'            rowLLabels = head(as.matrix(subset(exTaxonList, select = "VarName"))),
#'            choices = exPftList$ID,
#'            selected = head(exTaxonList$DefPFT)),
#'     verbatimTextOutput('debug01')
#'   )
#'
#'   server <- function(input, output, session) {
#'     output$debug01 <- renderPrint({input$rmi01})
#'   }
#'
#'   shinyApp(ui, server)
#' }
#' 
#' if (interactive()) {
#'
#'   ui <- fluidPage(
#'
#'     radioMatrixInput(inputId = "rmi02", rowIDs = c("Performance", "Statement A"),
#'                      rowLLabels = c("Poor", "Agree"),
#'                      rowRLabels = c("Excellent", "Disagree"),
#'                      choices = 1:5,
#'                      selected = rep(3, 2),
#'                      rowIDsName = "Grade",
#'                      labelsWidth = list("100px", "100px")),
#'     verbatimTextOutput('debug02')
#'   )
#'
#'   server <- function(input, output, session) {
#'     output$debug02 <- renderPrint({input$rmi02})
#'   }
#'
#'   shinyApp(ui, server)
#'
#' }
#' 
#' @export
#'
radioMatrixInput <- function(inputId, 
                             rowIDs, 
                             rowLLabels, 
                             rowRLabels = NULL, 
                             choices = NULL,
                             selected = NULL, 
                             choiceNames = NULL, 
                             choiceValues = NULL,
                             rowIDsName = "ID",
                             labelsWidth = list(NULL, NULL),
                             LLabelStyle = NULL,
                             RLabelStyle = NULL,
                             choiceStyle = NULL,
                             LLabPos = 0,
                             RLabPos = length(choiceNames)) {

  # check the inputs
  args <- eval(parse(text = "shiny:::normalizeChoicesArgs(choices, choiceNames, choiceValues)"))
  selected <- eval(parse(text = "shiny::restoreInput(id = inputId, default = selected)"))
  labelsWidth <- as.list(labelsWidth)
  validateParams(rowIDs, rowLLabels, rowRLabels, selected, args$choiceNames, rowIDsName, labelsWidth)

  # generate the HTML for the controller itself
  radiomatrix <- generateRadioMatrix(
    inputId = inputId, 
    rowIDs = rowIDs,
    rowLLabels = rowLLabels, 
    rowRLabels = rowRLabels,
    selected = selected,
    choiceNames = args$choiceNames, 
    choiceValues = args$choiceValues,
    rowIDsName = rowIDsName,
    labelsWidth = labelsWidth,
    LLabelStyle = LLabelStyle,
    RLabelStyle = RLabelStyle,
    choiceStyle = choiceStyle,
    LLabPos = LLabPos,
    RLabPos = RLabPos
  )

  divClass <- "form-group shiny-radiomatrix-container dataTable-container"

  # Make sure that the js and css files are locatable
  shiny::addResourcePath("radiomatrix", system.file(package="shinyRadioMatrix"))

  shiny::tagList(
    shiny::tags$head(
      shiny::singleton(shiny::tags$script(src = "radiomatrix/inputRadioMatrixBinding.js")),
      shiny::singleton(shiny::tags$link(rel = "stylesheet", type = "text/css",
                                        href = "radiomatrix/inputRadioMatrixCss.css"))

    ),

    shiny::tags$div(
      id = inputId,
      class = divClass,
      radiomatrix
    )
  )
}
