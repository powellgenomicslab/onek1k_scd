#$ -N annotate_pools
#$ -q short.q
#$ -l mem_requested=16G
#$ -cwd
#$ -S /bin/bash
#$ -r yes
#$ -M j.alquicira@garvan.org.au
#$ -m ae

# qsub -t 1-3 ../../bin/pre-qc_annotate.qsub.sh

# Set up environment
conda activate r-4.1.1

# Set environmental variables
input=../2021-10-26_raw_seurat_objects

# Get job info
echo "JOB: $JOB_ID TASK: $SGE_TASK_ID"
echo "$HOSTNAME $tmp_requested $TMPDIR"

# Get basefile name

files=($(ls ${input}))
i="$(($JOB_ID-1))"

filename=${files[$i]}

echo "Running for: $filename"

# Run main command
singularity run -B $PWD ../../bin/azimuth.sif --file ${input}/${filename}.RDS --out ${filename}_out