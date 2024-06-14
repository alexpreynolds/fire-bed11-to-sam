#!/bin/bash

chrom=${1}
in_fn=${2}
haplotype_key=${3}
scratch_dir=${4}
out_fn=${5}

module add bedops

bedextract ${chrom} ${in_fn} | awk -vFS="\t" -vOFS="\t" -vHAP=${haplotype_key} '($11==HAP)' | sort-bed --max-mem 8G --tmpdir ${scratch_dir} - > ${out_fn}

