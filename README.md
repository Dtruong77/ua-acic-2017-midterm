# README for species distribution modeling

## Overview
Code and sample data for running species distribution models from data 
harvested from [iNaturalist](http://www.inaturalist.org). Produces 13 models for each species listed
in "taxon-ids.txt" (or another file containing taxon ids); 1 for each month and 1 for all data.

## Dependancies
Five additional R packages are required:

+ raster
+ sp
+ dismo
+ maptools
+ httr

## Structure
+ data
  + inaturalist: data harvested from [iNaturalist](http://www.inaturalist.org)
    + 50931-iNaturalist.txt: Gray Hairstreak, _Strymon melinus_
    + 509627-iNaturalist.txt: Western Giant Swallowtail, _Papilio rumiko_
    + 59125-iNaturalist.txt: Great Copper, _Lycaena xanthoides_
  + gbif: data harvested from GBIF for iNaturalist taxon_id values; most files
  _not_ under version control (> 2GB each);
    + taxon-ids.txt: tab-delimited text files of unique species-level taxon_id
    values for records from Canada, Mexico, and United States; incluedes two
    columns: `taxonID` and `scientificName`
+ output (not included in repository, but this structure is assumed on local)
  + images
  + results
  + splitdata
+ scripts
  + get-observation-data.R: Harvest data from iNaturalist using their API; 
  called from command line terminal
    + Usage: `Rscript --vanilla get-observation-data.R <taxon_id>`
    + Example: `Rscript --vanilla get-observation-data.R 60606`
  + get-observation-data-batch.R <taxon_id_file> <start_index> <end_index>
  	+ Usage: 'Rscript --vanilla get-observation-data-batch.R <taxon_id_file> <start_index> <end_index>'
  	+ Example: 'Rscript get-observation-data-batch.R ../data/gbif/taxon-ids.txt 0 700'
  + run-sdm.R: Run species distribution model and create map and raster output;
  called from command line terminal
    + Usage: `Rscript --vanilla run-sdm.R <path/to/data/file> <output-file-prefix> <path/to/output/directory/>`
    + Example: `Rscript --vanilla run-sdm.R data/inaturalist/60606-iNaturalist.txt 60606 output/`
  + split-observations-by-months.R: Loops through all observation files contained in ./data/inaturalist and splits
  each file into 12 files for each month. Alternatively, if a file path is given as an arugments, processes the specified file.
  	+ Usage: 'Rscript split-observations-by-months.R <observations_file>'
  	+ Example: 'Rscript split-observations-by-months.R'
  + SDMmaker.sh: Bash script that runs the run-sdm.R script on all datasets in ./data/inaturalist and ./output/splitdata 
  and puts the outputs into ./output/images
  	+ Usage: Run from the scripts folder that contains this script
  	+ Example: 'bash SDMmaker.sh'

## General approach:

1. Create csv (with header 'taxonID') that contains the taxon ids, one per line.
2. Install necessary R packages (listed above)
2. Run get-obsevation-data-batch.R to get all observations for each species in file 
3. Run split-observations-by-months.R to split the results of step 2 into 12 files for each months obsevations
4. Run SDMMaker shell script from scripts folder

## Resources
### Species distribution models in R
+ [Vignette for `dismo` package](https://cran.r-project.org/web/packages/dismo/vignettes/sdm.pdf)
+ [Fast and flexible Bayesian species distribution modelling using Gaussian processes](http://onlinelibrary.wiley.com/doi/10.1111/2041-210X.12523/pdf)
+ [Species distribution models in R](http://www.molecularecologist.com/2013/04/species-distribution-models-in-r/)
+ [Run a range of species distribution models](https://rdrr.io/cran/biomod2/man/BIOMOD_Modeling.html)
+ [SDM polygons on a Google map](https://rdrr.io/rforge/dismo/man/gmap.html)
+ [R package 'maxnet' for functionality of Java maxent package](https://cran.r-project.org/web/packages/maxnet/maxnet.pdf)

### iNaturalist
+ [API documentation](https://www.inaturalist.org/pages/api+reference)
+ Google groups [discussion](https://groups.google.com/d/topic/inaturalist/gDpfMWXNxvE/discussion) about taxon_id
