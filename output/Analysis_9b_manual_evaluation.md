# Manual Evaluation of Top-200 ChemOnt Matches per Embedding Model

**Files evaluated:**
- `output/tables/Analysis_9b_top200_miniLM.csv`
- `output/tables/Analysis_9b_top200_mpnet.csv`
- `output/tables/Analysis_9b_top200_scibert.csv`
- `output/tables/Analysis_9b_top200_biobert.csv`

Each file contains the best-matching ChemOnt class for a substance name, ranked by cosine similarity between name embeddings and ChemOnt class label embeddings. The evaluation below assesses match quality, systematic errors, and suitability for regulatory ChemOnt classification.

---

## Score Ranges

| Model | Score floor (~rank 200) | Score ceiling |
|---|---|---|
| miniLM | ~0.800 | 1.000 |
| mpnet | ~0.813 | 1.000 |
| scibert | ~0.908 | 1.000 |
| biobert | ~0.944 | 1.000 |

The higher floors for scibert and biobert are not a quality advantage. Both models assign high scores to incorrect matches, indicating poor calibration: a score of 0.93 on a wrong match is less informative than 0.85 on a correct match.

---

## all-MiniLM-L6-v2 — Best calibrated

### Correct matches

Scores above 0.90 are largely reliable:

- "Phenols" → Phenols, "cresols" → Cresols, "xylenols" → Xylenols, "Tannins" → Tannins: exact matches at ≈1.0
- "Polychlorinated Biphenyls (PCB)" → Polychlorinated biphenyls (0.912): correct
- "Diaminotoluene" → Diaminotoluenes (0.905): correct
- "Arsenic compounds" → Inorganic arsenic compounds (0.947): correct, though slightly over-specified (not all arsenic compounds are inorganic)
- "Chromium VI compounds" → Inorganic chromium (VI) compounds (0.932): correct
- "Quaternary ammonium compounds" → Quaternary ammonium salts (0.901): correct
- "Quinoline derivative" → Quinolines and derivatives (0.930): correct
- "Alkyldimethylbenzyl ammonium chloride" → Alkyldimethylbenzylammonium chlorides (0.901): correct
- "lead alkyls" → Alkyl lead compounds (0.868): correct
- "polyhalogenated dibenzo-p-dioxins and dibenzofurans" → Dibenzo-p-dioxins (0.850): correct at class level

### Errors and weaknesses

| Substance name | Matched class | Score | Problem |
|---|---|---|---|
| Inorganic ammonium salts | Quaternary ammonium salts | 0.842 | Conceptually wrong — inorganic ammonium ≠ quaternary ammonium |
| Organostannic compounds | Organoarsenic compounds | 0.815 | Wrong element — tin ≠ arsenic; driven by shared "organo-" prefix |
| perchloric acid, salts (perchlorate) | Organic perchlorate salts | 0.835 | Organic/inorganic distinction missed — perchlorates are generally inorganic |
| Polycyclic aromatic hydrocarbons (PAH) | Aromatic hydrocarbons | 0.813 | Too broad — PAH is a distinct ChemOnt node |
| Metal oxide sulfide | Metalloid sulfides | 0.812 | Metal ≠ metalloid |
| thioxylenols | Thioperoxols | 0.840 | Debatable; not convincing |
| Naphthenic acids, lithium salts | Organic lithium salts | 0.801 | Too broad; naphthenic acid class ignored |

**Assessment:** miniLM is the best-calibrated of the four models. Scores above 0.90 are mostly trustworthy. Scores in the 0.80–0.88 range contain recurring errors. The model's main blind spots are the organic/inorganic distinction and element-level confusion triggered by shared prefixes (organotin → organoarsenic). Uncertainty is expressed honestly through lower scores.

---

## all-mpnet-base-v2 — Broader coverage, one severe systematic error

### Advantages over miniLM

- More PFAS entries in the top 200, with correct class assignments: PFHxS, PFOA, PFNA, and related compounds are correctly matched to "Perfluoroalkyl sulfonic acid and derivatives" and "Perfluoroalkyl carboxylic acid and derivatives"
- "Alkyloxyl and aryl mercury compounds" → Aryl mercury compounds (0.908): more specific than miniLM's match to Alkyl mercury compounds
- Better coverage of ethoxylated alcohols and phosphoric acid ester derivatives
- "lead alkyls" → Alkyl lead compounds (0.913): correct

