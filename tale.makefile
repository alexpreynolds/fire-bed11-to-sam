SHELL=/bin/bash
CELL_TYPE=hudep
CONDITION=tale
LOCAL_PREFIX=${CELL_TYPE}_${CONDITION}.fire
FIRE_BED_GZ=/net/seq/pacbio/fiberseq_processing/fiberseq/fire_analysis_v0.0.2/fiberseq_fire_v_0.0.4/results/Mutant_A11_TALE_Expressing/fiber-calls/FIRE.bed.gz
FIRE_BED=${PWD}/${LOCAL_PREFIX}.bed
S3_DEST_URL=s3://areynolds-us-west-2/${CELL_TYPE}/052524/fire-bam/

all:

extract:
	${PWD}/extract_chroms.sh ${FIRE_BED_GZ} ${FIRE_BED} ${CONDITION}

convert:
	${PWD}/convert_chroms.sh ${FIRE_BED} ${CONDITION}

upload:
	aws s3 cp --dryrun . ${S3_DEST_URL} --recursive --exclude "*" --include "${LOCAL_PREFIX}.chr*.HAP*.bam"
	aws s3 cp --dryrun . ${S3_DEST_URL} --recursive --exclude "*" --include "${LOCAL_PREFIX}.chr*.HAP*.bam.bai"

upload-real:
	aws s3 cp . ${S3_DEST_URL} --recursive --exclude "*" --include "${LOCAL_PREFIX}.chr*.HAP*.bam"
	aws s3 cp . ${S3_DEST_URL} --recursive --exclude "*" --include "${LOCAL_PREFIX}.chr*.HAP*.bam.bai"
