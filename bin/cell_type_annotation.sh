#$ -N annotate_pools
#$ -q short.q
#$ -l mem_requested=50G
#$ -S /bin/bash
#$ -r yes
#$ -cwd 
#$ -o results/2021-10-28_cell_type_annotation
#$ -e results/2021-10-28_cell_type_annotation

# Remove empty pools (no individuals)
# rm results/2021-10-28_cleaned_barcodes/pool_40.RDS
# rm results/2021-10-28_cleaned_barcodes/pool_66.RDS
#
# mkdir results/2021-10-28_cell_type_annotation
# qsub -t 1-75 bin/cell_type_annotation.sh

cd $SGE_O_WORKDIR

# Set environmental variables
input=results/2021-10-28_cleaned_barcodes
output=results/2021-10-28_cell_type_annotation

# Get job info
echo "JOB: $JOB_ID TASK: $SGE_TASK_ID HOSTNAME: $HOSTNAME"

# Get basefile name
files=($(ls ${input} | grep ".RDS"))
i="$(($SGE_TASK_ID-1))"

filename=${files[$i]}
filename=$(echo $filename | sed 's/.RDS//')

echo "Running for: $filename"

# Run main command
singularity run -B $SGE_O_WORKDIR bin/azimuth.sif --file ${input}/${filename}.RDS --out ${output}/${filename}_out