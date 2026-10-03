Dataset and codes for the submitted manuscript:

"Taxonomic update of the monospecific *Caa* (Apocynaceae, Asclepiadoideae): new records of the genus in Brazil and a revised morphological description".

Willian Souza Piovesani, Elizabeth de Araújo Schwarz, Elisete Maria de Freitas & Guilherme Dubal dos Santos Seger

***

### Files description:

> Piovesani_etal_NJB_data.RData
 
Dataset containing all objects necessary to execute the following script.

> SCRIPT_Caa_MapBiomas.R

Load MapBiomas rasters, crop a 5 km buffer around vouchers, export map figures, calculate and compare the area and percentage of cover classes, and the number of patches between years.

***
#### Codes were developed and tested using the R statistical environment, R version 4.6.0 (R Development Core Team, 2026).

### Computational Environment and Reproducibility

To ensure traceability and long-term methodological reproducibility, the dependency control of this repository is strictly managed by the `groundhog` package. The R computational environment was anchored to **October 2, 2026**. Upon executing the main script (`SCRIPT_Caa_MapBiomas.R`), `groundhog` will download and load the exact package versions available on this date from the CRAN historical mirror, shielding the analysis from future algorithmic updates.

### System Dependencies (Spatial Libraries)
Vector processing and operations on raster matrices depend on underlying C++ dynamic libraries. The original modeling was validated using the following versions of the geospatial engine (obtained via `sf::sf_extSoftVersion()`):

*   **GDAL:** [3.8.5]
*   **GEOS:** [3.13.0]
*   **PROJ:** [9.5.1]

To mitigate variations in rounding or geometric interpolation routines, it is recommended that host system instances maintain compatibility with the aforementioned versions.
