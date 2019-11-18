# This script should download the file specified in the first argument ($1), place it in the directory specified in the second argument, 
# and *optionally* uncompress the downloaded file with gunzip if the third argument contains the word "yes".
    echo "Descargar genomas"
    cd data
    wget -i urls
    echo
    echo "Descargar contaminantes"
    cd ..
    wget -O res/contaminants.fasta.gz https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz
    gunzip -k res/contaminants.fasta.gz
    echo
