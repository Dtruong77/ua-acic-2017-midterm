#!/bin/bash

clear

######THIS IS FOR COMBINING!
#Rscript --vanilla ~/Desktop/ebutterfly-sdm-master/GetData.R
# Run this script from the scripts directory

{
# Create images dir if it does not exist
if [ ! -d ../output/images ]; then
    mkdir ../output/images
fi

# Run SDM for all month datasets
input_dir=../output/splitdata/
for taxid_dir in $(ls $input_dir); do
    out_dir=../output/images/$taxid_dir
    # Create "taxid_dir" directory in images dir if it does not exist
    if [ ! -d $out_dir ]; then
        mkdir $out_dir
    fi

    for obs_file in $(ls $input_dir$taxid_dir); do
        month=$(echo $obs_file | cut -d'-' -f1)
        echo "Running SDM for $taxid_dir from data: $input_dir$taxid_dir/$obs_file" 
        Rscript run-sdm.R $input_dir$taxid_dir/$obs_file $month-$taxid_dir $out_dir
    done
done
} >> ../output/sdm.log 2> ../output/sdm.log

{
# Run SDM for all all-time datasets
input_dir=../data/inaturalist/
for file_name in $(ls $input_dir); do
    taxid=$(echo $file_name | cut -d'-' -f1)
    out_dir=../output/images/$taxid

    if [ ! -d $out_dir ]; then
        mkdir $out_dir
    fi

    echo "Running SDM for $taxid_dir from data: $input_dir$file_name"
    Rscript run-sdm.R $input_dir$file_name 00-$taxid $out_dir

done
} >> ../output/sdm_all.log 2> ../output/sdm_all.log


