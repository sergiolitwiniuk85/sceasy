<div align="center">
  <h1>🔄 sceasy</h1>
  <p><strong>Single-Cell Data Format Converter</strong></p>
  <p>Seamlessly convert between single-cell omics formats — Seurat, AnnData, SingleCellExperiment, Loom, and Monocle CDS.</p>

  <p>
    <a href="https://github.com/sergiolitwiniuk85/sceasy/blob/main/LICENSE">
      <img src="https://img.shields.io/github/license/sergiolitwiniuk85/sceasy" alt="License">
    </a>
    <a href="https://github.com/sergiolitwiniuk85/sceasy">
      <img src="https://img.shields.io/github/v/tag/sergiolitwiniuk85/sceasy" alt="Version">
    </a>
    <a href="https://github.com/sergiolitwiniuk85/sceasy/actions">
      <img src="https://img.shields.io/github/actions/workflow/status/sergiolitwiniuk85/sceasy/test.yml?branch=main" alt="CI">
    </a>
    <a href="https://cran.r-project.org/package=testthat">
      <img src="https://img.shields.io/badge/testthat-3.x-blue" alt="testthat">
    </a>
  </p>
</div>

---

## ✨ Features

- 🔄 **Cross-format conversion** — move data between Seurat, AnnData (h5ad), SingleCellExperiment, Loom, and Monocle CDS
- 🧬 **Seurat v5 ready** — full support for `Assay5` objects (automatic detection & conversion)
- 🔧 **No data loss** — preserves embeddings, metadata, variable features, and custom layers
- 🐍 **Python interop** — powered by `reticulate` for seamless AnnData integration
- 🧪 **Tested** — CI pipeline runs against both Seurat v4 and v5
- 📦 **Lightweight** — minimal dependencies, installable via `devtools` or `conda`

## 🔁 Supported Conversions

| From → To | AnnData | Seurat | SCE | Loom | CDS |
|:---------:|:-------:|:------:|:---:|:----:|:---:|
| **AnnData** | — | ✅ | — | — | ✅ |
| **Seurat** | ✅ | — | ✅ | — | — |
| **SCE** | ✅ | — | — | ✅ | — |
| **Loom** | ✅ | ✅ | ✅ | — | — |

## 📦 Installation

### From GitHub (recommended for this fork)

```r
# Install devtools if you haven't already
install.packages("devtools")

# Install sceasy with Seurat v5 support
devtools::install_github("sergiolitwiniuk85/sceasy")
```

### From Bioconda (upstream version)

```bash
conda install -c bioconda r-sceasy
```

### Dependencies

After installing sceasy, install the required R and Python packages:

```r
# R packages
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install(c("LoomExperiment", "SingleCellExperiment"))

# reticulate for Python interop
install.packages("reticulate")
```

```bash
# Python packages
conda install anndata loompy -c bioconda
```

## 🚀 Quick Start

```r
library(sceasy)
library(reticulate)
use_condaenv("your-environment-name")

# Seurat → AnnData
sceasy::convertFormat(seurat_obj, from = "seurat", to = "anndata",
                       outFile = "data.h5ad")

# AnnData → Seurat
sceasy::convertFormat("data.h5ad", from = "anndata", to = "seurat",
                       outFile = "data.rds")

# Seurat → SingleCellExperiment
sceasy::convertFormat(seurat_obj, from = "seurat", to = "sce",
                       outFile = "data.rds")

# SingleCellExperiment → AnnData
sceasy::convertFormat(sce_obj, from = "sce", to = "anndata",
                       outFile = "data.h5ad")

# SingleCellExperiment → Loom
sceasy::convertFormat(sce_obj, from = "sce", to = "loom",
                       outFile = "data.loom")

# Loom → AnnData
sceasy::convertFormat("data.loom", from = "loom", to = "anndata",
                       outFile = "data.h5ad")

# Loom → SingleCellExperiment
sceasy::convertFormat("data.loom", from = "loom", to = "sce",
                       outFile = "data.rds")
```

## 🧬 Seurat v5 Compatibility

This fork adds **full Seurat v5 support**. The original `sceasy` uses `slot =` parameters that were deprecated in Seurat v5's new `Assay5` layer API.

### What was changed

| Change | Location | Description |
|--------|----------|-------------|
| **Assay5 → Assay conversion** | `R/utils.R` | Automatic detection and conversion of `Assay5` objects before conversion |
| **Layer API** | `R/functions.R` | Uses `layer =` for Seurat v5, falls back to `slot =` for v4 |
| **Dispatch refactor** | `R/methods.R` | Replaced `eval(parse())` with clean named-list dispatch |
| **seurat2sce v5 guard** | `R/functions.R` | Added `Assay5` handling before `as.SingleCellExperiment()` |

### How it works

```r
# Just use it — v5 detection is automatic
seurat_v5_obj <- your_seurat_v5_object

# sceasy detects Assay5, converts temporarily, converts, and returns the result
sce <- sceasy::convertFormat(seurat_v5_obj, from = "seurat", to = "sce")
```

A warning is emitted when an `Assay5` object is detected, so you always know when the compatibility layer is active.

## 🧪 Development

```r
# Run tests
devtools::test()

# Or directly
testthat::test_dir("tests/testthat")
```

Tests are run in CI against both **Seurat v4** and **Seurat v5** via GitHub Actions.

## 📚 Related Tools

- [cellgeni/schard](https://github.com/cellgeni/schard) — h5ad to RDS conversion
- [cellgeni/py8rds](https://github.com/cellgeni/py8rds) — RDS to h5ad conversion
- [cellxgene](https://github.com/chanzuckerberg/cellxgene) — interactive single-cell explorer

## 🙏 Credits

This is a **maintained fork** of [cellgeni/sceasy](https://github.com/cellgeni/sceasy) by Vladimir Kiselev and Ni Huang. The original package is an essential tool in the single-cell bioinformatics ecosystem.

This fork adds Seurat v5 compatibility, code quality improvements, and a proper test suite.

## 📄 License

GPL-3.0
