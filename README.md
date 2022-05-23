# 2022G2PST

The task website is at [https://sigmorphon.github.io/2022G2PST](https://sigmorphon.github.io/2022G2PST/) and GitHub repo is at [https://github.com/sigmorphon/2022G2PST](https://github.com/sigmorphon/2022G2PST).

# Task 1: Third SIGMORPHON Shared Task on Grapheme-to-Phoneme Conversion (Low-Resource and Cross-Lingual)

In this task, participants will create computational models that map a sequence
of "graphemes"&mdash;characters&mdash;representing a word to a transcription of that
word's pronunciation. This task is an important part of speech technologies,
including recognition and synthesis. This is the second iteration of this task.

Please sign up for the mailing list 
[here](https://groups.google.com/u/0/g/sigmorphon-2022-g2p) by
clicking the button labeled "Ask to join group".

## Data

### Source

The data is extracted from the English-language portion of
[Wiktionary](https://en.wiktionary.org/) using
[WikiPron](https://github.com/kylebgorman/wikipron) (Lee et al. 2020), then
filtered and downsampled using proprietary techniques. Morphological data comes from [UniMorph](https://unimorph.github.io).

### Format

Training and development data are UTF-8-encoded tab-separated values files. Each
example occupies a single line and consists of a grapheme sequence&mdash;a sequence
of [NFC](https://en.wikipedia.org/wiki/Unicode_equivalence#Normal_forms) Unicode
codepoints&mdash;a tab character, and the corresponding phone sequence, a
roughly-phonemic IPA, tokenized using the
[`segments`](https://github.com/cldf/segments) library. The following shows
three lines of Romanian data:

    antonim a n t o n i m
    ploaie  p lʷ a j e
    pornește    p o r n e ʃ t e

The provided test data is of a similar format but only has the first column,
containing grapheme sequences.

Data for all three subtasks will be released promptly and announced in the Google Group.

**Update April 9th:**

Data is available in [`data`](https://github.com/sigmorphon/2022G2PST/tree/main/data). 
* `target_to_transfer_languages.json`: map a target language to its corresponding transfer language
* `target_languages`: Target language data. This folder contains the train, dev, and (covered) test splits. It also
contains the "low" data setting subtask named with format `<lang>_100_train.tsv`. The "high" data setting is the train 
file with all language examples, `<lang>_train.tsv`. The dev and test splits remain the same for all subtasks.
* `transfer_languages`: Transfer language data. Filenames include the language code for target and transfer. The files 
for the "mixed" subtask are named in `<transfer lang>_<lang>_*_.tsv.mixed` format. These contain all of the transfer language
examples and the 100 target language examples from the "low" data subtask.
* `morphological`: Morphological information

**Update May 23:**

Surprise languages are available! (Uploaded on May 18)
* Irish -> Welsh
* Burmese -> Shan

Clarifications:

* The "low" `<lang>_100_train.tsv` files: The `<lang>_100_train.tsv` files are *for your convenience* and are the first 100 lines of the `<lang>_train.tsv` file. You are **not required** to use these 100 lines, but these are for reproducibility of the baseline.
* In the original release, the transfer language files were said to be named in `<transfer lang>_<lang>_*_.tsv` format, but this was not the case. Apologies. For clarity, these files have been renamed to `<transfer lang>_<lang>.tsv`. The other information (e.g., "broad") was leftover from data processing and is unnecessary information for this task. 
* The `<transfer lang>_<lang>.tsv.mixed` files are the unshuffled concatenation of `<lang>_100_train.tsv` and `<transfer lang>_<lang>.tsv`. You **do not** have to use this pre-mixed file for your model. This is included for reproducibility of the baseline.

### Subtasks

There are three subtasks, which will be scored separately. Participant teams may
submit as many systems as they want to as many subtasks as they want.
We _strongly_ encourage participation in all three subtasks, for the sake of addressing the scientific questions of this task.

1. A small amount of data (100 words) in the language of interest (the "target language") and a large amount of data (1000 words) in a nearby language (the "transfer language").
2. A small amount of data (100 words) in target language and no data in the transfer language.
3. A large amount of data (1000 words) in target language and no data in the transfer language.

In every case, we will use the same 100-word test set, providing only graphemes to participants.

If you wish to use any external data, please discuss with the organizers beforehand.

This year, we will use 10 language pairs, including two surprise languages.

1. Swedish → Norwegian Nynorsk
2. German → Dutch
3. Italian → Romanian
4. Ukrainian → Belarusian
5. SURPRISE → SURPRISE
6. Tagalog → Cebuano
7. Bengali → Assamese
8. SURPRISE → SURPRISE
9. Persian → Pashto
10. Thai → Eastern Lawa


## Evaluation

The metric used to rank systems is *word error rate* (WER), the percentage of
words for which the hypothesized transcription sequence does not match the gold
transcription. This value, in accordance with common practice, is a decimal
value multiplied by 100 (e.g.: 13.53). 
WER is macro-averaged across all ten languages. We provide two Python scripts
for evaluation:

-   [`evaluate.py`](evaluation/evaluate.py) computes the WER for one language.
-   [`evaluate_all.py`](evaluation/evaluate_all.py) computes per-language and
    average WER across multiple languages.

## Submission

**Please submit your results in the two-column (grapheme sequence,
tab-character, tokenized phone sequence) TSV format, the same one used for the
training and development data.** If you use an internal representation other
than NFC, you must convert back before submitting.

Please use <a href="mailto:sigmorphon+sharedtask2022@gmail.com?&bcc=arya@jhu.edu&subject=SIGMORPHON 2022 Task 1 Submission&body=Team members (...):%0D%0ATeam name (no spaces):%0D%0APlease attach your submission(s). Each submission should be a .tar.gz or .zip file.">this email form</a> to submit your results.

## Baseline

The baseline is the same model as last year (2021), an ensembled neural transition system based on the
imitation learning paradigm introduced by Makarov & Clematide (2020). The baseline is referred to as "CLUZH."

Scores for the different subtasks (mixed, low, and high data settings) are below. 
Please see [`baseline`](baseline) for example code and more details about the model.
A "-" indicates that the model was unable to learn (improve loss) during training.

| Subtask | Language      | Dev   | Test  |
|---------|---------------|-------|-------|
| High    | ben           | 50.68 | 67.12 |
|         | bur           | 22.00 | 29.00 |
|         | ger           | 41.00 | 42.00 |
|         | gle           | 33.00 | 38.00 |
|         | ita           | 15.00 | 15.00 |
|         | per           | 58.93 | 59.65 |
|         | swe           | 52.00 | 45.00 |
|         | tgl           | 17.00 | 20.00 |
|         | tha           | 16.00 | 21.00 |
|         | ukr           | 25.00 | 32.00 |
|         | Macro-average | 33.06 | 36.88 |
| Mixed   | ben           | 84.93 | 91.78 |
|         | bur           | -     | -     |
|         | ger           | 96.00 | 97.00 |
|         | gle           | -     | -     |
|         | ita           | 37.00 | 44.00 |
|         | per           | -     | -     |
|         | swe           | 76.00 | 80.00 |
|         | tgl           | 32.00 | 30.00 |
|         | tha           | -     | -     |
|         | ukr           | 87.00 | 96.00 |
|         | Macro-average | 40.89 | 43.48 |
| Low     | ben           | -     | -     |
|         | bur           | -     | -     |
|         | ger           | -     | -     |
|         | gle           | -     | -     |
|         | ita           | 52.00 | 51.00 |
|         | per           | -     | -     |
|         | swe           | 71.00 | 79.00 |
|         | tgl           | 36.00 | 29.00 |
|         | tha           | -     | -     |
|         | ukr           | -     | -     |
|         | Macro-average | 15.20 | 15.20 |


## Comparison with the 2021 shared task

In contrast to the 2021 shared task (Ashby et al. 2021):

-   Transfer languages are provided.
-   There are new languages.
-   The three subtasks have changed, organized around research questions.
-   There are surprise languages.
-   The data been subjected to novel quality-assurance procedures.

## Organizers

- Arya D. McCarthy (Johns Hopkins University)
- Lucas F. Ashby (City University of New York)
- Milind Agarwal (Johns Hopkins University)
- Travis Bartley (City University of New York)
- Luca Del Signore (City University of New York)
- Alexandra DeLucia (Johns Hopkins University)
- Cameron Gibson (City University of New York)
- Jackson Lee
- Reuben Raff (City University of New York)
- Winston Wu (Johns Hopkins University)

## Licensing

The code is released under the [Apache License 2.0](
https://www.apache.org/licenses/LICENSE-2.0). The data is released
under the [Creative Commons Attribution-ShareAlike 3.0 Unported License](
https://creativecommons.org/licenses/by-sa/3.0/legalcode) inherited from
Wiktionary itself.

## References

Lucas F.E. Ashby, Travis M. Bartley, Simon Clematide, Luca Del Signore, Cameron Gibson, Kyle Gorman, Yeonju Lee-Sikka, Peter Makarov, Aidan Malanoski, Sean Miller, Omar Ortiz, Reuben Raff, Arundhati Sengupta, Bora Seo, Yulia Spektor, and Winnie Yan. 2021. [Results of the Second SIGMORPHON Shared Task on Multilingual Grapheme-to-Phoneme Conversion](https://aclanthology.org/2021.sigmorphon-1.13/). In *Proceedings of the 18th SIGMORPHON Workshop on Computational Research in Phonetics, Phonology, and Morphology*, pages 115–125.

Gorman, K., Ashby, L. F.E., Goyzueta, A., McCarthy, A. D., Wu, S., and You, D. 2020. [The SIGMORPHON 2020 shared task on multilingual grapheme-to-phoneme
conversion](https://www.aclweb.org/anthology/2020.sigmorphon-1.2/). In *17th
SIGMORPHON Workshop on Computational Research in Phonetics, Phonology, and
Morphology*, pages 40-50.

Lee, J. L, Ashby, L. F.E., Garza, M. E., Lee-Sikka, Y., Miller, S., Wong, A.,
McCarthy, A. D., and Gorman, K. 2020. [Massively multilingual pronunciation
mining with WikiPron](https://www.aclweb.org/anthology/2020.lrec-1.521/). In
*Proceedings of the 12th Language Resources and Evaluation Conference*, pages
4223-4228.

Makarov, P., and Clematide, S. 2018. [Imitation learning for neural
morphological string transduction](https://www.aclweb.org/anthology/D18-1314/).
In *Proceedings of the 2018 Conference on Empirical Methods in Natural Language
Processing*, pages 2877-2882.

Makarov, P., and Clematide, S. 2020. [CLUZH at SIGMORPHON 2020 shared task on
multilingual grapheme-to-phoneme
conversion](https://www.aclweb.org/anthology/2020.sigmorphon-1.19/). In
*Proceedings of the 17th SIGMORPHON Workshopon Computational Research in
Phonetics, Phonology, and Morphology*, pages 171-176.
