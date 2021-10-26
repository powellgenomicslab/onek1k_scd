#$ -N  integrate_pools
#$ -q short.q
#$ -l mem_requested=16G
#$ -o results/2021-10-26_pre-qc_annotation
#$ -e results/2021-10-26_pre-qc_annotation
#$ -cwd
#$ -S /bin/bash
#$ -r yes
#$ -M j.alquicira@garvan.org.au
#$ -m ae

# Set up environment
conda activate r-4.1.1

# Set environmental variables
input=results/2021-10-26_raw_seurat_objects

# Get job info
echo "JOB: $JOB_ID TASK: $SGE_TASK_ID"
echo "$HOSTNAME $tmp_requested $TMPDIR"

# Get basefile name

files=($(ls ${input}))

filename=${files[$i]}

# Run main command
singularity run -B $PWD bin/azimuth.sif --file ${input}/${filename}.RDS --out ${filename}_out