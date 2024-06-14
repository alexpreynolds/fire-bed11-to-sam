#!/bin/bash

in_fn=${1}
CONDITION=${2}

SCRATCH_PREFIX=/net/seq/data/projects/fsv/scratch

slurm_partition=queue1
slurm_cpus_per_task=1
slurm_mem_per_cpu="10G"
slurm_ntasks=1

for chr in `seq 1 22` X Y
do
    chrom="chr${chr}"
    root_out_fn=${in_fn%.*}.${chrom}.HAP1.bed
    out_fn=${PWD}/$(basename ${root_out_fn})
    echo "${chrom} | HAP1"
    # bedextract ${chrom} ${in_fn} | awk -vFS="\t" -vOFS="\t" '($11=="H1")' | sort-bed --max-mem 8G --tmpdir ${SCRATCH} - > ${out_fn}
    haplotype_key=H1
    slurm_job_name="extract_fire_${chrom}_${CONDITION}_${haplotype_key}"
    slurm_out=${PWD}/${slurm_job_name}.out
    slurm_err=${PWD}/${slurm_job_name}.err
    scratch_dir=${SCRATCH_PREFIX}/${haplotype_key}/${chrom}
    mkdir -p ${scratch_dir}
    sbatch \
        --partition=${slurm_partition} \
        --cpus-per-task=${slurm_cpus_per_task} \
        --ntasks=${slurm_ntasks} \
        --mem-per-cpu=${slurm_mem_per_cpu} \
        --job-name=${slurm_job_name} \
        -o ${slurm_out} \
        -e ${slurm_err} \
        ${PWD}/extract_chroms.slurm.sh ${chrom} ${in_fn} ${haplotype_key} ${scratch_dir} ${out_fn}
    root_out_fn=${in_fn%.*}.${chrom}.HAP2.bed
    out_fn=${PWD}/$(basename ${root_out_fn})
    echo "${chrom} | HAP2"
    # bedextract ${chrom} ${in_fn} | awk -vFS="\t" -vOFS="\t" '($11=="H2")' | sort-bed --max-mem 8G --tmpdir ${SCRATCH} - > ${out_fn
    haplotype_key=H2
    slurm_job_name="extract_fire_${chrom}_${CONDITION}_${haplotype_key}"
    slurm_out=${PWD}/${slurm_job_name}.out
    slurm_err=${PWD}/${slurm_job_name}.err
    scratch_dir=${SCRATCH_PREFIX}/${haplotype_key}/${chrom}
    mkdir -p ${scratch_dir}
    sbatch \
        --partition=${slurm_partition} \
        --cpus-per-task=${slurm_cpus_per_task} \
        --ntasks=${slurm_ntasks} \
        --mem-per-cpu=${slurm_mem_per_cpu} \
        --job-name=${slurm_job_name} \
        -o ${slurm_out} \
        -e ${slurm_err} \
        ${PWD}/extract_chroms.slurm.sh ${chrom} ${in_fn} ${haplotype_key} ${scratch_dir} ${out_fn}
    root_out_fn=${in_fn%.*}.${chrom}.HAPNA.bed
    out_fn=${PWD}/$(basename ${root_out_fn})
    echo "${chrom} | HAPNA"
    # bedextract ${chrom} ${in_fn} | awk -vFS="\t" -vOFS="\t" '($11=="UNK")' | sort-bed --max-mem 8G --tmpdir ${SCRATCH} - > ${out_fn
    haplotype_key=UNK
    slurm_job_name="extract_fire_${chrom}_${CONDITION}_${haplotype_key}"
    slurm_out=${PWD}/${slurm_job_name}.out
    slurm_err=${PWD}/${slurm_job_name}.err
    scratch_dir=${SCRATCH_PREFIX}/${haplotype_key}/${chrom}
    mkdir -p ${scratch_dir}
    sbatch \
        --partition=${slurm_partition} \
        --cpus-per-task=${slurm_cpus_per_task} \
        --ntasks=${slurm_ntasks} \
        --mem-per-cpu=${slurm_mem_per_cpu} \
        --job-name=${slurm_job_name} \
        -o ${slurm_out} \
        -e ${slurm_err} \
        ${PWD}/extract_chroms.slurm.sh ${chrom} ${in_fn} ${haplotype_key} ${scratch_dir} ${out_fn}
done
