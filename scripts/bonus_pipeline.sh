echo "Descargar muestras"
wget -i data/urls -P data/ -nc data/urls

echo "Descaragar contaminantes"
# Download the contaminants fasta file, and uncompress it
bash scripts/download.sh https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz res yes #$

echo "Index de los contaminantes"
# Index the contaminants file
bash scripts/index.sh res/contaminants.fasta res/contaminants_idx

echo "Merge de las muestras"
# Merge the samples into a single file
for sid in $(ls data/*.fastq.gz | cut -d "-" -f1 | sed 's:data/::') #TODO
do
    bash scripts/merge_fastqs.sh data out/merged $sid
done

echo "Running cutadapt"
# TODO: run cutadapt for all merged files
    mkdir -p out/trimmed
    mkdir -p log/cutadapt
for sid in $(ls out/merged/*.fastq.gz | cut -d "." -f1 | sed 's:out/merged/::')
do
    cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed -o out/trimmed/${sid}.trimmed.fastq.gz out/$
    echo "Todo va bien"
done

echo "Running STAR"
#TODO: run STAR for all trimmed files
for fname in out/trimmed/*.fastq.gz
do
    # you will need to obtain the sample ID from the filename
    sid=ls out/merged/*.fastq.gz | cut -d "." -f1 | sed 's:out/merged/::'
    mkdir -p out/star/$sid
    STAR --runThreadN 4 --genomeDir res/contaminants_idx/ --outReadsUnmapped Fastx --readFilesIn ${fname} -$
done

echo "Create Log_file"
for sampleid in log/cutadapt/
do
    cat | grep "Reads with adapters and total basepairs" >> pipeline.log

