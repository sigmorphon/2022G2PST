#!/bin/bash
# SGE script for evaluating CLUZH baselines for language pairs (8)
# This script uses the uncovered test data for scoring
# should be run after the train_ensemble_CLUZH_<data setting>.sh scripts
# Peter Makarov and Simon Clematide. 2020.
# CLUZH at SIGMORPHON 2020 Shared Task on Multilingual Grapheme-to-Phoneme Conversion.
# In Proceedings of the 17th SIGMORPHON Workshop on Computational Research in Phonetics,
# Phonology, and Morphology, pages 171–176, Online.
# Association for Computational Linguistics.
# https://aclanthology.org/2020.sigmorphon-1.19/

#$ -cwd
#$ -N CLUZH-eval
#$ -j y -o $JOB_NAME-$JOB_ID.$TASK_ID.out
#$ -l ram_free=5G,mem_free=5G
#$ -t 1

LANGS=( "ben" "ger" "ita" "per" "swe" "tgl" "tha" "ukr" )
DATA_SETTINGS=( "high" "low" "mixed" )
LANG=${LANGS[(( SGE_TASK_ID - 1))]}

# Environment variable SIGMORPHON points to code repo (same as GitHub)
CODE_DIR="${SIGMORPHON}"
DATA_TARGET="${SIGMORPHON}/data/target_languages"
OUTPUT_BASE="${SIGMORPHON}/results"

# Activate conda environment
conda activate sigmorphon

# Experiment settings
BEAM_WIDTH=4
MAX_ENSEMBLE_SIZE=10

# For each data setting subtask
for SETTING in "${DATA_SETTINGS[@]}"
do
  # Ensemble models
  OUTPUT="${OUTPUT_BASE}/${SETTING}/${LANG}/ensemble"
  python "${CODE_DIR}/baseline/trans/ensembling.py" \
    --gold "${DATA_TARGET}/${LANG}_dev.tsv" \
    --systems "${OUTPUT_BASE}/${SETTING}/${LANG}/"*"/dev_beam${BEAM_WIDTH}.predictions" \
    --output "${OUTPUT}"

  # Dev score
  # Create two-column TSV with gold and hypothesis data
  paste \
      "${DATA_TARGET}/${LANG}_dev.tsv" \
      "${OUTPUT_BASE}/${SETTING}/${LANG}/ensemble/dev_${MAX_ENSEMBLE_SIZE}ensemble.predictions" \
      | cut -f2,4 \
      > "${OUTPUT_BASE}/${SETTING}/${LANG}/ensemble/dev_${MAX_ENSEMBLE_SIZE}ensemble.tsv"

  # Repeat for test
  python "${CODE_DIR}/baseline/trans/ensembling.py" \
    --gold "${DATA_TARGET}/${LANG}_test.tsv.private" \
    --systems "${OUTPUT_BASE}/${SETTING}/${LANG}/"*"/test_beam${BEAM_WIDTH}.predictions" \
    --output "${OUTPUT}"

  paste \
      "${DATA_TARGET}/${LANG}_test.tsv.private" \
      "${OUTPUT_BASE}/${SETTING}/${LANG}/ensemble/test_${MAX_ENSEMBLE_SIZE}ensemble.predictions" \
      | cut -f2,4 \
      > "${OUTPUT_BASE}/${SETTING}/${LANG}/ensemble/test_${MAX_ENSEMBLE_SIZE}ensemble.tsv"

done
echo "Done ensembling"

# Use the last task to evaluate the models
if [ "${SGE_TASK_ID}" -eq "${SGE_TASK_LAST}" ]
then
  # Ensure that last task ID is the last task to finish
  while [ "$(qstat -u ${USER} | grep -c ${JOB_ID})" -ne 1 ]
  do
      # Wait patiently
      sleep 20
  done

for SETTING in "${DATA_SETTINGS[@]}"
do
  echo "Dev ${SETTING}:"
  python "${CODE_DIR}/evaluation/evaluate_all.py" \
      "${OUTPUT_BASE}/${SETTING}/"*"/ensemble/dev_${MAX_ENSEMBLE_SIZE}ensemble.tsv"
  echo

  echo "Test ${SETTING}:"
  python "${CODE_DIR}/evaluation/evaluate_all.py" \
      "${OUTPUT_BASE}/${SETTING}/"*"/ensemble/test_${MAX_ENSEMBLE_SIZE}ensemble.tsv"
  echo
done

fi

echo "Done done"
