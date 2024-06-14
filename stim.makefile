SHELL=/bin/bash
LOCAL_PREFIX=d2_stim_sequel.fire.all
D2_STIM_FIRE_BED=/net/seq/pacbio/fiberseq_processing/fiberseq/fire_analysis_v0.0.2/fiberseq_fire_v_0.0.4/results/d2_stim_sequel/fire/d2_stim_sequel.fire.all.bed
D2_STIM_FIRE_CHRX_BED=d2_stim_sequel.fire.all.chrX.bed
D2_STIM_FIRE_CHRX_SORTED_BED=d2_stim_sequel.fire.all.chrX.sorted.bed
D2_STIM_FIRE_CHRX_SORTED_H1_BED=d2_stim_sequel.fire.all.chrX.sorted.H1.bed
S3_DEST_URL=s3://areynolds-us-west-2/cd3plus/052524/fire-bam/

all:

# extract_chrX:
#	 module add bedops && bedextract chrX ${D2_STIM_FIRE_BED} > ${D2_STIM_FIRE_CHRX_BED} && module remove bedops

# sort_chrX:
#	 module add bedops && sort-bed --max-mem 4G --tmpdir ${TMPDIR} ${D2_STIM_FIRE_CHRX_BED} > ${D2_STIM_FIRE_CHRX_SORTED_BED}

# h1_chrX:
# 	awk -vFS='\t' -vOFS='\t' '($$11=="H1")' ${D2_STIM_FIRE_CHRX_SORTED_BED} > ${D2_STIM_FIRE_CHRX_SORTED_H1_BED}

extract:
	${PWD}/extract_chroms.sh ${D2_STIM_FIRE_BED} stim

convert:
	${PWD}/convert_chroms.sh ${D2_STIM_FIRE_BED} stim

upload:
#	aws s3 cp --dryrun . ${S3_DEST_URL} --recursive --exclude "*" --include "${LOCAL_PREFIX}.chr*.HAP*.bam"
#	aws s3 cp --dryrun . ${S3_DEST_URL} --recursive --exclude "*" --include "${LOCAL_PREFIX}.chr*.HAP*.bam.bai"
	aws s3 cp . ${S3_DEST_URL} --recursive --exclude "*" --include "${LOCAL_PREFIX}.chr*.HAP*.bam"
	aws s3 cp . ${S3_DEST_URL} --recursive --exclude "*" --include "${LOCAL_PREFIX}.chr*.HAP*.bam.bai"
