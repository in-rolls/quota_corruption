# SEPRI reservation histories and reported payments

The SEPRI extension estimates associations between women's reservation histories and two later-wave survey measures: unofficial payments for land-record copies, and bribe demands reported as a reason for not obtaining an MGNREGS job card. The paper examined elsewhere in this repository uses household bribery reports from REDS 2006. These are different observations, outcomes and periods.

## Data and comparisons

The inputs are the `Sepri1` and `Sepri2` household and village modules in the [reds project](https://github.com/in-rolls/reds). [The input manifest](../sources/sepri_inputs.json) pins eight Stata files and two questionnaires by SHA-256. The pipeline rejects changed inputs. Source microdata stay outside this repository; outputs contain aggregate statistics without household or village identifiers.

Village schedule section 11(D1), printed p. 35, records the current council in row 1 and the previous council in row 2. Question 7 records whether the pradhan seat was reserved for a woman: 1 means yes and 2 means no. Other codes remain missing. Rows with conflicting records for the same term are excluded from treatment construction. Histories with a current election year no later than the previous year are also excluded rather than reordered.

Models include current reservation, previous reservation, their interaction and state fixed effects. They report the interaction and three direct contrasts: both reserved terms versus previous only, current only and neither. Reparameterizing the model makes each contrast a single coefficient; tests verify equivalence to the coefficient sum and its full covariance calculation.

These are exploratory conditional associations. The files do not establish the joint assignment mechanism needed for a causal comparison of reservation histories. State effects do not establish exchangeability. Job-card reports cover February 2013–April 2014 in the supplied household questionnaire; the council recorded as current at interview need not have been in office throughout that reporting period.

## Land-record payments

Village schedule section 05, printed p. 23, asks for the unofficial payment in rupees to obtain a certified Record of Rights copy. The outcome is row 7, `s05_p23_q5` (Now, Value). `s05_p23_q6` supplies the retrospective 2006 amount. The numeric value columns are used consistently; entries in the parallel categorical columns are not silently substituted. Missing amounts remain missing and observed zeros remain zero.

Each sampled village has a distinct GP under the normalized state, district, tehsil and GP identifiers. The code checks this before assigning clusters. The main specification weights each observed GP equally. The 147-GP sample has 71 GPs reserved in neither term, 23 in the previous term only, 29 in the current term only and 24 in both.

Sensitivity specifications use `log(1 + payment)` and adjust the rupee outcome for the retrospective 2006 payment. The adjusted sample contains 142 GPs and requires the current election to be after 2006. The retrospective measure is not an independently observed baseline, and conditioning on it may remove associations with previous reservation. The log specification is not interpreted as a percentage change in mean payment.

The rupee estimate for both terms versus previous only is −33.09, with a CR2 95% interval of −96.52 to 30.35. Leaving one GP out produces estimates from −42.22 to −5.03; leaving one state out produces estimates from −42.49 to −1.21. Adjustment for retrospective payment reduces the point estimate to −3.18 (95% interval −22.83 to 16.47). These intervals allow substantial differences in either direction. Land-record administration can also lie outside the pradhan's direct authority, so this outcome is not a comprehensive measure of corruption under the council.

## Job-card demands and coding ambiguity

The household schedule, printed p. 15, routes adults without a job card (`q9_6 = 2`) who applied for one (`q9_7 = 1`) to `q9_9`, their reason for not obtaining it. Responses outside that route are excluded. The pipeline does not treat people with cards, non-applicants, unknown reasons or unasked questions as reporting no bribe demand.

The supplied questionnaire and both Stata files disagree:

| Code | Questionnaire | Stata value labels |
|:--|:--|:--|
| 1 | Incomplete application / missing photograph | Don't know / can't say |
| 2 | Bribe demanded | Incomplete application / missing photograph |
| 3 | Don't know / can't say | Bribe demanded |

Both interpretations are reported as coding sensitivity analyses. The unknown category is excluded under each interpretation, so the scenarios change the analytical sample as well as the outcome. They are not identified lower and upper bounds, and the data do not establish which is correct. A reconciled codebook or confirmation of the data-entry coding is needed to interpret either as a bribery estimate.

The household outcome is 100 if any eligible member reports a demand, zero if every eligible member has a known non-demand reason, and missing otherwise. It measures the percentage of households reporting a demand among households with eligible applicants and a classifiable outcome. The person specification weights each eligible respondent equally. The GP specification averages household outcomes within GP and weights GPs equally. Each answers a different question.

Questionnaire coding yields 270 households in 33 GPs; Stata-label coding yields 912 households in 43 GPs. Both have five twice-reserved GPs, but only two and four previous-only GPs respectively. Under questionnaire coding, the household outcome in the neither-reserved group averages 7.73%; under the Stata labels it averages 97.79%. That discrepancy concerns measurement, not sampling uncertainty. Linear-model fitted values can fall outside 0–100; their counts appear in the estimates file, and fitted values are not interpreted as valid individual probabilities.

## Linking and sample checks

Village serial numbers repeat. Village modules are joined on all six source identifiers: serial number, village name, GP, tehsil, block and district. The right side must be unique and joins must conserve rows. The script verifies distinct GP geography before using a village record as a cluster.

Household-to-village links use exact normalized district and village labels, allowing the two district and village-name fields present in the village file. A link must be unique in both directions and compatible with the state. State normalization uses an explicit spelling/abbreviation map. No fuzzy matching is used. An unrecognized village-state field can be filled only from an otherwise unambiguous exact household link; no such fill was required for these inputs.

| Check | Sepri1 | Sepri2 |
|:--|--:|--:|
| Village records | 101 | 90 |
| Adults reporting no card and a prior application | 3,103 | 3,880 |
| Missing person identifiers, excluded | 4 | 0 |
| Eligible applicants linked to a village record | 2,553 | 2,380 |
| Eligible applicants without a unique link | 546 | 1,500 |
| Villages with an exact household link | 69 | 63 |
| Conflicting election-term records, excluded | 2 | 0 |
| Nonchronological histories, excluded | 5 | 0 |
| Nonmissing reasons recorded outside the question route | 1,999 | 1,179 |

The two conflicting election records belong to one village and both label different elections as current. Excluding those records removes that village's current treatment rather than guessing its history. Complete-case models also exclude missing state, outcome or treatment. [Sample flows](../output/sepri/sample_flow.csv) report inclusion by reservation history, [cell summaries](../output/sepri/cell_summary.csv) report outcome levels and counts, and [state support](../output/sepri/state_support.csv) reports each history's representation within states. The matched and observed samples are not representative by construction. Conditioning on unsuccessful job-card applications may itself select on consequences of reservation.

## Inference and reproducibility

[The analysis script](../scripts/sepri_analysis.R) uses [clubSandwich](https://jepusto.github.io/clubSandwich/reference/coef_test.html) for CR2 standard errors and Satterthwaite degrees of freedom. The reported 95% intervals use that t reference distribution. With one observation per GP, the land-payment CR2 covariance reduces to an HC2 adjustment; household and person regressions allow dependence within GP.

[fwildclusterboot](https://s3alfisc.github.io/fwildclusterboot/reference/boottest.lm.html) supplies null-imposed WCR11 bootstrap-t tests, two-sided, with 9,999 GP-level draws. Rademacher weights are primary and Webb weights are reported alongside them. Both R and `dqrng` seeds are set for each test; the base seed is 20261004 and each model/contrast's actual seed is saved. Bootstrap draws must all be finite, and the bootstrap sample size and cluster count must equal the fitted model's. The pipeline records zero failed draws. These p-values are not randomization-inference p-values, and the confidence intervals are CR2 intervals, not bootstrap-inverted intervals.

Small comparison groups remain a limitation even with bootstrap inference. Some job-card contrasts have Satterthwaite degrees of freedom below two. [The estimates file](../output/sepri/estimates.csv) reports the degrees of freedom, design rank, condition number, maximum leverage, leave-one-GP/state-out ranges and failed deletion fits. Holm-adjusted Rademacher p-values cover all 36 reported outcome/contrast tests; no specification was preregistered. No causal identification or equivalence claim follows from a large p-value.

Unit tests check missing-value rules, competing code schemes, household denominators, joins, exact coefficient/covariance transformations and recovery of planted effects with repeated observations per GP. They also verify bootstrap reproducibility. `make sepri` verifies the source hashes, regenerates aggregate outputs and updates the README table. The original `make audit` remains independent and reconstructs the REDS 2006 manuscript tables using Python's standard library.
