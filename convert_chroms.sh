#!/bin/bash

in_fn=${1}
CONDITION=${2}

SCRATCH_PREFIX=/net/seq/data/projects/fsv/scratch

slurm_partition=queue0
slurm_cpus_per_task=1
slurm_mem_per_cpu="25G"
slurm_ntasks=1

for chr in `seq 1 22` X Y
do
    chrom="chr${chr}"
    root_out_fn=${in_fn%.*}.${chrom}.HAP1
    out_fn=${PWD}/$(basename ${root_out_fn})
    local_in_fn=${out_fn}.bed
    echo "${chrom} | HAP1 | ${local_in_fn}"
    haplotype_key=H1
    slurm_job_name="convert_fire_${chrom}_${CONDITION}_${haplotype_key}"
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
        ${PWD}/convert_chroms.slurm.sh ${chrom} ${local_in_fn} ${haplotype_key} ${scratch_dir} ${out_fn} ${PWD}

    root_out_fn=${in_fn%.*}.${chrom}.HAP2
    out_fn=${PWD}/$(basename ${root_out_fn})
    local_in_fn=${out_fn}.bed
    echo "${chrom} | HAP2 | ${local_in_fn}"
    haplotype_key=H2
    slurm_job_name="convert_fire_${chrom}_${CONDITION}_${haplotype_key}"
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
        ${PWD}/convert_chroms.slurm.sh ${chrom} ${local_in_fn} ${haplotype_key} ${scratch_dir} ${out_fn} ${PWD}

    root_out_fn=${in_fn%.*}.${chrom}.HAPNA
    out_fn=${PWD}/$(basename ${root_out_fn})
    local_in_fn=${out_fn}.bed
    echo "${chrom} | HAPNA | ${local_in_fn}"
    haplotype_key=UNK
    slurm_job_name="convert_fire_${chrom}_${CONDITION}_${haplotype_key}"
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
        ${PWD}/convert_chroms.slurm.sh ${chrom} ${local_in_fn} ${haplotype_key} ${scratch_dir} ${out_fn} ${PWD}
done
