#!/bin/bash


function restrict_to_overlaps() {
    # print lines from whole-genome file from loci with non-zero overlap
    # with target intervals
    WGS_FILE=$1
    EXOME_FILE=$2
    paste target_overlap_counts.txt $WGS_FILE |
        grep -Ev "^0" |
        cut -f 2- > $EXOME_FILE
    echo "Generated $EXOME_FILE"
}

restrict_to_overlaps Homo_sapiens_assembly38.contam.UD whole_exome_illumina_coding_v1.Homo_sapiens_assembly38.contam.UD
restrict_to_overlaps Homo_sapiens_assembly38.contam.bed whole_exome_illumina_coding_v1.Homo_sapiens_assembly38.contam.bed
restrict_to_overlaps Homo_sapiens_assembly38.contam.mu whole_exome_illumina_coding_v1.Homo_sapiens_assembly38.contam.mu