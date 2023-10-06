#!/bin/bash

# Run the baseline model

ERR="err.log"

# Define the sublevel folder to save the output files
input_folder="init_files"
output_folder="output_files"

# Create the sublevel folder if it does not exist
mkdir -p "$output_folder"

for FILE in $input_folder/init_*.imf
do
	echo "Processing $FILE"
	if [ -f "${FILE%%.*}.epmdet" ];
	then
	   echo "File $FILE exist and cleanup Old $FILE" >$ERR
	   # Delete all output files
	   rm ${FILE%%.*}.epmdet
	   rm ${FILE%%.*}.epmidf
	   rm ${FILE%%.*}.idf
	else
	   runepmacro ${FILE%%.*}
	   mv ${FILE%%.*}.epmidf ${FILE%%.*}.idf
	   rm ${FILE%%.*}.epmdet
	   energyplus -w ../weather-files/IDN_JAKARTA-SOEKARNO-HA_967490_IW2/IDN_JAKARTA-SOEKARNO-HA_967490_IW2.EPW -r ${FILE%%.*}.idf 
	   echo "Completed EnergyPlus File $FILE Model Successfully." >>$ERR

	   mv eplusout.csv $output_folder/$(basename ${FILE%%.*}.csv)
	   mv eplustbl.htm $output_folder/$(basename ${FILE%%.*}.htm)
	   rm eplus*
	   rm sqlite.err
	fi
done