
#! /usr/bin/env bash

datasets='/Users/katiearnolds/data-sets'

CTCF="$datasets/bed/encode.tfbs.chr22.bed.gz"
H3K4="$datasets/bed/encode.h3k4me3.hela.chr22.bed.gz"

# Use BEDtools intersect to identify the size of the largest overlap
# between CTCF and H3K4me3 locations.

answer_1=$(bedtools intersect -a $CTCF -b $H3K4 \
|awk 'BEGIN {OFS="\t"} ($4 == "CTCF") {print $3 - $2}' \
|sort -k1nr \
|head -n1)

echo "answer-1: $answer_1"

fasta="$datasets/fasta/hg19.chr22.fa"
bed="$datasets/bed/genes.hg19.bed.gz"

answer_2=$(echo -e "chr22\t19000000\t19000500" > tmp.bed \
|bedtools nuc -fi $fasta -bed tmp.bed \
|tail -n1 \
|cut -f5)

echo "answer-2: $answer_2"



hela="$datasets/bedtools/ctcf.hela.chr22.bg.gz"
answer_3=$(gzcat $CTCF \
|awk '($4 == "CTCF")' \
|bedtools map -a - -b $hela -c 4 -o mean \
|sort -k5nr \
|awk 'BEGIN{OFS="\t"} {print$3 -$2}' \
|head -n1)

echo "answer-3: $answer_3"

tss="$datasets/bed/tss.hg19.chr22.bed.gz"
hg19="$datasets/genome/hg19.genome"
answer_4=$(bedtools slop -i $tss -g $hg19 -l 1000 -r 0 -s \
|sort \
|bedtools map -a - -b $hela -c 4 -o  median\
|sort -k7nr \
|cut -f4 \
|head -n1)

echo "answer-4: $answer_4"

answer_5=$(bedtools complement -i $bed -g $hg19 \
|awk 'BEGIN {OFS="\t"} ($1 == "chr22") {print $1, $2, $3, $3 - $2}' \
|sort -k4nr \
|awk '{print $1":"$2"-"$3}'\
|head -n1)

echo "answer-5: $answer_5"

