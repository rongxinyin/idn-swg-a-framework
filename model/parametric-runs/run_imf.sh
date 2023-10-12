#!/bin/bash

# Run the baseline model
location="Jakarta"

ERR="err.log"

# Define the sublevel folder to save the output files
input_folder="init_files/$location"
output_folder="output_files/$location"

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
		if grep -q "Jakarta" $FILE; then
		   energyplus -w ../weather-files/IDN_JAKARTA-SOEKARNO-HA_967490_IW2/IDN_JAKARTA-SOEKARNO-HA_967490_IW2.EPW -r ${FILE%%.*}.idf 
		elif grep -q "Balikpapan" $FILE; then
		   energyplus -w ../weather-files/IDN_BALIKPAPAN-SEPINGGA_966330_IW2/IDN_BALIKPAPAN-SEPINGGA_966330_IW2.EPW -r ${FILE%%.*}.idf 
		elif grep -q "Padang" $FILE; then
		   energyplus -w ../weather-files/IDN_PADANG-TABING_961630_IW2/IDN_PADANG-TABING_961630_IW2.EPW -r ${FILE%%.*}.idf 
		elif grep -q "Waingapu" $FILE; then
		   energyplus -w ../weather-files/IDN_WAINGAPU-MAU-HAU_973400_IW2/IDN_WAINGAPU-MAU-HAU_973400_IW2.EPW -r ${FILE%%.*}.idf 
		elif grep -q "Puncak" $FILE; then
		   energyplus -w ../weather-files/Puncak-Bogor/IDN_Puncak-Bogor_MN6.epw -r ${FILE%%.*}.idf
		else
		   echo "No location found" >>$ERR
		fi
		echo "Completed EnergyPlus File $FILE Model Successfully." >>$ERR

		mv eplusout.csv $output_folder/$(basename ${FILE%%.*}.csv)
		mv eplustbl.htm $output_folder/$(basename ${FILE%%.*}.htm)
		rm eplus*
		rm sqlite.err
	fi
done

# source ~/myenv/bin/activate
# cd post-process
# python parse_htm_output.py