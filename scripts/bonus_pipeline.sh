echo "Descargar muestras"
wget -i data/urls -P data/ -nc data/urls

echo "Descaragar contaminantes"
# Download the contaminants fasta file, and uncompress it
bash scripts/download.sh https://bioinformatics.cnio.es/data/courses/decont/contaminants.fasta.gz res yes #TODO

echo "Index contaminantes"
# Index the contaminants file
bash scripts/index.sh res/contaminants.fasta res/contaminants_idx

echo "Merge muestras"
# Merge the samples into a single file
for sid in $(ls data/*.fastq.gz | cut -d "-" -f1 | sed 's:data/::' | sort | uniq) #TODO
do
    bash scripts/merge_fastqs.sh data out/merged $sid
done

echo "Running cutadpat"
# TODO: run cutadapt for all merged files
    mkdir -p out/trimmed
    mkdir -p log/cutadapt

for sampleid in $(ls out/merged/*.fastq.gz | cut -d "." -f1 | sed 's:out/merged/::' | sort | uniq)
do
    if [ -f out/merged/${sampleid}-12.5dpp_sRNA_merged.fastq.gz ]
    then
        cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed -o out/trimmed/${sampleid}.trimmed.fastq.gz out/merged/${sampleid}.fastq.gz > log/cutadapt/${sampleid}.log
    else
        echo "ERROR: No se detectan los ficheros necesarios: $sampleid-12.5dpp_sRNA_merged.fastq.gz"
        exit 1
    fi
done

echo "Running Star"
#TODO: run STAR for all trimmed files
for fname in out/trimmed/*.fastq.gz
do
    sid=$(echo ${fname} | sed 's:out/trimmed/::' | cut -d "." -f1)
    mkdir -p out/star/${sid}

    if [ -f ${fname} ]
    then
        STAR --runThreadN 4 --genomeDir res/contaminants_idx --outReadsUnmapped Fastx --readFilesIn ${fname} --readFilesCommand zcat --outFileNamePrefix out/star/${sid}/
    else
       echo "ERROR: No se detectan los ficheros necesarios: $fname or res/contaminants_idx"
       exit 1
    fi
done

echo "Create Log_file"
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
