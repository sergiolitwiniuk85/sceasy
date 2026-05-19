#' Check if object is Seurat v5 or later
#' @param obj A Seurat object
#' @keywords internal
.is_seurat_v5 <- function(obj) {
  inherits(obj, "Seurat") && 
  requireNamespace("Seurat", quietly = TRUE) && 
  packageVersion("Seurat") >= "5.0.0"
}

#' Convert Assay5 to Assay class for compatibility
#' @param obj Seurat object (v5)
#' @keywords internal
.fix_seurat_v5_assays <- function(obj) {
  if (!.is_seurat_v5(obj)) return(obj)
  
  for (assay_name in Seurat::Assays(obj)) {
    assay_obj <- obj[[assay_name]]
    if (inherits(assay_obj, "Assay5")) {
      # Convert Assay5 to legacy Assay
      obj[[assay_name]] <- as(object = assay_obj, Class = "Assay")
    }
  }
  return(obj)
}
