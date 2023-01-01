rule SortSam:
    input:
        bam = "aligned_reads/{sample}_unsorted_mkdups.bam"
    output:
        bam = "aligned_reads/{sample}_sorted_mkdups.bam",
        mapped_bam_readgroup="aligned_reads/{sample}_mapped_bam.readgroup"
    conda:
        "../envs/picard.yaml"
    log:
        "logs/SortSam/{sample}.log"
    message:
        "Compiling a HTML report for quality control checks on raw sequence data"
    shell:
        """java -Dsamjdk.compression_level=2 -Xms10000m -Xmx30000m -jar ../tools/picard.jar \
        SortSam \
        INPUT={input.bam} \
        OUTPUT={output.bam} \
        SORT_ORDER="coordinate" \
        CREATE_INDEX=true \
        CREATE_MD5_FILE=true \
        MAX_RECORDS_IN_RAM=300000 &>{log}"""
