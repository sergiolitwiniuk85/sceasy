# Helper functions for creating test Seurat objects

#' Create a minimal Seurat v4 object
#'
#' Creates a minimal Seurat object with 20 genes x 10 cells for testing.
#'
#' @return Seurat object
#' @keywords internal
.create_seurat_v4 <- function() {
  skip_if_not_installed("Seurat")

  # Create a simple count matrix (20 genes x 10 cells)
  counts <- Matrix::Matrix(
    matrix(
      rpois(20 * 10, lambda = 5),
      nrow = 20,
      ncol = 10
    ),
    sparse = TRUE
  )
  colnames(counts) <- paste0("cell_", 1:10)
  rownames(counts) <- paste0("gene_", 1:20)

  # Create Seurat object
  obj <- Seurat::CreateSeuratObject(counts = counts, project = "test")

  obj
}

#' Create a Seurat v5 object
#'
#' Creates a minimal Seurat object and forces it to use Assay5 if Seurat >= 5.0.0.
#'
#' @return Seurat object (v5 if Seurat >= 5.0.0)
#' @keywords internal
.create_seurat_v5 <- function() {
  skip_if_not_installed("Seurat")

  # Check if Seurat version is >= 5.0.0
  if (packageVersion("Seurat") < "5.0.0") {
    skip("Seurat version < 5.0.0, cannot create v5 object")
  }

  # Create a simple count matrix (20 genes x 10 cells)
  counts <- Matrix::Matrix(
    matrix(
      rpois(20 * 10, lambda = 5),
      nrow = 20,
      ncol = 10
    ),
    sparse = TRUE
  )
  colnames(counts) <- paste0("cell_", 1:10)
  rownames(counts) <- paste0("gene_", 1:20)

  # Create Seurat object
  obj <- Seurat::CreateSeuratObject(counts = counts, project = "test_v5")

  # Force RNA assay to be Assay5
  obj[["RNA"]] <- as(obj[["RNA"]], "Assay5")

  obj
}

#' Check if a Seurat object is a v5 object
#'
#' Determines whether a Seurat object is using Assay5 (Seurat v5 format).
#'
#' @param obj A Seurat object
#' @return TRUE if the object is a Seurat v5 object with Assay5, FALSE otherwise
#' @keywords internal
.is_seurat_v5_object <- function(obj) {
  if (!inherits(obj, "Seurat")) {
    return(FALSE)
  }

  if (!requireNamespace("Seurat", quietly = TRUE)) {
    return(FALSE)
  }

  if (packageVersion("Seurat") < "5.0.0") {
    return(FALSE)
  }

  # Check if any assay is an Assay5
  any(sapply(Seurat::Assays(obj), function(x) inherits(obj[[x]], "Assay5")))
}