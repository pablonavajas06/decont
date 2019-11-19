# This script should download the file specified in the first argument ($1), place it in the directory specified in the second argument, 
# and *optionally* uncompress the downloaded file with gunzip if the third argument contains the word "yes".
    echo "Descargar genomas"
    wget -P $2 $1
    echo
    echo "Descargar contaminantes"
if ["$3"=="yes"]
then
    gunzip -fk $($2) / $(basename $1)
fi
