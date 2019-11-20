#Download all the files specified in data/filenames
for url in $(cat data/urls) #TODO
do
    bash scripts/download.sh $url data
done

# Download the contaminants fasta file, and uncompress it
bash scripts/download.sh https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz res yes #TODO

# Index the contaminants file
bash scripts/index.sh res/contaminants.fasta res/contaminants_idx

# Merge the samples into a single file
for sid in $(ls data/*.fastq.gz | cut -d "-" -f1 | sed 's:data/::') #TODO
do
    bash scripts/merge_fastqs.sh data out/merged $sid
done

# TODO: run cutadapt for all merged files
    mkdir -p out/trimmed
    mkdir -p log/cutadapt
for sid in $(ls out/merged/*.fastq.gz | cut -d "." -f1 | sed 's:out/merged/::')
do
    cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed -o out/trimmed/${sid}.trimmed.fastq.gz out/merged/${sid}.fastq.gz > log/cutadapt/${sid}.log
    echo "Todo va bien"
done
#TODO: run STAR for all trimmed files
for fname in out/trimmed/*.fastq.gz
do
    # you will need to obtain the sample ID from the filename
    sid=ls out/merged/*.fastq.gz | cut -d "." -f1 | sed 's:out/merged/::'
    mkdir -p out/star/$sid
    STAR --runThreadN 4 --genomeDir res/contaminants_idx/ --outReadsUnmapped Fastx --readFilesIn ${fname} --readFilesCommand zcat --outFileNamePrefix out/star/${sid}/
done

for sampleid in log/cutadapt/
do
    cat | grep "Reads with adapters and total basepairs" >> pipeline.log
    
    
    
    
# TODO: create a log file containing information from cutadapt and star logs
# (this should be a single log file, and information should be *appended* to it on each run)
# - cutadapt: Reads with adapters and total basepairs
# - star: Percentages of uniquely mapped reads, reads mapped to multiple loci, and to too many loci




    echo "Guardar Ambiente"
    mkdir -p envs
    conda env export > envs/trabajo_final.yaml
