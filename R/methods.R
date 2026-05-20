#' Convert between data objects
#'
#' This function converts between data format frequently used to hold single
#' cell data
#'
#' @param obj Input Seurat object
#' @param from Format of input object, e.g. "anndata", "seurat", "sce", "loom",
#'   etc (str)
#' @param to Format of output object (str)
#' @param main_layer Required by some formats, may be "counts", "data",
#'   "scale.data", etc (str)
#'
#' @return Output object
#' Convert single-cell objects between formats
#'
#' @param obj Input object
#' @param from Source format ("anndata", "seurat", "sce", "loom")
#' @param to Target format ("anndata", "loom", "sce", "seurat", "cds")
#' @param outFile Output file path (required for some conversions)
#' @param main_layer Main data layer to use (e.g., "counts", "data")
#' @param ... Additional arguments passed to conversion functions
#' @return Converted object or writes to file
#' @export

convertFormat <- function(obj, from = c("anndata", "seurat", "sce", "loom"), to = c("anndata", "loom", "sce", "seurat", "cds"), outFile = NULL,
                          main_layer = NULL, ...) {
  from <- match.arg(from)
  to <- match.arg(to)

  # Seurat v5 compatibility guard
  if (from == "seurat") {
    if (requireNamespace("Seurat", quietly = TRUE) && 
        inherits(obj, "Seurat") && 
        utils::packageVersion("Seurat") >= "5.0.0") {
      has_assay5 <- any(vapply(Seurat::Assays(obj), function(nm) inherits(obj[[nm]], "Assay5"), logical(1)))
      if (has_assay5) {
        warning("Seurat v5 object detected. Converting assays to v4 compatibility mode for conversion. Original object unchanged.")
        for (assay_name in Seurat::Assays(obj)) {
          if (inherits(obj[[assay_name]], "Assay5")) {
            obj[[assay_name]] <- as(object = obj[[assay_name]], Class = "Assay")
          }
        }
      }
    }
  }

  converters <- list(
    seurat2anndata = seurat2anndata,
    seurat2sce     = seurat2sce,
    sce2anndata    = sce2anndata,
    sce2loom       = sce2loom,
    loom2anndata   = loom2anndata,
    loom2sce       = loom2sce,
    anndata2seurat = anndata2seurat,
    anndata2cds    = anndata2cds
  )

  key <- paste0(from, "2", to)
  func <- converters[[key]]
  if (is.null(func)) {
    stop(paste0('Unsupported conversion from "', from, '" to "', to, '"'), call. = FALSE)
  }

  func(obj, outFile = outFile, main_layer = main_layer, ...)
}
