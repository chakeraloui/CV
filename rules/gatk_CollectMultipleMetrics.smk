rule gatk_CollectMultipleMetrics:
    input:
        bam = "aligned_reads/{sample}_recalibrated.bam",
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME'])
    output:
        output_bam_prefix="aligned_reads/{sample}_multiple_metrics",
        output_bam_prefix2="aligned_reads/{sample}_multiple_metrics2",
        read_group_md5_filename="aligne_reads/{sample}_read_group_md5"
    
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY'])
    log:
        "logs/CollectMultipleMetrics/{sample}.log"
    benchmark:
        "benchmarks/CollectMultipledMetrics/{sample}.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "Calling germline SNPs and indels via local re-assembly of haplotypes for {input.bam}"
    shell:
       """ java -Xms5000m -Xmx6500m -jar ../tools/picard.jar \
        CollectMultipleMetrics \
        INPUT={input.bam} \
        REFERENCE_SEQUENCE={input.refgenome} \
        OUTPUT={output.output_bam_prefix} \
        ASSUME_SORTED=true \
        PROGRAM=null \
        PROGRAM=CollectAlignmentSummaryMetrics \
        PROGRAM=CollectGcBiasMetrics \
        METRIC_ACCUMULATION_LEVEL=null \
        METRIC_ACCUMULATION_LEVEL=READ_GROUP && \
        java -Xms5000m -Xmx6500m -jar ../tools/picard.jar \
        CollectMultipleMetrics \
        INPUT={input.bam} \
        REFERENCE_SEQUENCE={input.refgenome} \
        OUTPUT={output.output_bam_prefix2} \
        ASSUME_SORTED=true \
        PROGRAM=null \
        PROGRAM=CollectAlignmentSummaryMetrics \
        PROGRAM=CollectInsertSizeMetrics \
        PROGRAM=CollectSequencingArtifactMetrics \
        PROGRAM=QualityScoreDistribution \
        PROGRAM=CollectGcBiasMetrics \
        METRIC_ACCUMULATION_LEVEL=null \
        METRIC_ACCUMULATION_LEVEL=SAMPLE \
        METRIC_ACCUMULATION_LEVEL=LIBRARY && \
        java -Xms1000m -Xmx3500m -jar ../tools/picard.jar \
        CalculateReadGroupChecksum \
        INPUT={input.bam} \
        OUTPUT={output.read_group_md5_filename} &>log"""
