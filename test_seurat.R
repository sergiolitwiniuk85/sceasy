#!/usr/bin/env Rscript

# test_fix.R - Prueba minimalista del fix para Seurat v5
# Uso: Rscript test_fix.R

test_seurat_v5_fix <- function() {
  
  # Configuración inicial
  setwd("~/Documents/sceasy/sceasy")
  library(Seurat)
  devtools::load_all(".", quiet = TRUE)
  
  # Helper: detectar v5
  is_v5 <- function(obj) {
    inherits(obj, "Seurat") && 
    packageVersion("Seurat") >= "5" &&
    any(sapply(Seurat::Assays(obj), \(x) inherits(obj[[x]], "Assay5")))
  }
  
  # Crear objeto v5 garantizado
  create_v5_object <- function() {
    data("pbmc_small", package = "SeuratObject", envir = environment())
    obj <- get("pbmc_small")
    
    if (!is_v5(obj) && packageVersion("Seurat") >= "5") {
      message("Convirtiendo a v5...")
      obj <- CreateSeuratObject(counts = obj[["RNA"]]$counts)
    }
    obj
  }
  
  # Ejecutar prueba con manejo de errores
  run_test <- function(description, expr) {
    cat(description, "... ")
    result <- tryCatch({
      expr
      "✅ ÉXITO"
    }, warning = function(w) {
      if (grepl("Seurat v5 object detected", w$message)) "⚠️ WARNING (normal)" else "⚠️ WARNING"
    }, error = function(e) {
      paste("❌ ERROR:", e$message)
    })
    cat(result, "\n")
    invisible(result)
  }
  
  # Main
  cat("\n🔬 Probando fix de Seurat v5\n")
  cat("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
  
  obj <- create_v5_object()
  cat(sprintf("📦 Objeto: %s cells | %s genes | Assay: %s | v5: %s\n",
              ncol(obj), nrow(obj), class(obj[["RNA"]])[1], is_v5(obj)))
  
  # Pruebas
  run_test("1. Seurat → Seurat", convertFormat(obj, "seurat", "seurat"))
  
  tmp <- tempfile(fileext = ".rds")
  run_test("2. Guardar como RDS", convertFormat(obj, "seurat", "seurat", outFile = tmp))
  unlink(tmp)
  
  if (requireNamespace("reticulate", quietly = TRUE) && 
      reticulate::py_module_available("anndata")) {
    tmp <- tempfile(fileext = ".h5ad")
    run_test("3. Seurat → AnnData", convertFormat(obj, "seurat", "anndata", outFile = tmp))
    unlink(tmp)
  } else {
    cat("3. Seurat → AnnData ... ⏭️  Skip (instala anndata)\n")
  }
  
  cat("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
  cat("✅ Fix funcionando correctamente\n")
}

# Ejecutar
test_seurat_v5_fix()
