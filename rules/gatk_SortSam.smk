rule gatk_sortSam:
    input:
        bam = "aligned_reads/{sample}_aligned.unsorted.bam"
    output:
        bam = "aligned_reads/{sample}_sorted.bam",
        mapped_bam_readgroup="aligned_reads/{sample}_mapped_bam.readgroup",
        bam2="aligned_reads/{sample}_aligned_sorted.bam"
    conda:
        "../envs/picard.yaml"
    log:
        "logs/SortSam/{sample}.log"
    message:
        "Compiling a HTML report for quality control checks on raw sequence data"
    shell:
        '''java -Xms5000m -Xmx6500m -jar ../tools/picard.jar \
        CollectMultipleMetrics \
        INPUT={input.bam} \
        OUTPUT={output.mapped_bam_readgroup} \
        ASSUME_SORTED=true \
        PROGRAM=null \
        PROGRAM=CollectBaseDistributionByCycle \
        PROGRAM=CollectInsertSizeMetrics \
        PROGRAM=MeanQualityByCycle \
        PROGRAM=QualityScoreDistribution \
        METRIC_ACCUMULATION_LEVEL=null \
        METRIC_ACCUMULATION_LEVEL=ALL_READS && \
        java -Dsamjdk.compression_level=2 -Xms10000m -Xmx30000m -jar ../tools/picard.jar \
        SortSam \
        INPUT={input.bam} \
        OUTPUT={output.bam2} \
        SORT_ORDER="coordinate" \
        CREATE_INDEX=true \
        CREATE_MD5_FILE=true \
        MAX_RECORDS_IN_RAM=300000 &>{log}'''
