#' Shiny haplotype analysis
#'
#' Shiny module for analysis based on haplotype alleles, with interface \code{shinyHaploUI}.
#'
#' @param input,output,session standard shiny arguments
#' @param win_par,pmap_obj,phe_mx,cov_df,K_chr,analyses_df,covar,pheno_data,analyses_tbl,peaks,project_info,allele_info reactive arguments
#' @param id shiny identifier
#'
#' @author Brian S Yandell, \email{brian.yandell@@wisc.edu}
#' @keywords utilities
#'
#' @export
#' @importFrom shiny callModule NS req 
#'   radioButtons
#'   textOutput uiOutput
#'   renderText renderUI
#'   mainPanel sidebarPanel strong tagList
shinyHaplo <- function(input, output, session,
                       win_par, pmap_obj, 
                       phe_mx, cov_df, K_chr, analyses_df, 
                       covar, pheno_data, analyses_tbl, peaks,
                       project_info, allele_info) {
  ns <- session$ns

  ## Genotype Probabilities.
  probs_obj <- shiny::callModule(shinyProbs, "probs", 
                          win_par, project_info)

  ## Genome Scan.
  shiny::callModule(shinyScanCoef, "hap_scan", 
             input, win_par, 
             phe_mx, cov_df, probs_obj, K_chr, analyses_df,
             project_info, allele_info)
  
  ## SNP Association
  patterns <- shiny::callModule(shinySNPSetup, "snp_setup",
              input, win_par, 
              phe_mx, cov_df, probs_obj, K_chr, analyses_df,
              project_info, allele_info)

  ## Mediation
  shiny::callModule(shinyMediate, "mediate",
                    input, win_par, patterns,
                    phe_mx, cov_df, probs_obj, K_chr, analyses_df,
                    pmap_obj, 
                    covar, pheno_data, analyses_tbl, peaks,
                    project_info, allele_info)

  output$allele_names <- shiny::renderText({
    shiny::req(allele_info())
    paste(allele_info()$code, allele_info()$shortname, sep = "=", collapse = ", ")
  })

  output$hap_input <- shiny::renderUI({
    switch(shiny::req(input$button),
           "Genome Scans"    = shinyScanCoefUI(ns("hap_scan")),
           "SNP Association" =,
           "Allele Pattern"  = shinySNPSetupUI(ns("snp_setup")),
           "Mediation"       = shinyMediateUI(ns("mediate")))
  })
  output$hap_output <- shiny::renderUI({
    switch(shiny::req(input$button),
           "Genome Scans"    = shinyScanCoefOutput(ns("hap_scan")),
           "SNP Association" = ,
           "Allele Pattern"  = shinySNPSetupOutput(ns("snp_setup")),
           "Mediation"       = shinyMediateOutput(ns("mediate")))
  })
  output$radio <- shiny::renderUI({
    shiny::radioButtons(ns("button"), "",
                 c("Genome Scans","SNP Association","Allele Pattern","Mediation"),
                 input$button)
  })
  output$sex_type <- shiny::renderUI({
    choices <- c("A","I","F","M","all")
    if(ncol(shiny::req(phe_mx())) > 1 & shiny::req(input$button) != "Mediation") {
      choices <- choices[1:4]
    }
    shiny::radioButtons(ns("sex_type"), "Sex:",
                        choices,
                        input$sex_type, inline = TRUE)
  })
  output$project <- shiny::renderUI({
    shiny::strong(shiny::req(paste("Project:",
                                   project_info()$project,
                                   "\n")))
  })
}
shinyHaploUI <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::sidebarPanel(
      shiny::uiOutput(ns("project")),
      shiny::strong("SNP/Gene Additive"),
      shiny::uiOutput(ns("radio")),
      shiny::uiOutput(ns("sex_type")),
      shiny::uiOutput(ns("hap_input")),
      shiny::textOutput(ns("allele_names"))),
    shiny::mainPanel(
      shiny::uiOutput(ns("hap_output")))
  )
}
