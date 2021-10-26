#$ -N annotate_pools
#$ -q short.q
#$ -l mem_requested=16G
#$ -S /bin/bash
#$ -r yes
#$ -M j.alquicira@garvan.org.au
#$ -m ae
#$ -cwd 
#$ -o results/2021-10-26_pre-qc_annotation
#$ -e results/2021-10-26_pre-qc_annotation

# qsub -t 1-3 bin/pre-qc_annotate.qsub.sh

cd $SGE_O_WORKDIR

# Set up environment
conda activate r-4.1.1

# Set environmental variables
input=results/2021-10-26_raw_seurat_objects
output=results/2021-10-26_pre-qc_annotation

# Get job info
echo "JOB: $JOB_ID TASK: $SGE_TASK_ID HOSTNAME: $HOSTNAME"

# Get basefile name
files=($(ls ${input}))
i="$(($JOB_ID-1))"

echo "i = $i"

filename=${files[$i]}

echo "Running for: $filename"

# Run main command
#singularity run -B $SGE_O_WORKDIR bin/azimuth.sif --file ${input}/${filename}.RDS --out ${output}/${filename}_out