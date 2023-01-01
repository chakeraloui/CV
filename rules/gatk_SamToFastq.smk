rule SamToFastq:
    input:
        ubam="unmapped_bams/{sample}_unmapped.bam"
        
    output:
        fastq1 = "unmapped_bams/{sample}_R1.fastq.gz",
        fastq2 = "unmapped_bams/{sample}_R2.fastq.gz"
        
    params:
         
    log:
        "logs/fastqtosam/{sample}.log"
    benchmark:
        "benchmarks/fastqtosam/{sample}.tsv"
    threads:  config['THREADS']
    conda:
        "./envs/fastqc.yaml"
    message:
        "Undertaking quality control checks on raw sequence data for {input.ubam}"
    shell:
        """java -Xms10g -Xmx50g -jar ../tools/picard.jar \
        SamToFastq \
        --INPUT {input.ubam} \
        --FASTQ {output.fastq1} \
        --SECOND_END_FASTQ {output.fastq2} \
        --INTERLEAVE true \
        -NON_PF true" &>{log}"""
