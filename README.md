# river-distance-R-GRASS-GIS

A workflow using **R** and **GRASS GIS** (`rgrass7`) to calculate the shortest network distances between geographical places/archaeological sites (points) and river networks (lines).

Although originally developed for archaeological spatial analysis (e.g., studying site location preferences relative to water sources), this method is easily applicable to other domains requiring point-to-network distance queries.

## How It Works

The script automates GRASS GIS spatial operations directly from R:
1. **Initializes GRASS GIS** inside a temporary workspace.
2. **Imports Shapefiles** containing rivers (lines) and sites (points).
3. **Builds a Network** (`v.net`) to connect sites to the nearest river segment within a specified threshold.
4. **Selects the connecting lines** and computes their exact length in meters (`v.to.db`).
5. **Copies the calculated length values** back to the sites dataset (`v.what.vect`).
6. **Imports the final dataset** back into R for further statistical processing.

## Prerequisites

- **GRASS GIS:** Developed and tested with [GRASS GIS 7.6.1](https://grass.osgeo.org/grass76/binary/mswindows/native/x86_64/WinGRASS-7.6.1-1-Setup-x86_64.exe) (native Windows 64-bit setup).
- **R Packages:**
  - `rgrass7`
  - `sf`
  - `XML`

Ensure R packages are installed before running:
```r
install.packages(c("rgrass7", "sf", "XML"))
