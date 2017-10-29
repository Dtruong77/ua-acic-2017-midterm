# Script to download file of observations from iNaturalist based on taxon_id
# Jeff Oliver
# jcoliver@email.arizona.edu
# 2017-08-24

################################################################################
library(httr)

# INaturalis OAuth access token
access.token = "df6cd04233b788ec698b5b4f22ca5e0d195ab2ee6357dd3f5145c12680926cd1"

args = commandArgs(trailingOnly = TRUE)
usage.string <- paste0("Usage: Rscript --vanilla get-observation-data-batch.R <taxon_id_file> <start_index> <end_index>\n",
                       "taxon_id_file - File path for csv containing list of taxon ids, csv should have header with\"taxonID\" and be tab separated",
                       "start_index - Beginning row of taxon id file. (Optional)",
                       "end_index - End row of taxon id file. (Optional)")

if (length(args) < 1) {
  stop(paste("get-observation-data-batch requires a file path", 
             usage.string,
             sep = "\n"))
}

taxon.file.path <- args[1]
taxon.ids = read.csv(taxon.file.path, sep = "\t")

# Check for optional arguments
start.index = 1
if (length(args) > 1) {
  if (is.na(suppressWarnings(as.numeric(args[2])))) {
    stop("start_index must be a numeric integer")
  }
  start.index = as.numeric(args[2])
}

end.index = nrow(taxon.ids)
if (length(args) > 2) {
  if (is.na(suppressWarnings(as.numeric(args[3])))) {
    stop("end_index must be a numeric integer")
  }
  end.index = as.numeric(args[3])
}

if (start.index > end.index) {
  stop("end_index cannot be less than start_index")
}

page.per <- 200
for (row in start.index:end.index) {
  inat.taxon.id <- taxon.ids$taxonID[row]
  if (is.na(suppressWarnings(as.numeric(inat.taxon.id)))) {
    warning(paste0("Non-numeric taxon id detected, skipping! On row ",
                   row,
                   " : ",
                   inat.taxon.id))
  }
  
  page.num <- 1
  finished <- FALSE
  obs.data <- NULL
  # Retrieving information from iNaturalist API
  # Don't know a priori how many pages of records there will be, so for now we'll
  # just keep doing GET requests, incrementing the `page` key until we get a 
  # result with zero observations
  while (!finished) {
    obs.url <- paste0("http://inaturalist.org/observations.csv?&taxon_id=", 
                      inat.taxon.id,
                      "&page=",
                      page.num,
                      "&per_page=",
                      page.per,
                      "&quality_grade=research&has[]=geo")
    get.result = GET(obs.url, add_headers(Authorization = paste("Bearer", access.token)))
    data = content(get.result, as = "text")
    temp.data <- read.csv(text = data, stringsAsFactors = FALSE)
    if (nrow(temp.data) > 0) {
      if (is.null(obs.data)) {
        obs.data <- temp.data
      } else {
        obs.data <- rbind(obs.data, temp.data)
      }
    } else {
      finished <- TRUE
    }
    page.num <- page.num + 1
    rm(temp.data)
  }
  
  # As long as there are records, write them to file
  if (nrow(obs.data) > 0 && !is.null(obs.data)) {
    if (!dir.exists("../data")) {
      dir.create("../data")
    }
    if (!dir.exists("../data/inaturalist")) {
      dir.create("../data/inaturalist")
    }
    outfile <- paste0("../data/inaturalist/", inat.taxon.id, "-iNaturalist.txt")
    write.csv(x = obs.data, 
              file = outfile,
              row.names = FALSE,
              quote = TRUE) # Gotta quote strings, as they are likely to contain common seps (i.e. "," and "\t")
    cat(paste0(nrow(obs.data), " records for taxon id ", inat.taxon.id, " written to ", outfile, "\n"))
  } else {
    cat(paste0("No records returned for taxon id = ", inat.taxon.id, "\n"))
  }
  rm(obs.data)
}