### Systematic error — critical

Every nickel compound variant is incorrectly matched:

| Substance name | Matched class | Score |
|---|---|---|
| Nickel Sulfide (Ni4S) | Nitrile sulfides | 0.835 |
| Nickel Sulfide (Ni7S3) | Nitrile sulfides | 0.829 |
| Nickel Sulfide (Ni9S8) | Nitrile sulfides | 0.827 |
| Nickel Sulfide (Ni5S6) | Nitrile sulfides | 0.827 |
| Nickel Sulfide (Ni9S5) | Nitrile sulfides | 0.826 |
| Nickel Sulfide (Ni5S4) | Nitrile sulfides | 0.819 |
| Nickel Sulfide (Ni5S3) | Nitrile sulfides | 0.819 |
| Nickel selenide (Ni3Se2) | Nitrile selenides | 0.830 |

This is an embedding artefact: the model reads "Ni" (the chemical symbol for nickel) as the start of the word "nitrile". None of these compounds have any relationship to nitriles. The error is entirely consistent across the series.

### Other errors

| Substance name | Matched class | Score | Problem |
|---|---|---|---|
| Polychlorinated naphthalenes | Polychlorinated biphenyls | 0.835 | Wrong class — naphthalenes ≠ biphenyls |
| chlorobutadienes | Chloroanilines | 0.814 | Wrong class — butadienes ≠ anilines |
| BIS-PIPERAZINE | Piperazinoazepines | 0.820 | Wrong — miniLM correctly returns Piperazines |

**Assessment:** good PFAS coverage and specificity in mercury compound matching are genuine advantages. However, the systematic Ni → nitrile error disqualifies the model for nickel compounds, a class that is directly relevant to ECHA regulatory lists (SVHC, CMR). This error cannot be corrected by score thresholding, as the affected entries span a coherent score band.

---

## allenai/scibert_scivocab_uncased — Poor calibration, unsuitable

### Correct matches

A small number of entries are correct:

- Basic class names (Phenols, Tannins, Polysaccharides) at ≈1.0
- "Diisocyanates" → Isocyanates (0.968): correct
- "polyhalogenated dibenzo-p-dioxins and dibenzofurans" → Chlorinated dibenzo-p-dioxins (0.932): correct
- "Enzymatically produced steviol glycosides" → Steviol glycosides (0.924): correct
- "1,3,5-Triazine-2,4,6-triamine, deammoniated" → "1,3,5-triazine-2,4-diamines" (0.951): correct
- "chlorobutadienes" → Alkadienes (0.930): correct (better than mpnet)

### Serious errors

| Substance name | Matched class | Score | Problem |
|---|---|---|---|
| Inorganic ammonium salts | Inorganic chloride salts | 0.978 | Severely wrong, with high confidence |
| Polyphosphoric acids | Boronic acids | 0.918 | Catastrophic — phosphorus ≠ boron |
| Quinoline derivative | Carboxylic acid derivatives | 0.924 | Too broad / wrong |
| Naphthenic acids | Benzoic acids | 0.941 | Wrong class |
| CW004A (Cu-ETP) | Gal- (Gala series) | 0.925 | A copper alloy trade code matched to a glycolipid class |
| octylalcohols | Cyclopentanols | 0.924 | Wrong class |
| aluminium alkyls | Alkyl fluorides | 0.924 | Wrong element |
| Nickel arsenide sulfide | Alkali metal sulfides | 0.924 | Wrong class |
| melamine sulfonates | Diazonium sulfates | 0.936 | Wrong |

### Repeated false anchors

Two ChemOnt classes recur as catch-all matches for structurally unrelated substances throughout the top 200:

- `Pyrazolo[1',5':1,6]pyrimido[4,5-d]pyridazin-4-ones` — matched to dozens of complex organic names with no relationship to this specific fused ring system
- `1,2-diacyl-sn-glycerol-3(2'-trimethylaminoethyl)phosphonates` — a specific phospholipid class, repeatedly matched to complex non-lipid substances

