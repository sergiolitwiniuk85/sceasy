# sceasy

`sceasy` is a package that helps easy conversion of different single-cell data formats to each other. Converting to AnnData creates a file that can be directly used in [cellxgene](https://github.com/chanzuckerberg/cellxgene) which is an interactive explorer for single-cell transcriptomics datasets.


| 💡 for h5da to rds conversion also see [https://github.com/cellgeni/schard](https://github.com/cellgeni/schard) |
| ----------------------------------------------------------------------------------------------- |

| 💡 for rds to h5ad conversion also see [https://github.com/cellgeni/py8rds](https://github.com/cellgeni/py8rds) |
| ----------------------------------------------------------------------------------------------- |

> ### Warning
> Before installing the conda packages below please first create a new conda environment EnvironmentName and activate it. Everything else can be installed in R.


## Installation

sceasy is installable either as a bioconda package:

```conda install -c bioconda r-sceasy```

or as an R package:

```devtools::install_github("cellgeni/sceasy")```

which will require the biconductor packages BiocManager and LoomExperiment:

```
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install(c("LoomExperiment", "SingleCellExperiment"))
```

To use sceasy ensure the anndata package is installed:

```conda install anndata -c bioconda```

Optionally, if you plan to convert between loom and anndata, please also ensure that the `loompy` package is installed:

```conda install loompy  -c bioconda```

You will also need to install reticulate package:

```install.packages('reticulate')```


## Usage

Before converting your data please load the following libraries in your R session:

```
library(sceasy)
library(reticulate)
use_condaenv('EnvironmentName')
loompy <- reticulate::import('loompy')
```

**Seurat to AnnData**

```
sceasy::convertFormat(seurat_object, from="seurat", to="anndata",
                       outFile='filename.h5ad')
```

**AnnData to Seurat**

```
sceasy::convertFormat(h5ad_file, from="anndata", to="seurat",
                       outFile='filename.rds')
```
                       
**Seurat to SingleCellExperiment**

```
sceasy::convertFormat(seurat_object, from="seurat", to="sce",
                       outFile='filename.rds')
```
   
**SingleCellExperiment to AnnData**

```
sceasy::convertFormat(sce_object, from="sce", to="anndata",
                       outFile='filename.h5ad')
```
                       
**SingleCellExperiment to Loom**

```
sceasy::convertFormat(sce_object, from="sce", to="loom",
                       outFile='filename.loom')
```
                       
**Loom to AnnData**

```
sceasy::convertFormat('filename.loom', from="loom", to="anndata",
                       outFile='filename.h5ad')
```
                       
**Loom to SingleCellExperiment**



## Seurat v5 Compatibility

This fork includes full compatibility with **Seurat v5**, which introduced the new `Assay5` class. The original `sceasy` package uses deprecated `slot` parameters that cause errors with Seurat v5.

### Modifications Made

<details>
<summary>Click to expand: Code changes for Seurat v5 support</summary>

#### 1. Assay Conversion (`R/methods.R`)

Added automatic detection and temporary conversion of `Assay5` to legacy `Assay`:

```r
# Detectar versión de Seurat
.is_seurat_v5 <- function(obj) {
  inherits(obj, "Seurat") && 
  packageVersion("Seurat") >= "5.0.0"
}

# Convertir Assay5 a Assay temporalmente
.fix_seurat_v5_assays <- function(obj) {
  if (!.is_seurat_v5(obj)) return(obj)
  for (assay_name in Seurat::Assays(obj)) {
    if (inherits(obj[[assay_name]], "Assay5")) {
      obj[[assay_name]] <- as(object = assay_obj, Class = "Assay")
    }
  }
  return(obj)
}


```
sceasy::convertFormat('filename.loom', from="loom", to="sce",
                       outFile='filename.rds')
```
