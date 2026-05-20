context("Seurat to SingleCellExperiment conversion")

test_that("seurat2sce returns SingleCellExperiment class for v4 objects", {
  skip_if_not_installed("Seurat")
  skip_if_not_installed("SingleCellExperiment")

  v4_obj <- .create_seurat_v4()

  result <- seurat2sce(v4_obj)

  expect_s3_class(result, "SingleCellExperiment")
})

test_that("seurat2sce returns SingleCellExperiment class for v5 objects", {
  skip_if_not_installed("Seurat")
  skip_if_not_installed("SingleCellExperiment")

  # Skip if Seurat version < 5.0.0
  if (packageVersion("Seurat") < "5.0.0") {
    skip("Seurat version < 5.0.0")
  }

  v5_obj <- .create_seurat_v5()

  result <- seurat2sce(v5_obj)

  expect_s3_class(result, "SingleCellExperiment")
})

test_that("seurat2sce with outFile creates a file on disk", {
  skip_if_not_installed("Seurat")
  skip_if_not_installed("SingleCellExperiment")

  v4_obj <- .create_seurat_v4()

  temp_file <- .temp_rds_path()

  # Clean up after test
  on.exit(unlink(temp_file, force = TRUE))

  result <- seurat2sce(v4_obj, outFile = temp_file)

  expect_true(file.exists(temp_file))
  expect_s3_class(result, "SingleCellExperiment")
})

test_that("seurat2sce preserves cell count", {
  skip_if_not_installed("Seurat")
  skip_if_not_installed("SingleCellExperiment")

  v4_obj <- .create_seurat_v4()

  result <- seurat2sce(v4_obj)

  expect_equal(ncol(result), ncol(v4_obj))
  expect_equal(nrow(result), nrow(v4_obj))
})