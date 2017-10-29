# Script to split INaturalist obersvations by the 12 months. Unless given a specific file, will process
# all files in ../data/inaturalist directory
# Daniel Truong
# dtruong@email.arizona.edu
# 2017-10-28

################################################################################
data.directory = "../data/inaturalist/"
out.dir = "../output/splitdata/"

args = commandArgs(trailingOnly = TRUE)
usage.string <- paste0("Usage: Rscript --vanilla split-observations-by-months.R <observations_file>\n",
                       "observations_file - file name containing Inaturalist observations to be split (optional)\n",
                       "\tIf not provided, then all files in directory '", data.directory, "' will be processed\n")

# If no opional argument, get all file names in '../data/inaturalist/' directory
# Otherwise get file name from command line argument
data.file.names = c()
if (length(args) < 1) {
  if (!dir.exists(data.directory)) {
    stop(paste0("Cannot find ", data.directory, ", directory does not exist.\n", usage.string, "\n"))
  }
  
  data.file.names = list.files(data.directory)
} else {
  infile <- args[1]
  if (!file.exists(infile)) {
    stop(paste0("Cannot find ", infile, ", file does not exist.\n", usage.string, "\n"))
  }
  
  if (file.access(names = infile, mode = 4) != 0) {
    stop(paste0("You do not have sufficient access to read ", infile, "\n"))
  }
  
  data.file.names = c(infile)
}


# Initialize output directory
temp.path = ""
for (path.part in unlist(strsplit(out.dir, "/"))) {
  temp.path = paste0(temp.path, path.part, "/")
  if (!dir.exists(temp.path)) {
    dir.create(temp.path)
  }
}

# Initialize observation counts data frame
observation.counts = data.frame(taxon_id = numeric(length(data.file.names)), total = numeric(length(data.file.names)))

# For every file, split the contained observations into 12 new files.
# Each file containing observations for a given month of the year.
currIndex = 1
for (file.name in data.file.names) {
  observations = read.csv(file = paste0(data.directory, basename(file.name)),
                          header = TRUE,
                          sep = ",",
                          stringsAsFactors = FALSE)
  
  # Get taxon id from file name
  inat.taxon.id = unlist(strsplit(basename(file.name), "-"))[1]
  #init dir for results
  result.dir = paste0(out.dir, inat.taxon.id, "/")
  if (!dir.exists(result.dir)) {
    dir.create(result.dir)
  }
  
  observation.counts[currIndex, "taxon_id"] = as.numeric(inat.taxon.id)
  observation.counts[currIndex, "total"] = nrow(observations)
  
  for (n in 1:12) {
    month = formatC(n, width = 2, flag = "0")
    observation.month = subset(observations, format(as.Date(observations$observed_on), "%m") == month)
    if (nrow(observation.month) > 0) {
      write.csv(observation.month,
                file = paste0(result.dir, month, '-', basename(file.name)),
                row.names = FALSE,
                quote = TRUE)
    }
    
    observation.counts[currIndex, month] = nrow(observation.month)
  }
  currIndex = currIndex + 1
  print(paste("Split file:", file.name))
}

counts.filename = paste0(out.dir, "counts.csv")
isAppend = FALSE
includeColName = TRUE
if (file.exists(counts.filename)) {
  isAppend = FALSE
  includeColName = TRUE
}
write.table(observation.counts,
          file = counts.filename,
          row.names = FALSE,
          sep = ",",
          col.names = includeColName,
          append = isAppend)

