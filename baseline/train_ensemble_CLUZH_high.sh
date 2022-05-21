#!/bin/bash
# SGE script for training CLUZH baselines for language pairs (8)
# Peter Makarov and Simon Clematide. 2020.
# CLUZH at SIGMORPHON 2020 Shared Task on Multilingual Grapheme-to-Phoneme Conversion.
# In Proceedings of the 17th SIGMORPHON Workshop on Computational Research in Phonetics,
# Phonology, and Morphology, pages 171–176, Online.
# Association for Computational Linguistics.
# https://aclanthology.org/2020.sigmorphon-1.19/

#$ -cwd
#$ -N CLUZH-high
#$ -j y -o $JOB_NAME-$JOB_ID.$TASK_ID.out
#$ -l ram_free=1G,mem_free=1G
#$ -pe smp 10
#$ -t 1

LANGS=( "ben" "ger" "ita" "per" "swe" "tgl" "tha" "ukr" "gle" "bur" )
LANG=${LANGS[(( SGE_TASK_ID - 1))]}
SETTING="high"

# Environment variable SIGMORPHON points to code repo (same as GitHub)
CODE_DIR="${SIGMORPHON}"
DATA_TARGET="${SIGMORPHON}/data/target_languages"
OUTPUT_BASE="${SIGMORPHON}/results"
mkdir -p "${OUTPUT_BASE}"

# Activate conda environment
conda activate sigmorphon

# Experiment settings
BEAM_WIDTH=4
EPOCHS=60
PATIENCE=12
SED_EM_ITERATIONS=10
MAX_ENSEMBLE_SIZE=10
HIDDEN_DIM=100

# Train MAX_ENSEMBLE_SIZE models
for ENSEMBLE_SIZE in $(seq 1 "${MAX_ENSEMBLE_SIZE}"); do
  OUTPUT="${OUTPUT_BASE}/${SETTING}/${LANG}/${ENSEMBLE_SIZE}"
  mkdir -p "${OUTPUT}"

  python "${CODE_DIR}/baseline/trans/train.py" \
    --dynet-seed "${ENSEMBLE_SIZE}" \
    --output "${OUTPUT}" \
    --train "${DATA_TARGET}/${LANG}_train.tsv" \
    --dev "${DATA_TARGET}/${LANG}_dev.tsv" \
    --test "${DATA_TARGET}/${LANG}_test.tsv" \
    --sed-em-iterations "${SED_EM_ITERATIONS}" \
    --enc-hidden-dim "${HIDDEN_DIM}" \
    --dec-hidden-dim "${HIDDEN_DIM}" \
    --epochs "${EPOCHS}" \
    --beam-width "${BEAM_WIDTH}" \
    --patience "${PATIENCE}" \
    --nfd &

done
wait
echo "Done training"

# Check exit status
if [ $? -ne 0 ]
then
    echo "Task ${SGE_TASK_ID} failed on ${SETTING} with language ${LANG}"
fi

# Ensemble models
OUTPUT="${OUTPUT_BASE}/${SETTING}/${LANG}/ensemble"
mkdir -p "${OUTPUT}"
for SPLIT in "dev" "test"
do
    python "${CODE_DIR}/baseline/trans/ensembling.py" \
      --gold "${DATA_TARGET}/${LANG}_${SPLIT}.tsv" \
      --systems "${OUTPUT_BASE}/${SETTING}/${LANG}/"*"/${SPLIT}_beam${BEAM_WIDTH}.predictions" \
      --output "${OUTPUT}"
done
echo "Done ensembling"

# Evaluate ensemble model
# Create two-column TSV with gold and hypothesis data
for SPLIT in "dev" "test"
do
    paste \
        "${DATA_TARGET}/${LANG}_${SPLIT}.tsv" \
        "${OUTPUT_BASE}/${SETTING}/${LANG}/ensemble/${SPLIT}_${MAX_ENSEMBLE_SIZE}ensemble.predictions" \
        | cut -f2,4 \
        > "${OUTPUT_BASE}/${SETTING}/${LANG}/ensemble/${SPLIT}_${MAX_ENSEMBLE_SIZE}ensemble.tsv"
done

echo "Done"

# Use the last task to evaluate the models
if [ "${SGE_TASK_ID}" -eq "${SGE_TASK_LAST}" ]
then
  # Ensure that last task ID is the last task to finish
  while [ "$(qstat -u ${USER} | grep -c ${JOB_ID})" -ne 1 ]
  do
      # Wait patiently
      sleep 20
  done

  # Evaluate
  for SPLIT in "dev" "test"
  do
      echo "${SPLIT} ${SETTING}:"
      python "${CODE_DIR}/evaluation/evaluate_all.py" \
          "${OUTPUT_BASE}/${SETTING}/"*"/ensemble/${SPLIT}_${MAX_ENSEMBLE_SIZE}ensemble.tsv"
      echo
  done

fi

echo "Done done"
