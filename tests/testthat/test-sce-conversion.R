context("SingleCellExperiment to Loom conversion")

test_that("sce2loom creates a .loom file on disk", {
  skip_if_not_installed("LoomExperiment")
  skip_if_not_installed("SingleCellExperiment")

  # Create a minimal SCE object for testing
  n_genes <- 20
  n_cells <- 10

  counts <- Matrix::Matrix(
    matrix(rpois(n_genes * n_cells, lambda = 5),
           nrow = n_genes, ncol = n_cells),
    sparse = TRUE
  )
  colnames(counts) <- paste0("cell_", 1:n_cells)
  rownames(counts) <- paste0("gene_", 1:n_genes)

  # Create a minimal SCE object
  sce_obj <- SingleCellExperiment::SingleCellExperiment(
    assays = list(counts = counts)
  )

  temp_loom <- .temp_loom_path()

  # Clean up after test
  on.exit(unlink(temp_loom, force = TRUE))

  result <- sce2loom(sce_obj, outFile = temp_loom)

  expect_true(file.exists(temp_loom))
  expect_s4_class(result, "SingleCellLoomExperiment")
})

test_that("loom2sce returns SingleCellExperiment class", {
  skip_if_not_installed("LoomExperiment")
  skip_if_not_installed("SingleCellExperiment")

  # First create a loom file to read
  n_genes <- 20
  n_cells <- 10

  counts <- Matrix::Matrix(
    matrix(rpois(n_genes * n_cells, lambda = 5),
           nrow = n_genes, ncol = n_cells),
    sparse = TRUE
  )
  colnames(counts) <- paste0("cell_", 1:n_cells)
  rownames(counts) <- paste0("gene_", 1:n_genes)

  sce_obj <- SingleCellExperiment::SingleCellExperiment(
    assays = list(counts = counts)
  )

  temp_loom <- .temp_loom_path()

  # Clean up after test
  on.exit(unlink(temp_loom, force = TRUE))

  # Create the loom file
  sce2loom(sce_obj, outFile = temp_loom)

  # Now read it back
  result <- loom2sce(temp_loom)

  expect_s3_class(result, "SingleCellExperiment")
})

test_that("SCE to Loom round-trip preserves cell count", {
  skip_if_not_installed("LoomExperiment")
  skip_if_not_installed("SingleCellExperiment")

  n_genes <- 20
  n_cells <- 10

  counts <- Matrix::Matrix(
    matrix(rpois(n_genes * n_cells, lambda = 5),
           nrow = n_genes, ncol = n_cells),
    sparse = TRUE
  )
  colnames(counts) <- paste0("cell_", 1:n_cells)
  rownames(counts) <- paste0("gene_", 1:n_genes)

  sce_obj <- SingleCellExperiment::SingleCellExperiment(
    assays = list(counts = counts)
  )

  temp_loom <- .temp_loom_path()

  # Clean up after test
  on.exit(unlink(temp_loom, force = TRUE))

  # Write to loom
  sce2loom(sce_obj, outFile = temp_loom)

  # Read back
  result <- loom2sce(temp_loom)

  # Check that cell count is preserved
  expect_equal(ncol(result), ncol(sce_obj))
  expect_equal(nrow(result), nrow(sce_obj))
})