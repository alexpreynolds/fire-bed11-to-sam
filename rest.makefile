SHELL=/bin/bash
LOCAL_PREFIX=d2_rest_sequel.fire.all
D2_REST_FIRE_BED=/net/seq/pacbio/fiberseq_processing/fiberseq/fire_analysis_v0.0.2/fiberseq_fire_v_0.0.4/results/d2_rest_sequel/fire/d2_rest_sequel.fire.all.bed
S3_DEST_URL=s3://areynolds-us-west-2/cd3plus/052524/fire-bam/

all:

extract:
	${PWD}/extract_chroms.sh ${D2_REST_FIRE_BED} rest

convert:
	${PWD}/convert_chroms.sh ${D2_REST_FIRE_BED} rest

upload:
	aws s3 cp --dryrun . ${S3_DEST_URL} --recursive --exclude "*" --include "${LOCAL_PREFIX}.chr*.HAP*.bam"
	aws s3 cp --dryrun . ${S3_DEST_URL} --recursive --exclude "*" --include "${LOCAL_PREFIX}.chr*.HAP*.bam.bai"

upload-real:
	aws s3 cp . ${S3_DEST_URL} --recursive --exclude "*" --include "${LOCAL_PREFIX}.chr*.HAP*.bam"
	aws s3 cp . ${S3_DEST_URL} --recursive --exclude "*" --include "${LOCAL_PREFIX}.chr*.HAP*.bam.bai"
