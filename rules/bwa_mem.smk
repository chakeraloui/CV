rule bwa_mem:
    input:
        fastq = get_input_fastq,
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME']),
        ubam="unmapped_bams/{sample}_unmapped.bam"
    output: 
        bam2=temp("aligned_reads/{sample}_aligned_unsorted.bam"),
        bam=temp("aligned_reads/{sample}_aligned_unsorted_merged.bam") 
    params:
        readgroup = "'@RG\\tID:{sample}_rg1\\tLB:lib1\\tPL:bar\\tSM:{sample}\\tPU:{sample}_rg1'",
        #readgroup =  "'@RG\tID:{sample}\tPL:ILLUMINA\tSM:{sample}'" ,
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']),
        sortsam = "--INPUT /dev/stdin --SORT_ORDER coordinate --MAX_RECORDS_IN_RAM 400000  ",
        tdir = expand("{tdir}", tdir = config['TEMPDIR'])
        #bwa_command="bwa mem -M -t {threads} -K 10000000 -R {input.refgenome} {output.bam3} "
    log:
        "logs/bwa_mem/{sample}.log"
    benchmark:
        "benchmarks/bwa_mem/{sample}.tsv"
    conda:
        "../envs/bwa.yaml"
    threads: config['THREADS']
    message:
        "Mapping sequences against a reference human genome with BWA-MEM for {input.fastq}"
    shell:
         """bwa mem -M -t {threads} -K 10000000 -R {params.readgroup} {input.refgenome} {input.fastq} > {output.bam2} \
         && \
         java -Dsamjdk.compression_level=2 -Xms10g -Xmx50g -jar ../tools/picard.jar \
         MergeBamAlignment \
         --ALIGNED {output.bam2} \
         --UNMAPPED {input.ubam} \
         --OUTPUT {output.bam} \
         --REFERENCE_SEQUENCE {input.refgenome} \
         --VALIDATION_STRINGENCY SILENT \
         --EXPECTED_ORIENTATIONS FR \
         --ATTRIBUTES_TO_RETAIN X0 \
         --ATTRIBUTES_TO_REMOVE NM \
         --ATTRIBUTES_TO_REMOVE MD \
         --SORT_ORDER "unsorted" \
         --IS_BISULFITE_SEQUENCE false \
         --ALIGNED_READS_ONLY false \
         --CLIP_ADAPTERS false \
         --CLIP_OVERLAPPING_READS true \
         --CLIP_OVERLAPPING_READS_OPERATOR H \
         --MAX_RECORDS_IN_RAM 2000000 \
         --ADD_MATE_CIGAR true \
         --MAX_INSERTIONS_OR_DELETIONS -1 \
         --PRIMARY_ALIGNMENT_STRATEGY MostDistant \
         --PROGRAM_RECORD_ID "bwamem" \
         --PROGRAM_GROUP_VERSION "0.7.17" \
         --PROGRAM_GROUP_COMMAND_LINE "" \
         --PROGRAM_GROUP_NAME "bwamem" \
         --UNMAPPED_READ_STRATEGY COPY_TO_TAG \
         --ALIGNER_PROPER_PAIR_FLAGS true \
         --UNMAP_CONTAMINANT_READS true \
         --ADD_PG_TAG_TO_READS false \
         >{log}.bwa {log}.merge 2>&1"""
