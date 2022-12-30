rule SamToFastqAndBwaMemAndMba:
    input:
        ubam = "unmapped_bams/{sample}_unmapped.bam",
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME'])
    output: 
        bam ="aligned_reads/{sample}_aligned.unsorted.bam",
        fastq1="unmapped_bams/{sample}_R1.fastq.gz",
        fastq2="unmapped_bams/{sample}_R2.fastq.gz"
    params:
        readgroup = "'@RG\\tID:{sample}_rg1\\tLB:lib1\\tPL:bar\\tSM:{sample}\\tPU:{sample}_rg1'",
        #readgroup =  "'@RG\tID:{sample}\tPL:ILLUMINA\tSM:{sample}'" ,
        sample_name="{sample}",
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']),
        sortsam = "--INPUT /dev/stdin --SORT_ORDER coordinate --MAX_RECORDS_IN_RAM 400000  ",
        tdir = expand("{tdir}", tdir = config['TEMPDIR']),
        bwa_commandline="bwa mem -K 100000000 -p -v 3 -t 6 -Y {input.refgenome}",
        compression_level ="2",
        BWA_VERSION="0.7.17"
    log:
        "logs/bwa_mem/{sample}.log"
    benchmark:
        "benchmarks/bwa_mem/{sample}.tsv"
    conda:
        "../envs/bwa.yaml"
    threads: config['THREADS']
    message:
        "Mapping sequences against a reference human genome with BWA-MEM for {input.ubam}"
    shell:
         """java -Xms20G -Xmx50G -jar ../tools/picard.jar SamToFastq \
         INPUT = {input.ubam} \
         FASTQ = {output.fastq1} \
         SECOND_END_FASTQ = {output.fastq2}\
         INTERLEAVE = true \
         NON_PF=true &>{log}"""