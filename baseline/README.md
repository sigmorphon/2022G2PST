# Baseline

This year's baseline is an ensembled neural transition system based on the
imitation learning paradigm introduced by Makarov & Clematide (2020). 
This is a slightly modified baseline from the 2021 shared task (Ashby et al. 2021).


## How to use

1. The baseline requires Python 3.7. If your system does not use Python 3.7 by
    default (i.e., see `python --version` for your default Python), create and
    activate either:

    -   a [3.7 virtualenv](https://virtualenv.pypa.io/en/latest/):

    ```bash
    virtualenv --python=python3.7 sigmorphon
    source sigmorphon/bin/activate
    ```

    -   or a [3.7 Conda environment](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-python.html#installing-a-different-version-of-python):

    ```bash
    conda create --name=sigmorphon python=3.7
    conda activate sigmorphon
    ```

2. Install the requirements and the library itself:

    ```bash
    pip install --upgrade pip
    pip install -r requirements.txt
    pip install .
    ```

3. Train the ensemble models for each target language and data setting subtask. Low, mixed, and high refer to the 100
The provided bash scripts are for an SGE job scheduling environment, but can be modified to use a for-loop instead.
Training may take a while depending on the model settings.

    ```bash
   qsub train_ensemble_CLUZH_low.sh
   qsub train_ensemble_CLUZH_mixed.sh
   qsub train_ensemble_CLUZH_high.sh
    ```

## License

The baseline is made available under the [Apache 2.0](LICENSE.txt) license.

## References

Makarov, P., and Clematide, S. 2020. [CLUZH at SIGMORPHON 2020 shared task on
multilingual grapheme-to-phoneme
conversion](https://www.aclweb.org/anthology/2020.sigmorphon-1.19/). In
*Proceedings of the 17th SIGMORPHON Workshopon Computational Research in
Phonetics, Phonology, and Morphology*, pages 171-176.
