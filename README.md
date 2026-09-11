# Female politicians and corruption in rural India

**Replication pending; manuscript audit started.** The author manuscript's interaction coefficient does not equal a direct comparison of two reserved terms with one. Its printed coefficients still imply lower reported bribery for twice-reserved villages. Whether those differences survive appropriate inference remains untested: REDS 2006 microdata and the authors' code are not available locally.

Paper: Somdeep Chatterjee, Shiv Hastawala and Elisa Taveras, *Female politicians and corruption in rural India*, European Journal of Political Economy 90, 102764 (2025), [DOI](https://doi.org/10.1016/j.ejpoleco.2025.102764). This audit covers the complete 75-page [author manuscript dated September 9, 2025](https://www.dropbox.com/scl/fi/w8cf9d5wws4yhcn7maum3/women_politicians_and_corruption_paper_ejpe_9_sep_2025.pdf?rlkey=u8ivgxir96p0of8mjs7o84d95&dl=1), including its appendix, linked from [Hastawala's website](https://www.shivhastawala.com/). The publisher version was not inspected in full. Findings below concern this manuscript unless stated otherwise. Page references are printed page numbers.

## What the coefficients compare

Equation 2 includes current reservation, previous reservation and their interaction. At fixed covariates, the interaction is `(both − previous only) − (current only − neither)`. The direct effect of continuing reservation after a reserved term is **current + interaction**. Comparing both terms with current only instead requires **previous + interaction**.

The paper recognizes this distinction in footnote 21 and Appendix A, but the abstract and results describe the interaction as an additional-term effect. Table 4 also pools reservation histories: its current-reservation coefficient is not restricted to a first reserved term. The appendix supplies that restricted comparison separately in Tables A15–A18.

From Table 5, panel B, for whether a household paid any bribe:

<!-- TABLE_AUDIT_START -->
| Comparison | Difference, percentage points |
|:--|--:|
| Interaction (reported coefficient) | -13.10 |
| Both terms vs previous only | -4.73 |
| Both terms vs current only | -18.78 |
| Both terms vs neither | -10.41 |

Table A25 implies **14 twice-reserved villages in 6 states**, including 9 in its early-adopter sample.
<!-- TABLE_AUDIT_END -->

These are reconstructions from rounded coefficients, not new regressions. The reported interaction SE is 2.79 percentage points, with 8,116 households. SEs for the direct comparisons require covariances that the tables do not report. Table A25 totals 71 currently reserved villages, while Table 1's Census-linked sample has 67. Village counts therefore need confirmation in each outcome's estimation sample; adoption dates are transcribed, not independently validated.

## Findings and unresolved checks

| Finding | Evidence | Consequence and decisive check |
|:--|:--|:--|
| The main coefficient answers a different comparison from the headline. | Equation 2, Table 5, p. 25; footnote 21, p. 20; Appendix A, pp. 45–46. | Report the interaction and direct contrasts separately, with their full covariance matrix. The negative direct point estimates survive the arithmetic correction. |
| A bribe reduction exceeding 100% is impossible for nonnegative payments. | Results, p. 20, describe amounts as “smaller by a whopping 105%.” Table 5 reports −1.032 and −1.100 log units. | `100 * (exp(-1.100) - 1)` is −66.7%, but describes a multiplicative transformed-outcome interaction under suitable coding, not automatically mean expenditure. Recover zero handling and the outcome definition before reporting a corrected spending effect. |
| The repeated-reservation cell is small. | Table A25, p. 72: subtract current-only from current counts, and independently previous-only from previous counts. Both give the same state totals. | Table notes say robust SEs; no GP clustering specification was located. This is an unresolved inference concern, not evidence that clustered results are null. Obtain code, count analysis GPs, and run GP-clustered and small-sample sensitivity analyses. |
| Official-specific bribe denominators appear conditional on contact. | Table 2, p. 17, has 6,449 GP-president bribery responses versus 8,273 for any official approached; counts vary by official. | Compare all-household incidence, contact rates and incidence among contacts. Establish skip rules before treating unasked responses as zero. |
| The log outcome's stated sample does not reconcile with a payer-only interpretation. | Table 2 reports 8,277 log-amount observations and 8,144 any-bribe observations, with about half reporting a bribe. Table 4 instead reports 8,144 for both outcomes. | Inspect aggregation, zeros and sample filters. Counts establish a documentation gap, not the underlying coding error. |
| Several first-term percentages are mis-scaled in the manuscript prose. | P. 20 gives roughly 0.24, 0.33 and 0.20 percentage points for GP president, secretary and PDS. Table 6B gives 0.0236, 0.0333 and 0.0201. | These are 2.36, 3.33 and 2.01 percentage points. The authors' later [Ideas for India account](https://www.ideasforindia.in/topics/governance/it-takes-two-terms-to-tango-female-leaders-and-corruption-in-rural-india) uses approximately these correctly scaled values; do not attribute the manuscript typo to that account. |

The causal interpretation also needs the **joint reservation-assignment rule**. Balance on current reservation alone does not establish exchangeability of reservation histories. Table 1 compares current treatment groups; state effects do not recover an undocumented rotation mechanism. The [constitutional amendment](https://www.legislative.gov.in/static/uploads/2025/07/d6e04624ef8b6b869af003909507cfe6.pdf) specifies reservation and rotation, leaving implementation to state rules. Appropriate randomization inference requires those rules and the eligible sets.

The survey question asks whether households **had to pay** a bribe. It cannot separately identify voluntary supply, officials' demands or beliefs about female competence. The accountability outcomes are household reports too. The mechanism remains speculative, as the abstract acknowledges. Two reserved terms also need not involve the same woman; the manuscript acknowledges possible network transmission between women on p. 31.

## Claims and estimands

All main regressions concern household reports for the current council term in the 2006 survey, fielded during 2006–2008. Reservation is measured at GP level. The manuscript describes OLS with state and interview year/month effects; population weighting is not established from the available code. Jharkhand is excluded by missing treatment despite the broader 17-state survey description (p. 12, footnote 10).

| Claim | Measured outcome and comparison | What is established here |
|:--|:--|:--|
| Current reservation raises bribery. | Equation 1; household any-bribe indicator and log amount, current reserved versus unreserved, pooling past histories. | Reported coefficient identified and transcribed; microdata implementation untested. Calling it first-term-only is unsupported by this specification. |
| An additional reserved term reduces bribery. | Equation 2; interaction of current and previous reservation. | Arithmetic verified; direct contrasts reconstructed. Causal identification and uncertainty unresolved. |
| Effects extend to other officials. | Equations 1–2; six official-specific bribery indicators with varying samples. | Outcomes and sample differences identified; unconditional household interpretation unresolved. |
| Experience or trust explains the pattern. | Household assessments of problem-solving and beneficiary selection; female-respondent subgroup. | Associations do not identify mediation. A significant estimate for one respondent group and an insignificant estimate for another do not establish a gender difference. |

## Existing evidence in the sibling projects

The [Rajasthan MGNREGA social-audit analysis](../quota/scripts/17a_raj_social_audit.R) measures works/household verification, job-card possession, staffing and meeting procedures. Its four reservation-cycle coefficients are separate marginal terms, not a repeated-versus-single contrast. The [reported audit table](../quota/tabs/mnrega_raj_05_20_audit.tex) therefore tests different outcomes and histories from REDS bribery.

The [UP](../quota_unquote/tabs/up_pai_effects.csv) and [Rajasthan](../quota_unquote/tabs/raj_pai_effects.csv) PAI 2.0 estimates are near zero: 0.067 points (HC2 95% CI −0.223 to 0.358) and −0.050 (−0.588 to 0.487). These were checked against the saved output, not rerun here. Their [design](../quota_unquote/docs/design.md) treats them as conditional associations. [PAI](../pai/README.md) measures governance procedures; these findings cannot establish a zero effect on household bribes. They motivate testing whether any REDS result extends to independently measured governance.

## Data access and resumption

Brown's [REDS documentation](https://adfdell.pstc.brown.edu/arisreds_data/readme.txt) says the 2006 microdata require approved institutional IRB access. Its [public06 directory](https://adfdell.pstc.brown.edu/arisreds_data/public06/) exposes questionnaires and variable lists. The local `../reds` files are SEPRI 2014, a different wave; the user confirms no 2006 files. No public replication deposit was located in the checked author pages, publication records or targeted repository searches. [sources/manifest.json](sources/manifest.json) records the searches, version and hashes. No authors were contacted.

The public [household variable list](https://adfdell.pstc.brown.edu/arisreds_data/public06/hh_variable_list.pdf#page=76) identifies `hdeck81.dta`, schedule p. 129: `p129q2` contact, `p129q5` bribery and `p129q6` amount for the current term; corresponding prior-term fields are also available. Household demographics require additional modules. The GP reservation fields, merge keys, filters and missing-value codes must be matched to the authors' actual inputs before estimation.

To resume: obtain approved 2006 household/village files and the authors' construction and estimation code, including their SHRUG linkage. Reproduce every main coefficient, SE and N first. Then test contact denominators, zeros, joint assignment support, GP-level inference, leave-one-GP/state-out influence and the direct contrasts above. Report GP-weighted estimates separately because they answer a different population question. A stable negative direct contrast with credible assignment and appropriate uncertainty would support the paper; altered coding or inference could weaken it. No result is presumed.

## Audit coverage

| Check | Status |
|:--|:--|
| Tier 1: denominators; missing versus zero; row loss | Table counts checked; raw-data reconciliation untestable. |
| Tier 1: provenance; internal consistency | Version, table transcription and contrast arithmetic checked; author build unavailable. |
| Tier 2: EDA; joins; construction | Mechanical sweep run on the two table transcriptions only. Household EDA, joins and construction untestable. |
| Tier 2: estimand; inference; skew | Contrasts reconstructed; covariance, clustering and bribe tails untestable. |
| Tier 3: measurement, assignment, attrition, subgroups | Claims reviewed; no raw implementation or gender-difference test available. No registration located; absence not established. |
| Tier 4: randomized/observational assignment, selection, functional form | Joint assignment unresolved; raw sample selection and transformed outcomes untestable. IV, RD and longitudinal outcome DiD are not the manuscript's estimator. |
| Paper moves 1–3: components, bounds, dose | Official components and log bound checked; history contrasts reconstructed; observed cell means unavailable. |
| Paper moves 4–6: mechanism, implementation, ITT/TOT | Mechanism unverified; observed compliance unavailable, so no TOT constructed. |
| Paper moves 7–9: benchmarks, fragility, statements versus behavior | Local estimands distinguished; treated-cell counts checked; inference untestable; self-report scope recorded. |
| Paper moves 10–12: companion work, emphasis, generalizability | Same-survey and local evidence reviewed; appendix caveats retained; national scope qualified by sample and treatment support. |

Rejected criticisms: the interaction does not by itself imply impossible negative bribery probabilities; fixing its interpretation does not reverse the negative direct estimates; the authors do acknowledge interaction arithmetic and possible leader turnover; local PAI/social-audit nulls do not refute this different estimand. Table A2 also contains unusual main-effect entries compared with A3, but these cannot be silently corrected without source code.

## Reproduce the completed checks

```sh
make audit
make test
```

Python 3 standard library only. [scripts/audit_tables.py](scripts/audit_tables.py) verifies transcription hashes, generates [all contrasts](output/contrasts.csv) and [cell-count checks](output/summary.json), and updates the marked table above. Tests recover contrasts from known four-cell means and reject inconsistent reservation counts. These checks establish arithmetic and provenance, not computational reproduction of the paper's regressions. The original PDF is retained locally under ignored `sources/`; restricted microdata belong outside version control.