This pattern reflects domain shift: scibert was pre-trained on biomedical scientific literature, where complex heterocyclic and lipid terminology occurs frequently. The model has learnt that complex organic names in general co-occur with these specific class tokens, regardless of actual chemical structure.

**Assessment:** unsuitable for regulatory ChemOnt classification. Scores are systematically inflated — a score of 0.93 on an incorrect match provides less information than a score of 0.85 on a correct match from miniLM. The model's training domain (biomedical scientific text) does not generalise to chemical regulatory nomenclature.

---

## dmis-lab/biobert-v1.1 — Most overconfident, worst calibration

### Correct matches

- Basic class names correct (Phenols, Tannins, Alkyl mercury compounds) at ≈1.0
- "Acridinic bases" → Acridines (0.965): correct
- "Diisocyanates" → Isocyanates (0.974): correct
- "polyhalogenated dibenzo-p-dioxins and dibenzofurans" → Chlorinated dibenzo-p-dioxins (0.963): correct
- PFAS classes largely correct
- "Polycyclic aromatic hydrocarbons (PAH)" → Polycyclic hydrocarbons (0.945): correct at broad level

### Serious errors

| Substance name | Matched class | Score | Problem |
|---|---|---|---|
| Inorganic ammonium salts | Inorganic sodium salts | 0.982 | Highly confident wrong match |
| Arsenic compounds | Organic arsenates | 0.963 | Wrong direction — general arsenic ≠ specifically organic |
| Naphthenic acids | Naphthacenes | 0.955 | Naphthacene is a PAH; naphthenic acids are alicyclic carboxylic acids |
| 2-naphthylamine and its salts | 2-naphthalene sulfonic acids and derivatives | 0.957 | Amine ≠ sulfonic acid |
| Triazine derivative | Triazirines | 0.961 | Triazine (6-membered) ≠ triazirine (3-membered) |
| polyphosphoric acids | Organic thiophosphoric acids | 0.951 | Wrong — no sulphur |
| Chromium VI compounds | Organic chromium salts | 0.946 | Organic/inorganic distinction missed |
| Organostannic compounds | Organoarsenic compounds | 0.949 | Same tin → arsenic confusion as miniLM, but with higher confidence |
| Polychlorinated naphthalenes | Polychlorinated biphenyls | 0.954 | Same error as mpnet |

With a score floor of 0.944, the score range is compressed to approximately 0.944–1.000 across 200 entries. Score is effectively non-informative as a confidence measure: the difference between a correct and an incorrect match is smaller than the noise floor.

**Assessment:** worse than scibert. BioberBERT was trained on clinical and biological literature (gene expression, proteins, clinical records) — a training domain even further removed from regulatory chemical nomenclature than scibert. Practically unsuitable for this application.

---

## Summary

| Model | Calibration | Correct matches | Systematic errors | Suitability |
|---|---|---|---|---|
| **miniLM** | Good — lower score reflects genuine uncertainty | High (>0.90 mostly reliable) | Organic/inorganic conflation; Sn → As confusion | Most suitable |
| **mpnet** | Acceptable | Good; stronger PFAS coverage | Ni → nitrile (all nickel compounds affected) | Suitable if nickel compounds filtered or flagged |
| **scibert** | Poor — high score ≠ correct | Moderate | Boronic/phosphoric conflation; repeated false anchors | Unsuitable |
| **biobert** | Very poor — score non-informative | Moderate | Multiple systematic class confusions; highest overconfidence | Unsuitable |

### Implications for Analysis 9c

The validation metrics from Analysis 9c (Hit@k, MRR, weighted MRR) will reflect these patterns:

- miniLM and mpnet should produce the highest strict Hit@k and mrr_weighted scores
- scibert and biobert will show low strict Hit@k despite high cosine scores, confirming that their confidence inflation is not matched by retrieval accuracy
- The per-level metrics (subclass/class/superclass/kingdom) will additionally reveal whether scibert and biobert fail at all hierarchy levels or retain some kingdom-level discriminative power
- The Ni → nitrile error in mpnet will be visible as a localised depression in Hit@k for the relevant substance subset, not a global weakness

For downstream use in Analysis 09 (ChemOnt class assignment for non-structure-defined substances), **miniLM is the recommended model**. mpnet may be used as a secondary check, with nickel compound entries flagged for manual review.
