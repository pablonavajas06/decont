# This script should merge all files from a given sample (the sample id is provided in the third argument)
# into a single file, which should be stored in the output directory specified by the second argument.
# The directory containing the samples is indicated by the first argument.
    echo "Merging compressed text files"
    mkdir -p out/merged
    cat $1/$3* $1/$3* > $2/$3.fastq.gz
