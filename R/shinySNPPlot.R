#' Shiny scan1 SNP analysis and plot module
#'
#' Shiny module for scan1 analysis and plots, with interfaces \code{shinySNPPlotUI} and  \code{shinySNPPlotOutput}.
#'
#' @param input,output,session standard shiny arguments
#' @param snp_par,chr_pos,pheno_names,snp_scan_obj,snpinfo,snp_action reactive arguments
#' @param id shiny identifier
#'
#' @author Brian S Yandell, \email{brian.yandell@@wisc.edu}
#' @keywords utilities
#'
#' @export
#' @importFrom shiny NS reactive req 
#'   plotOutput
#'   renderPlot
#'   withProgress setProgress
#'   downloadButton downloadHandler
shinySNPPlot <- function(input, output, session,
                          snp_par, chr_pos, pheno_names,
                          snp_scan_obj, snpinfo,
                          snp_action = shiny::reactive({"basic"})) {
  ns <- session$ns
  
  output$snpPlot <- shiny::renderPlot({
    if(!shiny::isTruthy(snp_par$scan_window) || !shiny::isTruthy(pheno_names()))
      return(plot_null("need to select\nRegion & Phenotype"))
    
    if(is.null(snp_scan_obj()) |
       is.null(snp_par$scan_window) | is.null(snp_action()) |
       is.null(snpinfo()) | is.null(snp_par$minLOD))
      return(plot_null())
    shiny::withProgress(message = 'SNP plots ...', value = 0, {
      shiny::setProgress(1)
    top_snp_asso(snp_scan_obj(), snpinfo(),
                 snp_par$scan_window, snp_action(), 
                 minLOD = snp_par$minLOD)
    })
  })
  
  output$downloadPlot <- shiny::downloadHandler(
    filename = function() {
      file.path(paste0("snp_scan_", chr_pos(), "_", snp_action(), ".pdf")) },
    content = function(file) {
      pdf(file, width = 9)
      print(top_snp_asso(shiny::req(snp_scan_obj()), 
                         shiny::req(snpinfo()), 
                         shiny::req(snp_par$scan_window),
                         snp_action(), 
                         minLOD = shiny::req(snp_par$minLOD)))
      dev.off()
    }
  )
}
shinySNPPlotUI <- function(id) {
  ns <- shiny::NS(id)
  shiny::downloadButton(ns("downloadPlot"), "Plots")
}
shinySNPPlotOutput <- function(id) {
  ns <- shiny::NS(id)
  shiny::plotOutput(ns("snpPlot"))
}
