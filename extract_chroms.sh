#!/bin/bash

in_gz_fn=${1}
out_bed_fn=${2}
CONDITION=${3}

SCRATCH_PREFIX=/net/seq/data/projects/fsv/scratch

slurm_partition=queue1
slurm_cpus_per_task=1
slurm_mem_per_cpu="10G"
slurm_ntasks=1

if [[ ! -e ${in_gz_fn} ]]
then
    echo "Error: Cannot find ${in_gz_fn}"
    exit -1
fi

gunzip -c ${in_gz_fn} > ${out_bed_fn}

for chr in `seq 1 22` X Y
do
    haplotype_key=UNK
    chrom="chr${chr}"
    root_out_fn=${out_bed_fn%.*}.${chrom}.${haplotype_key}.bed
    out_fn=${PWD}/$(basename ${root_out_fn})
    echo "${chrom} | ${out_fn} | ${haplotype_key}"
    # bedextract ${chrom} ${in_fn} | awk -vFS="\t" -vOFS="\t" '($11=="H1")' | sort-bed --max-mem 8G --tmpdir ${SCRATCH} - > ${out_fn}
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
        ${PWD}/extract_chroms.slurm.sh ${chrom} ${out_bed_fn} ${haplotype_key} ${scratch_dir} ${out_fn}
done
