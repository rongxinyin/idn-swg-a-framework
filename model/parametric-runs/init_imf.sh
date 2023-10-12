#!/bin/bash

# Define the input CSV file and the output text file
location="Jakarta"
input_file="parametric-runs-input-$location.csv"

# output_file="init.imf"

# Define the sublevel folder to save the output files
output_folder="init_files/$location"

# Create the sublevel folder if it does not exist
mkdir -p "$output_folder"

# Initialize the output file
# echo "" > "$output_file"

# Read the CSV file line by line
awk -F ',' '
NR==1 {
    # Store the field names from the first line
    for (i=1; i<NF; i++) {
        gsub(/"/, "");
        field_names[i]=$i;
    }
    next;
}
{
    # Initialize the output file
    output_file="'$output_folder'/init_" NR-1 ".imf"
    print "" > output_file

    # add first line to the init file
    print "! ----parameters----" >> output_file;

    # For each line, write each field name and value into the output file
    for (i=1; i<NF; i++) {
        print "##set1 " field_names[i] "[] " $i >> output_file;
    }

    # Include the parameter imf file
    print "##include parameter.imf" >> output_file;

    # Add an empty line between records
    print "" >> output_file;
}' "$input_file"
