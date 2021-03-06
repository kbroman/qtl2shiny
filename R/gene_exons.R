gene_exons <- function(tops, project_info) {
  
  query_genes <- read_query_rds(project_info, "query_genes.rds")

  chr_id <- as.character(unique(tops$chr))
  range_Mbp <- range(tops$pos) + c(-1,1) * 0.005
  
  feature_tbl <- query_genes(chr_id, range_Mbp[1], range_Mbp[2])
  qtl2pattern::get_gene_exon_snp(tops, feature_tbl)
}