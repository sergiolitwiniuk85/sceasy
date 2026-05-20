context("convertFormat dispatch and routing")

# Test that convertFormat dispatches to correct conversion functions

test_that("convertFormat seurat to seurat raises error (no identity conversion)", {
  skip_if_not_installed("Seurat")

  obj <- .create_seurat_v4()

  expect_error(
    convertFormat(obj, from = "seurat", to = "seurat"),
    regexp = "Unsupported"
  )
})

test_that("convertFormat seurat to sce calls seurat2sce internally", {
  skip_if_not_installed("Seurat")
  skip_if_not_installed("SingleCellExperiment")

  obj <- .create_seurat_v4()

  # Should return SingleCellExperiment (or error gracefully if dependencies missing)
  expect_error_free({
    result <- convertFormat(obj, from = "seurat", to = "sce")
  })

  expect_s3_class(result, "SingleCellExperiment")
})

test_that("convertFormat unsupported pair raises descriptive error", {
  skip_if_not_installed("Seurat")

  obj <- .create_seurat_v4()

  # loom to cds is not a supported conversion
  # This should error with message containing "Unsupported"
  expect_error(
    convertFormat(obj, from = "seurat", to = "cds"),
    regexp = "Unsupported",
    fixed = FALSE
  )
})

test_that("convertFormat mismatched from/to raises descriptive error", {
  skip_if_not_installed("Seurat")

  obj <- .create_seurat_v4()

  # seurat to cds and seurat to loom are not supported pairs
  expect_error(
    convertFormat(obj, from = "seurat", to = "cds"),
    regexp = "Unsupported"
  )
  expect_error(
    convertFormat(obj, from = "seurat", to = "loom"),
    regexp = "Unsupported"
  )
})