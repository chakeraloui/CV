rule FastqToSam:
    input:
        fastq1  ="../test/{sample}_R1.fastq.gz",
        fastq2  = "../test/{sample}_R2.fastq.gz"
        
    output:
        ubam="unmapped_bams/{sample}_unmapped.bam"
    params:
        readgroup_name="{sample}_rg1",
        command_mem_gb="--java-options -Xmx10g",
        sample_name="{sample}",
        run_date="2022-12-29"
    log:
        "logs/FastqToSam/{sample}.log"
    benchmark:
        "benchmarks/FastqToSam/{sample}.tsv"
    threads:  config['THREADS']
    conda:
        "./envs/FastqToSam.yaml"
    message:
        "Converting {sample} FASTQ file to an unaligned BAM  ({output.ubam})"
    shell:
     "gatk   {params.command_mem_gb} FastqToSam --FASTQ {input.fastq1}  --FASTQ2 {input.fastq2}  --OUTPUT {output.ubam}  --READ_GROUP_NAME {params.readgroup_name}  --SAMPLE_NAME  {params.sample_name}   --LIBRARY_NAME Solexa-NA12878     --PLATFORM_UNIT H06HDADXX130110.2.ATCACGAT  --RUN_DATE {params.run_date}  --PLATFORM illumina  --SEQUENCING_CENTER BI &> {log}"
