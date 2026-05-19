#!/usr/bin/env Rscript

cat("========================================\n")
cat("Testing Seurat v5 with LOCAL sceasy\n")
cat("========================================\n\n")

# 1. Establecer directorio (CAMBIA ESTO SI ES NECESARIO)
setwd("~/Documents/sceasy/sceasy")
cat("Working directory:", getwd(), "\n\n")

# 2. Verificar que exista la estructura de sceasy
if (!dir.exists("R")) {
  stop("ERROR: No encuentro la carpeta R/. ¿Estás en el directorio correcto?")
}
cat("✓ Estructura de sceasy encontrada\n")

# 3. Instalar/cargar Seurat
if (!require(Seurat, quietly = TRUE)) {
  cat("Instalando Seurat...\n")
  install.packages("Seurat", repos = "https://cloud.r-project.org")
  library(Seurat)
}
cat("✓ Seurat version:", as.character(packageVersion("Seurat")), "\n")

# 4. Instalar devtools si no está (solo para load_all)
if (!require(devtools, quietly = TRUE)) {
  cat("Instalando devtools...\n")
  install.packages("devtools", repos = "https://cloud.r-project.org")
  library(devtools)
}
cat("✓ devtools version:", as.character(packageVersion("devtools")), "\n\n")

# 5. Cargar tu versión LOCAL de sceasy
cat("Cargando sceasy LOCAL...\n")
tryCatch({
  devtools::load_all(".")
  cat("✓ sceasy cargado exitosamente\n")
}, error = function(e) {
  stop("ERROR al cargar sceasy: ", e$message)
})

# 6. Verificar que convertFormat existe
if (!exists("convertFormat")) {
  stop("ERROR: convertFormat no encontrada después de load_all()")
}
cat("✓ convertFormat encontrada\n\n")

# 7. Crear objeto Seurat v5 de prueba
cat("Creando objeto Seurat v5 de prueba...\n")
set.seed(42)
counts_matrix <- matrix(rpois(20000, lambda = 5), nrow = 200, ncol = 100)
rownames(counts_matrix) <- paste0("Gene", 1:200)
colnames(counts_matrix) <- paste0("Cell", 1:100)

test_obj <- CreateSeuratObject(
  counts = counts_matrix,
  project = "test_v5",
  min.cells = 0,
  min.features = 0
)

cat("✓ Objeto creado\n")
cat("  - Clase del assay:", class(test_obj[["RNA"]]), "\n")
cat("  - Dimensiones:", dim(test_obj), "\n")
cat("  - Número de células:", ncol(test_obj), "\n")
cat("  - Número de genes:", nrow(test_obj), "\n\n")

# 8. Prueba 1: Seurat -> Seurat (conversión a sí mismo)
cat("--- Prueba 1: convertFormat(obj, 'seurat', 'seurat') ---\n")
result1 <- tryCatch({
  result_obj <- convertFormat(test_obj, from = "seurat", to = "seurat")
  list(
    status = "SUCCESS",
    message = "Conversión exitosa",
    class = class(result_obj)[1]
  )
}, warning = function(w) {
  list(
    status = "WARNING",
    message = w$message,
    class = NULL
  )
}, error = function(e) {
  list(
    status = "ERROR",
    message = e$message,
    class = NULL
  )
})

cat("Estado:", result1$status, "\n")
if (result1$status != "SUCCESS") {
  cat("Mensaje:", result1$message, "\n")
} else {
  cat("Resultado:", result1$message, "\n")
  cat("Clase retornada:", result1$class, "\n")
}
cat("\n")

# 9. Prueba 2: Guardar como archivo RDS (si el formato lo soporta)
cat("--- Prueba 2: Guardar como archivo RDS ---\n")
temp_rds <- tempfile(fileext = ".rds")
result2 <- tryCatch({
  convertFormat(test_obj, from = "seurat", to = "seurat", outFile = temp_rds)
  if (file.exists(temp_rds)) {
    file_size <- file.info(temp_rds)$size
    list(
      status = "SUCCESS",
      message = paste("Archivo creado:", temp_rds, "(", round(file_size/1024, 2), "KB)")
    )
  } else {
    list(status = "ERROR", message = "No se creó el archivo")
  }
}, warning = function(w) {
  list(status = "WARNING", message = w$message)
}, error = function(e) {
  list(status = "ERROR", message = e$message)
})

cat("Estado:", result2$status, "\n")
if (result2$status != "SUCCESS") {
  cat("Mensaje:", result2$message, "\n")
} else {
  cat("Resultado:", result2$message, "\n")
}
cat("\n")

# 10. Prueba 3: Seurat -> AnnData (opcional, requiere Python)
cat("--- Prueba 3: Seurat -> AnnData (opcional) ---\n")
if (requireNamespace("reticulate", quietly = TRUE)) {
  if (reticulate::py_module_available("anndata")) {
    temp_h5ad <- tempfile(fileext = ".h5ad")
    result3 <- tryCatch({
      convertFormat(test_obj, from = "seurat", to = "anndata", outFile = temp_h5ad)
      if (file.exists(temp_h5ad)) {
        file_size <- file.info(temp_h5ad)$size
        list(
          status = "SUCCESS",
          message = paste("Archivo h5ad creado:", round(file_size/1024, 2), "KB")
        )
      } else {
        list(status = "ERROR", message = "No se creó el archivo h5ad")
      }
    }, warning = function(w) {
      list(status = "WARNING", message = w$message)
    }, error = function(e) {
      list(status = "ERROR", message = e$message)
    })
    
    cat("Estado:", result3$status, "\n")
    if (result3$status != "SUCCESS") {
      cat("Mensaje:", result3$message, "\n")
    } else {
      cat("Resultado:", result3$message, "\n")
    }
  } else {
    cat("⚠ SKIP: Módulo 'anndata' de Python no disponible\n")
    cat("  Para instalarlo: reticulate::py_install('anndata')\n")
  }
} else {
  cat("⚠ SKIP: Paquete 'reticulate' no instalado\n")
  cat("  Para instalarlo: install.packages('reticulate')\n")
}
cat("\n")

# 11. Resumen final
cat("========================================\n")
cat("RESUMEN FINAL\n")
cat("========================================\n")
cat("✓ Seurat versión:", packageVersion("Seurat"), "\n")
cat("✓ Assay class:", class(test_obj[["RNA"]]), "\n")
cat("✓ Prueba 1 (Seurat->Seurat):", result1$status, "\n")
cat("✓ Prueba 2 (Guardar RDS):", result2$status, "\n")

if (exists("result3")) {
  cat("✓ Prueba 3 (Seurat->AnnData):", result3$status, "\n")
}

cat("\n⚠ Si todas las pruebas son SUCCESS o WARNING (no ERROR), el fix funciona.\n")
cat("⚠ Los WARNING son normales (indican que se aplicó la conversión temporal).\n")

# 12. Limpiar archivos temporales
unlink(temp_rds)
if (exists("temp_h5ad")) unlink(temp_h5ad)

cat("\n✓ Prueba completada\n")
