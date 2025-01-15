rule all:
    input:
        expand("results/{sample}.filtered.vcf", sample=["sample1", "sample2"])

rule index_reference:
    input:
        "reference/GRCh38.p10.genome.fa"
    output:
        "reference/GRCh38.p10.genome.fa.fai"
    shell:
        "samtools faidx {input}"

rule index_bam:
    input:
        bam="data/{sample}.bam"
    output:
        bai="data/{sample}.bam.bai"
    shell:
        "samtools index {input.bam}"

rule variant_calling:
    input:
        bam="data/{sample}.bam",
        bai="data/{sample}.bam.bai",
        ref="reference/GRCh38.p10.genome.fa",
        roi="data/ROI.bed"
    output:
        vcf="results/{sample}.raw.vcf"
    shell:
        """
        bcftools mpileup -f {input.ref} -R {input.roi} {input.bam} | \
        bcftools call -mv -Ov -o {output.vcf}
        """

rule filter_variants:
    input:
        vcf="results/{sample}.raw.vcf"
    output:
        filtered_vcf="results/{sample}.filtered.vcf"
    shell:
        """
        bcftools filter -i 'QUAL>20' {input.vcf} -o {output.filtered_vcf}
        """
