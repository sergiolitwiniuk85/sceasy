context("AnnData conversion")

test_that("anndata2seurat can convert a temp h5ad file", {
  skip_if_not_installed("reticulate")
  skip_if_not_installed("Seurat")

  # Check if anndata is available in Python
  if (!reticulate::py_module_available("anndata")) {
    skip("Python anndata module not available")
  }

  # Create a minimal h5ad file for testing
  # We'll create it programmatically using reticulate
  temp_h5ad <- .temp_h5ad_path()

  # Clean up after test
  on.exit(unlink(temp_h5ad, force = TRUE))

  # Import anndata and create a minimal AnnData object
  anndata <- reticulate::import("anndata", convert = FALSE)

  # Create a simple matrix (genes x cells)
  n_genes <- 10
  n_cells <- 5
  X <- matrix(1:(n_genes * n_cells), nrow = n_genes, ncol = n_cells)
  colnames(X) <- paste0("cell_", 1:n_cells)
  rownames(X) <- paste0("gene_", 1:n_genes)

  # Create obs (cell metadata) with the problematic column names
  obs <- data.frame(
    n_counts = rep(100, n_cells),
    n_genes = rep(50, n_cells),
    row.names = colnames(X)
  )

  # Create var (gene metadata)
  var <- data.frame(
    row.names = rownames(X)
  )

  # Create the AnnData object
  ad <- anndata$AnnData(
    X = reticulate::py_to_r(Matrix::t(X)),
    obs = obs,
    var = var
  )

  # Write to file
  ad$write_h5ad(temp_h5ad)

  # Now convert using anndata2seurat
  result <- anndata2seurat(temp_h5ad)

  expect_s3_class(result, "Seurat")
})

test_that("anndata2seurat renames metadata columns correctly", {
  skip_if_not_installed("reticulate")
  skip_if_not_installed("Seurat")

  # Check if anndata is available in Python
  if (!reticulate::py_module_available("anndata")) {
    skip("Python anndata module not available")
  }

  temp_h5ad <- .temp_h5ad_path()

  # Clean up after test
  on.exit(unlink(temp_h5ad, force = TRUE))

  anndata <- reticulate::import("anndata", convert = FALSE)

  # Create a simple matrix
  n_genes <- 10
  n_cells <- 5
  X <- matrix(1:(n_genes * n_cells), nrow = n_genes, ncol = n_cells)
  colnames(X) <- paste0("cell_", 1:n_cells)
  rownames(X) <- paste0("gene_", 1:n_genes)

  # Create obs with the problematic column names
  obs <- data.frame(
    n_counts = rep(100, n_cells),
    n_genes = rep(50, n_cells),
    row.names = colnames(X)
  )

  var <- data.frame(row.names = rownames(X))

  ad <- anndata$AnnData(
    X = reticulate::py_to_r(Matrix::t(X)),
    obs = obs,
    var = var
  )

  ad$write_h5ad(temp_h5ad)

  result <- anndata2seurat(temp_h5ad)

  # The function should rename n_counts -> nCounts_RNA
  # and n_genes -> nFeatures_RNA
  col_names <- colnames(result@meta.data)

  # Check for renamed columns
  expect_true(any(grepl("nCounts", col_names)),
    info = "Expected n_counts to be renamed to nCounts_RNA"
  )
})