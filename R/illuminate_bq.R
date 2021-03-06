#' Collect table from Alumni mirror
#'
#' @param table_name name of a table in illuminate
#' @param schema name of a table in illuminate schema that's
#' appended to the  dataset name (e.g., `public` for `illuminate_public`,
#' `dna` for `illuminate_dna`)
#' @param collect Whether to maintain data in BigQuery (`TRUE`) or to pull down
#' to your local environment (`FALSE`)
#'
#' @return a dataframe
#' @export

get_illuminate <- function(table_name,
                           schema = "dna_assessments",
                           collect = FALSE){



  dataset_name <- sprintf("illuminate_%s", schema)
  bq_dataset_name <- sprintf("bq_%s", dataset_name)
  #check if bq_illumiante exists; if not create it
  #connection_name <- sprintf("%s$con", bq_dataset_name)

  if (!exists(bq_dataset_name)) {
    connect_to_bq(dataset_name)
    bq_connection <- lazyeval::lazy_eval(bq_dataset_name, parent.frame())
  } else {
    bq_connection <- lazyeval::lazy_eval(bq_dataset_name, parent.frame())
    if (!DBI::dbIsValid(bq_connection)) {
      connect_to_bq(dataset_name)
    }
  }

  out <- dplyr::tbl(bq_connection, table_name)

  if (collect) {
    out <- dplyr::collect(out)
    names(out) <- tolower(names(out))
  }

  out

}
