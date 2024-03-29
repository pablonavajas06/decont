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
for sid in $(ls data/*.fastq.gz | cut -d "-" -f1 | sed 's:data/::'| sort | uniq) #TODO
do
    bash scripts/merge_fastqs.sh data out/merged $sid
done

# TODO: run cutadapt for all merged files
    mkdir -p out/trimmed
    mkdir -p log/cutadapt
for sampleid in $(ls out/merged/*.fastq.gz | cut -d "." -f1 | sed 's:out/merged/::')
do
    cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed -o out/trimmed/${sampleid}.trimmed.fastq.gz out/merged/${sampleid}.fastq.gz > log/cutadapt/${sampleid}.log
done
#TODO: run STAR for all trimmed files
for fname in out/trimmed/*.fastq.gz
do
    # you will need to obtain the sample ID from the filename
    sid=$(echo $fname | sed 's:out/trimmed/::' | cut -d "." -f1)
    mkdir -p out/star/$sid
    STAR --runThreadN 4 --genomeDir res/contaminants_idx --outReadsUnmapped Fastx --readFilesIn ${fname} --readFilesCommand zcat --outFileNamePrefix out/star/${sid}/
done
# TODO: create a log file containing information from cutadapt and star logs
# (this should be a single log file, and information should be *appended* to it on each run)
# - cutadapt: Reads with adapters and total basepairs
# - star: Percentages of uniquely mapped reads, reads mapped to multiple loci, and to too many loci
for sampleid in $(ls data/*.fastq.gz | cut -d "-" -f1 | sed 's:data/::' | sort | uniq)
do
    echo "Sample: " $sampleid >> log/pipeline.log
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" >> log/pipeline.log

    echo "Cutadpat: " >> log/pipeline.log
    echo $(cat log/cutadapt/$sampleid.log | grep -i "Reads with adapters") >> log/pipeline.log
    echo $(cat log/cutadapt/$sampleid.log | grep -i "total basepairs") >> log/pipeline.log
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" >> log/pipeline.log
    echo "STAR: " >> log/pipeline.log
    echo $(cat out/star/$sampleid/Log.final.out | grep -e "Percentage of uniquely mapped reads") >> log/pipeline.log
    echo $(cat out/star/$sampleid/Log.final.out | grep -e "Percentage of reads mapped to multiple loci") >> log/pipeline.log
    echo $(cat out/star/$sampleid/Log.final.out | grep -e "Percentage to too many loci") >> log/pipeline.log
    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" >> log/pipeline.log
    echo " " >> log/pipeline.log
done

echo "Guardar Ambiente"
mkdir -p envs
conda env export > envs/decont.yaml
