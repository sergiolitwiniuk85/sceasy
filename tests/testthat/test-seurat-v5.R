context("Seurat v5 detection and conversion")

test_that(".is_seurat_v5_object correctly identifies v5 objects", {
  skip_if_not_installed("Seurat")

  # Skip if Seurat version < 5.0.0
  if (packageVersion("Seurat") < "5.0.0") {
    skip("Seurat version < 5.0.0")
  }

  v5_obj <- .create_seurat_v5()

  expect_true(.is_seurat_v5_object(v5_obj))
})

test_that(".is_seurat_v5_object returns FALSE for v4 objects", {
  skip_if_not_installed("Seurat")

  v4_obj <- .create_seurat_v4()

  expect_false(.is_seurat_v5_object(v4_obj))
})

test_that("convertFormat v5 object issues warning about v5 detection", {
  skip_if_not_installed("Seurat")

  # Skip if Seurat version < 5.0.0
  if (packageVersion("Seurat") < "5.0.0") {
    skip("Seurat version < 5.0.0")
  }

  v5_obj <- .create_seurat_v5()

  expect_warning(
    result <- convertFormat(v5_obj, from = "seurat", to = "seurat"),
    regexp = "Seurat v5 object detected"
  )
})

test_that("convertFormat v5 object returns Seurat class after conversion", {
  skip_if_not_installed("Seurat")

  # Skip if Seurat version < 5.0.0
  if (packageVersion("Seurat") < "5.0.0") {
    skip("Seurat version < 5.0.0")
  }

  v5_obj <- .create_seurat_v5()

  suppressWarnings({
    result <- convertFormat(v5_obj, from = "seurat", to = "seurat")
  })

  expect_s3_class(result, "Seurat")
})