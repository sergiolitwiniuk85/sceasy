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

  # Kaizen: Seurat v5 assay compatibility fix
  if (from == "seurat") {
    # Internal helper functions for Seurat v5 detection and conversion
    .is_seurat_v5 <- function(obj) {
      inherits(obj, "Seurat") && 
      requireNamespace("Seurat", quietly = TRUE) && 
      utils::packageVersion("Seurat") >= "5.0.0"
    }
    
    .fix_seurat_v5_assays <- function(obj) {
      if (!.is_seurat_v5(obj)) return(obj)
      
      for (assay_name in Seurat::Assays(obj)) {
        assay_obj <- obj[[assay_name]]
        if (inherits(assay_obj, "Assay5")) {
          # Convert Assay5 to legacy Assay class
          # Try different methods for compatibility across Seurat versions
          tryCatch({
            # Method 1: Direct coercion
            obj[[assay_name]] <- as(object = assay_obj, Class = "Assay")
          }, error = function(e1) {
            tryCatch({
              # Method 2: Using as.Assay
              obj[[assay_name]] <- Seurat::as.Assay(assay_obj)
            }, error = function(e2) {
              # Method 3: Create new assay from slots (fallback)
#              counts_slot <- tryCatch(Seurat::GetAssayData(assay_obj, slot = "counts"), error = function(e) NULL)
#              data_slot <- tryCatch(Seurat::GetAssayData(assay_obj, slot = "data"), error = function(e) NULL)
#              scale_slot <- tryCatch(Seurat::GetAssayData(assay_obj, slot = "scale.data"), error = function(e) NULL)
              if (packageVersion("Seurat") >= "5.0.0") {
                counts_slot <- tryCatch(Seurat::GetAssayData(assay_obj, layer = "counts"), error = function(e) NULL)
                data_slot <- tryCatch(Seurat::GetAssayData(assay_obj, layer = "data"), error = function(e) NULL)
                scale_slot <- tryCatch(Seurat::GetAssayData(assay_obj, layer = "scale.data"), error = function(e) NULL)
                     } else {
                counts_slot <- tryCatch(Seurat::GetAssayData(assay_obj, slot = "counts"), error = function(e) NULL)
                data_slot <- tryCatch(Seurat::GetAssayData(assay_obj, slot = "data"), error = function(e) NULL)
                scale_slot <- tryCatch(Seurat::GetAssayData(assay_obj, slot = "scale.data"), error = function(e) NULL)
              }       
                
              new_assay <- Seurat::CreateAssayObject(counts = counts_slot)
              if (!is.null(data_slot)) {
                new_assay <- Seurat::SetAssayData(new_assay, slot = "data", new.data = data_slot)
              }
              if (!is.null(scale_slot)) {
                new_assay <- Seurat::SetAssayData(new_assay, slot = "scale.data", new.data = scale_slot)
              }
              obj[[assay_name]] <- new_assay
            })
          })
        }
      }
      return(obj)
    }
    
    # Apply fix if object is Seurat v5
    if (.is_seurat_v5(obj)) {
      warning("Seurat v5 object detected. Converting assays to v4 compatibility mode for conversion. Original object unchanged.")
      obj <- .fix_seurat_v5_assays(obj)
    }
  }

  tryCatch(
    {
      func <- eval(parse(text = paste(from, to, sep = "2")))
    },
    error = function(e) {
      stop(paste0('Unsupported conversion from "', from, '" to "', to, '"'), call. = FALSE)
    },
    finally = {}
  )

  return(func(obj, outFile = outFile, main_layer = main_layer, ...))
}
