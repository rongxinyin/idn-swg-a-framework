#!/bin/bash

# Define the location and init the baseline model
for location in Jakarta Balikpapan Padang Waingapu
do
	# location="Padang"

	ERR="err.log"

	# Define the sublevel folder to save the output files
	input_file="parametric-runs-input-$location.csv"
	init_output_folder="init_files/$location"

	# Create the sublevel folder if it does not exist
	mkdir -p "$init_output_folder"

	# Initialize the output file
	# echo "" > "$output_file"

	# Read the CSV file line by line and generate imf files
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
	    output_file="'$init_output_folder'/init_" NR-1 ".imf"
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

	# Define the sublevel folder to save the output files
	input_folder="init_files/$location"
	output_folder="output_files/$location"

	# Create the sublevel folder if it does not exist
	mkdir -p "$output_folder"

	# Run the ep-marco to convert imf to idf and call runenergyplus to run all idf simulations
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

	# Post-process the simulation results and generate the summary csv file
	source ~/myenv/bin/activate
	cd post-process
	python parse_htm_output.py --location $location
	cd ../
done