rule FastqToSam:
    input:
        fastq1  = expand("../test/{sample}_R1.fastq.gz", sample = SAMPLES), 
        fastq2  = expand("../test/{sample}_R2.fastq.gz", sample = SAMPLES)
        
    output:
        ubam="unmapped_bams/{sample}_unmapped.bam",
        yield_metrics = "aligned_reads/{sample}_unmapped_quality_yield_metrics"
    params:
        sample_name="{sample}",
        readgroup_name="{sample}_rg1",
        run_date="2022-12-29"
    log:
        "logs/FastqToSam/{sample}.log"
    benchmark:
        "benchmarks/FastqToSam/{sample}.tsv"
    threads:  config['THREADS']
    conda:
        "./envs/FastqToSam.yaml"
    message:
        "Converting {params.sample_name}FASTQ file to an unaligned BAM  ({output.ubam})"
    shell:
     """gatk   -Xmx50G FastqToSam \
     --FASTQ {input.fastq1}  \
     --FASTQ2 {input.fastq2}  \
     --OUTPUT {output.ubam}  \
     --READ_GROUP_NAME {params.readgroup_name} \
     --SAMPLE_NAME  {params.sample_name}   \
     --LIBRARY_NAME Solexa-NA12878     \
     --PLATFORM_UNIT H06HDADXX130110.2.ATCACGAT  \
     --RUN_DATE {params.run_date}  \
     --PLATFORM illumina  \
     --SEQUENCING_CENTER BI && \
     java -Xms2000m -Xmx3000m       -jar ../tools/picard.jar     CollectQualityYieldMetrics    \
     INPUT={output.ubam}  \
     OQ=true     \
     OUTPUT={output.yield_metrics}&> {log}"""
