# Helper functions for creating temporary file paths

#' Get temporary h5ad file path
#'
#' Creates a temporary file path with .h5ad extension.
#'
#' @return Character path to a temporary h5ad file
#' @keywords internal
.temp_h5ad_path <- function() {
  tempfile(fileext = ".h5ad")
}

#' Get temporary rds file path
#'
#' Creates a temporary file path with .rds extension.
#'
#' @return Character path to a temporary rds file
#' @keywords internal
.temp_rds_path <- function() {
  tempfile(fileext = ".rds")
}

#' Get temporary loom file path
#'
#' Creates a temporary file path with .loom extension.
#'
#' @return Character path to a temporary loom file
#' @keywords internal
.temp_loom_path <- function() {
  tempfile(fileext = ".loom")
}