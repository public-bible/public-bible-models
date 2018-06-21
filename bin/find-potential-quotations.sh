#!/bin/bash
#SBATCH --job-name=find-quotations
#SBATCH --output="/scratch/lmullen/logs/find-quotations-%A_%a.out"
#SBATCH --mail-type=ALL
#SBATCH --mail-user=lmullen@gmu.edu
#SBATCH --partition=all-HiPri
#SBATCH --mem-per-cpu=12G
#SBATCH --export=NONE
##SBATCH --array=1-1586%20
#SBATCH --array=1-5%5

## Load modules since we are not exporting our environment
module load R/3.4.4

## Get the file name associated with that line of the list of files
BATCH_LIST=/home/lmullen/public-bible/bin/newspaper-batches.txt
BATCH=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $BATCH_LIST)
INPUT=/scratch/lmullen/newspaper-batches/$BATCH.fst
OUTPUT=/scratch/lmullen/argo-out/quotations/$BATCH-quotations.fst

## Run the executable only if output does not exist
echo "Job details: BATCH=$BATCH TASKID: $SLURM_ARRAY_TASK_ID"
echo "Input files is $INPUT"
if [ -f "$OUTPUT" ]; then
  echo "SKIPPED: Not running task because $OUTPUT already exists"
else
  echo "RUNNING: Starting script to create $OUTPUT"
  Rscript /home/lmullen/public-bible/bin/find-potential-quotations.R \
    $INPUT \
    --bible=/home/lmullen/public-bible/bin/bible-payload.rda \
    --tokens=3 --tfidf=1.5 \
    -o $OUTPUT && \
  echo "FINISHED: Finished script to create $OUTPUT"
fi
