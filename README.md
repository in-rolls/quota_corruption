# Quotas and corruption in rural India

Does reserving village-council seats for women reduce bribery? This repository examines evidence from *Female politicians and corruption in rural India* by Somdeep Chatterjee, Shiv Hastawala and Elisa Taveras (*European Journal of Political Economy* 90, 102764, 2025; [paper](https://doi.org/10.1016/j.ejpoleco.2025.102764)). It reconstructs comparisons from the reported coefficients and analyzes later SEPRI survey measures of unofficial land-record payments and job-card bribe demands.

The reported coefficients imply lower household bribery in villages reserved for women in both council terms. But the interaction coefficient differs from either direct comparison of two reserved terms with one. The tables establish the point estimates of those comparisons; they do not provide the covariances needed to estimate their uncertainty.

The published-table reconstruction uses the complete 75-page [author manuscript dated September 9, 2025](https://www.dropbox.com/scl/fi/w8cf9d5wws4yhcn7maum3/women_politicians_and_corruption_paper_ejpe_9_sep_2025.pdf?rlkey=u8ivgxir96p0of8mjs7o84d95&dl=1), including its appendix, linked from [Hastawala's website](https://www.shivhastawala.com/). Findings and printed page references below concern that version. That reconstruction does not reproduce regressions on the underlying 2006 microdata.

## Published household-bribery findings

Equation 2 includes current reservation, previous reservation and their interaction. At fixed covariates, the interaction is `(both − previous only) − (current only − neither)`. Comparing both reserved terms with previous only requires **current + interaction**. Comparing both terms with current only requires **previous + interaction**.

The manuscript recognizes this distinction in footnote 21 and Appendix A, but the abstract and results describe the interaction as an additional-term effect. Table 4 pools reservation histories: its current-reservation coefficient is not restricted to a first reserved term. Tables A15–A18 provide that restricted comparison separately.

For whether a household paid any bribe, Table 5, panel B implies:

<!-- TABLE_AUDIT_START -->
| Comparison | Difference, percentage points |
|:--|--:|
| Interaction (reported coefficient) | -13.10 |
| Both terms vs previous only | -4.73 |
| Both terms vs current only | -18.78 |
| Both terms vs neither | -10.41 |

Table A25 implies **14 twice-reserved villages in 6 states**, including 9 in its early-adopter sample.
<!-- TABLE_AUDIT_END -->

These differences use rounded coefficients. The reported interaction standard error is 2.79 percentage points, with 8,116 households. Standard errors for the direct comparisons require covariances that the tables do not report. The interaction alone does not imply negative bribery probabilities.

Table A25 totals 71 currently reserved villages, while Table 1's Census-linked sample has 67. The number of villages in each reservation history therefore needs to be established for each regression sample. The adoption dates used in the cell-count calculation are transcribed from the manuscript and have not been independently validated.

## SEPRI extension: land payments and job-card access

The SEPRI files support a separate analysis of later reservation histories. The land-record outcome is the village respondent’s reported unofficial payment for a certified copy of the Record of Rights. The job-card outcome is a reported bribe demand as the reason an applicant lacks an MGNREGS job card. Neither reproduces the paper’s 2006 household-bribery outcome.

The estimates below are conditional associations with state fixed effects. Confidence intervals use GP-clustered CR2 standard errors with Satterthwaite degrees of freedom. The two-sided wild cluster bootstrap imposes the null and uses 9,999 Rademacher draws at the GP level; Webb-weight results are also available.

<!-- SEPRI_RESULTS_START -->

| Outcome | Comparison | Difference | 95% CI (CR2) | Wild bootstrap p | GPs |
|:--|:--|--:|:--|--:|--:|
| Unofficial land-record payment (rupees) | Both vs previous only | -33.09 | -96.52 to 30.35 | 0.306 | 147 |
| Unofficial land-record payment (rupees) | Both vs current only | -31.94 | -94.71 to 30.82 | 0.318 | 147 |
| Job-card demand: questionnaire coding (pp) | Both vs previous only | -12.25 | -49.29 to 24.79 | 0.142 | 33 |
| Job-card demand: questionnaire coding (pp) | Both vs current only | -12.25 | -34.36 to 9.86 | 0.096 | 33 |
| Job-card demand: Stata-label coding (pp) | Both vs previous only | -20.73 | -77.90 to 36.45 | 0.392 | 43 |
| Job-card demand: Stata-label coding (pp) | Both vs current only | 2.21 | -4.88 to 9.30 | 0.342 | 43 |

Among GPs reserved in neither term, the reported land-record payment averages 70.46 rupees. Among eligible households in that history, the job-card demand share is 7.73% under questionnaire coding and 97.79% under Stata-label coding. The coding changes both the outcome and which responses count as known.

<!-- SEPRI_RESULTS_END -->

The land-payment differences are imprecise and sensitive to influential GPs. The job-card results are coding sensitivity calculations: the questionnaire and Stata value labels disagree on the bribe-demand code. Applicants with unknown reasons remain missing, and households reporting a demand are counted only within the population of applicants without a card. This selected sample cannot identify bribery prevalence among all households.

Only two GPs under questionnaire coding and four under Stata-label coding supply the “previous only” household comparison group. Wild bootstrap does not make those comparisons well supported. The [methods and data checks](docs/sepri.md) explain the coding conflict, sample construction and influence diagnostics. [All estimates](output/sepri/estimates.csv) include person-, household- and GP-weighted job-card comparisons, land-payment transformations, adjustment for retrospective 2006 payments, and Holm-adjusted p-values.

## Measurement and interpretation

The paper’s main regressions concern household reports for the current council term in REDS 2006, fielded during 2006–2008. Reservation is measured at the gram panchayat (GP), or village-council, level. The manuscript describes ordinary least squares with state and interview year/month effects; the use of population weights cannot be verified without the estimation code. Jharkhand is excluded by missing treatment despite the broader 17-state survey description (p. 12, footnote 10).

| Finding | Evidence | Implication |
|:--|:--|:--|
| The interaction and direct reservation-history comparisons answer different questions. | Equation 2, Table 5, p. 25; footnote 21, p. 20; Appendix A, pp. 45–46. | The direct point estimates are negative. Their uncertainty requires the full covariance matrix. |
| A bribe reduction exceeding 100% is impossible for nonnegative payments. | Results, p. 20, describe amounts as “smaller by a whopping 105%.” Table 5 reports −1.032 and −1.100 log units. | `100 * (exp(-1.100) - 1)` is −66.7%, but describes a multiplicative transformed-outcome interaction under suitable coding. It is not automatically a change in mean expenditure; zero handling and the outcome definition matter. |
| The repeated-reservation cell is small. | Table A25, p. 72: current minus current-only and previous minus previous-only give the same state totals. | Table notes specify robust standard errors without identifying GP clustering. GP-clustered inference and sensitivity to influential GPs are needed to assess uncertainty. |
| Official-specific bribe denominators appear conditional on contact. | Table 2, p. 17, has 6,449 GP-president bribery responses versus 8,273 for any official approached; counts vary by official. | All-household incidence, contact rates and incidence among contacts answer different questions. Survey skip rules determine whether unasked responses can be treated as zero. |
| The log outcome's sample does not reconcile with a payer-only interpretation. | Table 2 reports 8,277 log-amount observations and 8,144 any-bribe observations, with about half reporting a bribe. Table 4 reports 8,144 for both outcomes. | Aggregation, zeros and sample filters require verification. The counts establish a documentation gap, not a particular coding error. |
| Several percentages in the manuscript prose are mis-scaled. | P. 20 gives roughly 0.24, 0.33 and 0.20 percentage points for GP president, secretary and PDS; Table 6B gives 0.0236, 0.0333 and 0.0201. | These coefficients represent 2.36, 3.33 and 2.01 percentage points. The authors' later [Ideas for India account](https://www.ideasforindia.in/topics/governance/it-takes-two-terms-to-tango-female-leaders-and-corruption-in-rural-india) uses approximately the correctly scaled values. |

Causal interpretation requires the joint reservation-assignment rule. Balance on current reservation alone does not establish comparability of reservation histories. Table 1 compares current treatment groups, and state effects do not establish how rotation selected each history. The [constitutional amendment](https://www.legislative.gov.in/static/uploads/2025/07/d6e04624ef8b6b869af003909507cfe6.pdf) specifies reservation and rotation, leaving implementation to state rules. Randomization inference requires those rules and the eligible sets.

The survey asks whether households **had to pay** a bribe. It does not separately identify voluntary supply, officials' demands or beliefs about female competence. Household reports of problem-solving and beneficiary selection do not establish an experience or trust mechanism. Nor does a significant estimate for one respondent group and an insignificant estimate for another establish a gender difference. Two reserved terms may involve different women; the manuscript acknowledges possible network transmission between women on p. 31.

### What each comparison establishes

| Claim | Measured outcome and comparison | Interpretation |
|:--|:--|:--|
| Current reservation raises bribery. | Equation 1: any-bribe indicator and log amount, current reserved versus unreserved, pooling past histories. | The reported comparison includes multiple reservation histories; it is not a first-term-only effect. |
| An additional reserved term reduces bribery. | Equation 2: interaction of current and previous reservation. | Direct comparisons can be reconstructed, but their uncertainty and causal identification remain unresolved. |
| Effects extend to other officials. | Equations 1–2: six official-specific bribery indicators with varying samples. | Contact and response denominators determine whether these describe unconditional household incidence. |
| Experience or trust explains the pattern. | Household assessments and a female-respondent subgroup. | These associations do not identify mediation. |

Table A2 also contains unusual main-effect entries relative to A3. Their accuracy cannot be established from the printed tables alone.

## Related evidence

Administrative records and survey reports measure different aspects of corruption and governance. The following projects provide complementary evidence:

| Project | Evidence | Relationship to this study |
|:--|:--|:--|
| [mnrega_social_audit](https://github.com/in-rolls/mnrega_social_audit) | Scripts and [data](https://doi.org/10.7910/DVN/KAIZ1B) for MNREGA social-audit reports across states. | A source of administrative audit measures; the data collection itself does not estimate reservation effects. |
| [quota_pds](https://github.com/in-rolls/quota_pds) | Analysis of 2021 Rajasthan ration cards, transactions and indicators of possible PDS leakage, linked to 2020 reservation and earlier histories. | The repository reports no statistically detectable effect of 2020 reservation on its corruption index. These administrative indicators differ from household reports of paying a bribe. |
| [quota_spending](https://github.com/in-rolls/quota_spending) | Rajasthan social-audit measures of works/household verification, job-card possession, staffing and meeting procedures. | Its four reservation-cycle coefficients are separate marginal terms, not the repeated-versus-single comparisons reconstructed here. |
| [quota_governance](https://github.com/in-rolls/quota_governance) | Panchayat Advancement Index (PAI) 2.0 measures of governance procedures in UP and Rajasthan. | Its design treats the estimates as conditional associations; procedural measures do not directly measure household bribery. |

The [quota_pds results](https://github.com/in-rolls/quota_pds#key-findings) report a corruption-index estimate of −0.026 standard deviations (p = .54; randomization-inference p = .52). Its separate comparison of women and men winning open seats is conditional on observables. Neither comparison reproduces the REDS sample, period or outcome.

The [Rajasthan social-audit specification](https://github.com/in-rolls/quota_spending/blob/main/scripts/17a_raj_social_audit.R) and [reported table](https://github.com/in-rolls/quota_spending/blob/main/tabs/mnrega_raj_05_20_audit.tex) document the cycle-specific comparisons. The saved PAI estimates for [UP](https://github.com/in-rolls/quota_governance/blob/main/tabs/up_pai_effects.csv) and [Rajasthan](https://github.com/in-rolls/quota_governance/blob/main/tabs/raj_pai_effects.csv) are 0.067 points (HC2 95% CI −0.223 to 0.358) and −0.050 (−0.588 to 0.487). Their [design](https://github.com/in-rolls/quota_governance/blob/main/docs/design.md) explains the interpretation limits. These results are attributed to the linked projects and are not re-estimated here; they do not establish a zero effect on REDS bribery.

## Data access

This repository includes transcribed coefficients, reservation counts, source hashes and reproducible arithmetic. [sources/manifest.json](sources/manifest.json) identifies the manuscript version and documents source checks. The underlying REDS 2006 household and village microdata and the authors' estimation code are not included.

Brown's [REDS documentation](https://adfdell.pstc.brown.edu/arisreds_data/readme.txt) specifies approved institutional IRB access for the 2006 microdata. The [public06 directory](https://adfdell.pstc.brown.edu/arisreds_data/public06/) provides questionnaires and variable lists. The recorded searches of author pages, publication records and repositories did not locate a public replication deposit.

The [household variable list](https://adfdell.pstc.brown.edu/arisreds_data/public06/hh_variable_list.pdf#page=76) identifies `hdeck81.dta`, schedule p. 129: `p129q2` records contact, `p129q5` bribery and `p129q6` amount for the current term. Corresponding prior-term fields are also available. Reproducing the regressions requires those observations, household covariates, GP reservation histories, documented merge keys and missing-value codes, and the authors' sample construction and SHRUG linkage.

### SEPRI 2014 and the REDS 2006 sample

The [reds repository](https://github.com/in-rolls/reds) contains analysis of SEPRI data, collected on the REDS sampling frame. Its `Sepri1` and `Sepri2` inputs are from the later survey, with questionnaires dated 2014 and village election histories extending through 2013–2014. These files supply the SEPRI extension above; they cannot substitute for the 2006 observations in a replication.

The available SEPRI modules include women's reservation histories (`Village/SECTION_11_D.dta`) and reasons for not obtaining an MGNREGS job card (`HH/SECTION09.dta`, `q9_9`). “Bribe demanded” is a response category, but the household questionnaire codes it as 2 while both Stata files label it as 3. The reason is asked conditionally on job-card access and application; missing responses cannot simply be counted as no bribery. The village questionnaire also asks about unofficial payments for land-record copies, recorded in `Village/SECTION_05.dta`, with current and retrospective 2006 responses. Retrospective village reports differ from the paper's contemporaneous household observations. The extension uses exact, unambiguous district/village links and reports both coding interpretations, with the validation and exclusions documented in [the methods note](docs/sepri.md).

### Inference

The SEPRI extension reports the interaction and direct coefficient sums, GP-clustered CR2 intervals, null-imposed wild cluster bootstrap p-values, and leave-one-GP-out and leave-one-state-out sensitivity. Cluster counts and reservation-history support accompany each estimation sample. Household-, person- and GP-weighted job-card estimates answer different questions and are labeled separately. Randomization inference requires documented joint assignment rules, which these files do not establish.

The REDS 2006 comparisons reconstructed from published tables still lack observation-level inference: printed coefficients alone cannot supply clustered standard errors or bootstrap results.

## Reproduction

```sh
git clone https://github.com/in-rolls/quota_corruption.git
cd quota_corruption
make audit
make test
```

Python 3 and its standard library are sufficient. [scripts/audit_tables.py](scripts/audit_tables.py) verifies transcription hashes, generates [all contrasts](output/contrasts.csv) and [cell-count checks](output/summary.json), and updates the findings table above. Tests recover contrasts from known four-cell means and reject inconsistent reservation counts. These commands reproduce the table calculations without microdata or a copy of the source PDF. Restricted microdata should be stored outside version control.


To reproduce the SEPRI extension, install the R packages and make the source files identified in [sources/sepri_inputs.json](sources/sepri_inputs.json) available under `../reds/data` (or set `REDS_DATA_DIR`):

```r
install.packages(c("haven", "dplyr", "rlang", "clubSandwich", "dqrng", "digest", "jsonlite", "testthat", "lintr"))
install.packages("fwildclusterboot", repos = c("https://s3alfisc.r-universe.dev", "https://cloud.r-project.org"))
```

```sh
make sepri
make test-sepri
make lint-r
```

The pipeline verifies source hashes, writes aggregate results under `output/sepri/`, and updates the SEPRI table above. No household or village identifiers are exported. Package versions, seeds and bootstrap settings are recorded in [provenance.json](output/sepri/provenance.json). The default is 9,999 draws per test; `BOOTSTRAP_DRAWS` can override it for development runs.

<!-- adjacent:start -->

## 🔗 Adjacent Repositories

- [in-rolls/quota_governance](https://github.com/in-rolls/quota_governance) — Women's political reservations and local governance in India
- [in-rolls/quota_pds](https://github.com/in-rolls/quota_pds) — Do women pradhans reduce corruption in the PDS? Forensics on 16M Rajasthan ration cards x GP reservation lottery: precise nulls, clean placebos.
- [in-rolls/local_elections_reform](https://github.com/in-rolls/local_elections_reform) — Replication materials and analyses of electoral reform, presidential participation, and elite representation in rural India
- [in-rolls/quota_elite_quality](https://github.com/in-rolls/quota_elite_quality) — Effect of Gender Quotas on Some Qualities of Elites
- [in-rolls/quota_sanitation](https://github.com/in-rolls/quota_sanitation) — Replication and analysis of gender quotas, sanitation preferences and toilet provision in India

_Powered by [Adjacent](https://github.com/gojiplus/adjacent)_

<!-- adjacent:end -->
