suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(rlang))

village_keys <- c(
  "village_sr_no", "village_name", "gram_panchayat",
  "tehsil_taluka", "cd_block", "district"
)

normal_name <- function(x) gsub("[^A-Z0-9]", "", toupper(trimws(x)))

state_name <- function(x) {
  x <- normal_name(x)
  aliases <- c(
    TAMILNDU = "TAMILNADU", TAAMILNADU = "TAMILNADU",
    CHHATISGARH = "CHHATTISGARH", CHHTTISGARH = "CHHATTISGARH",
    HARIYANA = "HARYANA", UP = "UTTARPRADESH", ORISSA = "ODISHA",
    ODISHA15 = "ODISHA", GUJRAT = "GUJARAT", MAHRASHTRA = "MAHARASHTRA"
  )
  replace <- x %in% names(aliases)
  x[replace] <- aliases[x[replace]]
  valid <- c(
    "RAJASTHAN", "JHARKHAND", "TAMILNADU", "HARYANA", "ANDHRAPRADESH",
    "BIHAR", "MADHYAPRADESH", "CHHATTISGARH", "MAHARASHTRA",
    "UTTARPRADESH", "ODISHA", "GUJARAT", "WESTBENGAL"
  )
  x[!x %in% valid] <- NA_character_
  x
}

assert_unique <- function(data, keys) {
  if (anyNA(data[keys]) || anyDuplicated(data[keys])) {
    stop("Missing or duplicate keys: ", paste(keys, collapse = ", "))
  }
  invisible(data)
}

safe_join <- function(left, right, by) {
  assert_unique(right, by)
  result <- left_join(left, right, by = by, relationship = "many-to-one")
  stopifnot(nrow(result) == nrow(left))
  result
}

yes_no <- function(x) ifelse(x %in% 1:2, as.numeric(x == 1), NA_real_)

reason_outcome <- function(card, applied, reason, scheme) {
  stopifnot(scheme %in% c("questionnaire", "stata_labels"))
  bribe <- if (scheme == "questionnaire") 2 else 3
  other <- if (scheme == "questionnaire") 1 else 2
  eligible <- card == 2 & applied == 1
  eligible[is.na(eligible)] <- FALSE
  ifelse(eligible & reason %in% c(bribe, other), as.numeric(reason == bribe), NA_real_)
}

household_outcome <- function(x) {
  if (any(x == 100, na.rm = TRUE)) {
    return(100)
  }
  if (anyNA(x)) {
    return(NA_real_)
  }
  0
}

label_text <- function(x) {
  labels <- attr(x, "labels")
  names(labels)[match(as.numeric(x), as.numeric(labels))]
}

read_wave <- function(root, wave) {
  read_module <- function(path) haven::read_dta(file.path(root, wave, path))
  village <- read_module("Village/VILLAGE_DETAIL.dta")
  assert_unique(village, village_keys)
  village$gp <- paste(wave, seq_len(nrow(village)), sep = "_")
  village$state <- state_name(village$q1_1h)
  gp_keys <- normal_name(paste(
    state_name(village$q1_1h), village$district,
    village$tehsil_taluka, village$gram_panchayat
  ))
  if (anyDuplicated(gp_keys)) stop("Multiple sampled villages per GP need reconciliation")
  election <- read_module("Village/SECTION_11_D.dta")
  election_key <- election[c(village_keys, "s11_d1_p35_q01")]
  duplicate_term <- duplicated(election_key) | duplicated(election_key, fromLast = TRUE)
  ambiguous_election_rows <- sum(duplicate_term)
  election <- election[!duplicate_term, ]
  assert_unique(election, c(village_keys, "s11_d1_p35_q01"))
  stopifnot(all(election$s11_d1_p35_q01 %in% 1:2))
  for (term in 1:2) {
    nm <- if (term == 1) "current" else "previous"
    e <- election[election$s11_d1_p35_q01 == term, village_keys]
    e[[nm]] <- yes_no(election$s11_d1_p35_q07[election$s11_d1_p35_q01 == term])
    e[[paste0(nm, "_year")]] <- election$s11_d1_p35_q03[election$s11_d1_p35_q01 == term]
    village <- safe_join(village, e, village_keys)
  }
  bad_order <- with(
    village,
    !is.na(current_year) & !is.na(previous_year) & current_year <= previous_year
  )
  village$current[bad_order] <- NA_real_
  village$previous[bad_order] <- NA_real_
  land <- read_module("Village/SECTION_05.dta")
  land <- land[land$s05_p23_q1 == 7, ]
  assert_unique(land, village_keys)
  land$payment <- as.numeric(land$s05_p23_q5)
  land$payment_2006 <- as.numeric(land$s05_p23_q6)
  land_missing <- sum(is.na(land$payment))
  land_alternate_only <- sum(is.na(land$payment) & !is.na(land$s05_p23_q3))
  stopifnot(
    all(land$payment >= 0, na.rm = TRUE),
    all(land$payment_2006 >= 0, na.rm = TRUE)
  )
  village <- safe_join(village, land[c(village_keys, "payment", "payment_2006")], village_keys)

  hh <- read_module("HH/SECTION09.dta")
  hh$state_name <- state_name(label_text(hh$state))
  hh$district_name <- normal_name(label_text(hh$district))
  hh$village_name <- normal_name(label_text(hh$village))
  hh_keys <- c("state", "district", "taluk", "block", "panchayat", "village", "q1_1", "q9_2")
  eligible <- hh$q9_6 == 2 & hh$q9_7 == 1
  eligible[is.na(eligible)] <- FALSE
  person <- hh[eligible, ]
  # Exclude every ambiguous person key; never select an arbitrary repeated record.
  dup <- duplicated(person[hh_keys]) | duplicated(person[hh_keys], fromLast = TRUE)
  missing_key <- !complete.cases(person[hh_keys])
  person <- person[!dup & !missing_key, ]
  assert_unique(person, hh_keys)
  lookup <- distinct(hh, across(all_of(c("state_name", "district_name", "village_name"))))
  good_lookup <- complete.cases(lookup) & lookup$district_name != "" &
    lookup$village_name != ""
  lookup <- lookup[good_lookup, ]
  candidates <- bind_rows(lapply(c("district", "q1_1g"), function(district_col) {
    bind_rows(lapply(c("village_name", "q1_1a"), function(village_col) {
      data.frame(
        gp = village$gp, state_recorded = village$state,
        district_name = normal_name(village[[district_col]]),
        village_name = normal_name(village[[village_col]])
      )
    }))
  })) |> distinct()
  matches <- inner_join(lookup, candidates,
    by = c("district_name", "village_name"),
    relationship = "many-to-many"
  ) |>
    filter(is.na(.data$state_recorded) | .data$state_name == .data$state_recorded) |>
    distinct(across(all_of(c("state_name", "district_name", "village_name", "gp")))) |>
    group_by(.data$state_name, .data$district_name, .data$village_name) |>
    filter(n_distinct(.data$gp) == 1) |>
    ungroup() |>
    group_by(.data$gp) |>
    filter(n() == 1) |>
    ungroup()
  assert_unique(matches, c("state_name", "district_name", "village_name"))
  assert_unique(matches, "gp")
  inferred <- matches$state_name[match(village$gp, matches$gp)]
  fill_state <- is.na(village$state) & !is.na(inferred)
  village$state[fill_state] <- inferred[fill_state]
  person <- safe_join(person, matches, c("state_name", "district_name", "village_name"))
  matched <- !is.na(person$gp)
  person <- safe_join(
    person[matched, ],
    village[c("gp", "current", "previous")], "gp"
  )
  person$state <- person$state_name
  person$household <- paste(wave, interaction(person[setdiff(hh_keys, "q9_2")], drop = TRUE))
  for (scheme in c("questionnaire", "stata_labels")) {
    person[[scheme]] <- reason_outcome(person$q9_6, person$q9_7, person$q9_9, scheme)
  }
  list(
    village = village[c(
      "gp", "state", "current", "previous", "current_year",
      "previous_year", "payment", "payment_2006"
    )],
    person = person[c(
      "gp", "state", "current", "previous", "household",
      "questionnaire", "stata_labels"
    )],
    audit = data.frame(
      wave = wave, village_records = nrow(village),
      household_module_rows = nrow(hh), applicants_without_card = sum(eligible),
      ambiguous_person_rows = sum(dup), missing_person_keys = sum(missing_key),
      matched_applicants = sum(matched), unmatched_applicants = sum(!matched),
      exact_matched_villages = nrow(matches),
      state_inferred_from_exact_link = sum(fill_state),
      nonchronological_histories = sum(bad_order),
      ambiguous_election_rows = ambiguous_election_rows,
      land_missing_values = land_missing,
      land_alternate_only = land_alternate_only,
      reason_outside_route = sum(!eligible & !is.na(hh$q9_9))
    )
  )
}

contrast_data <- function(data, contrast) {
  data$interaction <- data$current * data$previous
  if (contrast == "interaction") {
    data$target <- data$interaction
    data$other1 <- data$current
    data$other2 <- data$previous
  } else if (contrast == "both_vs_previous_only") {
    data$target <- data$current
    data$other1 <- data$previous
    data$other2 <- data$interaction - data$current
  } else if (contrast == "both_vs_current_only") {
    data$target <- data$previous
    data$other1 <- data$current
    data$other2 <- data$interaction - data$previous
  } else if (contrast == "both_vs_neither") {
    data$target <- data$interaction
    data$other1 <- data$current * (1 - data$previous)
    data$other2 <- (1 - data$current) * data$previous
  } else {
    stop("Unknown contrast")
  }
  data
}

fit_contrast <- function(data, contrast, baseline = FALSE) {
  data <- contrast_data(data, contrast)
  rhs <- c("target", "other1", "other2")
  if (length(unique(data$state)) > 1) rhs <- c(rhs, "factor(state)")
  if (baseline) rhs <- c(rhs, "payment_2006")
  model <- lm(reformulate(rhs, response = "y"), data = data)
  if (anyNA(coef(model))) stop("Rank-deficient model")
  model
}

estimate_sample <- function(data, name, draws, seed, baseline = FALSE) {
  required <- c("y", "state", "current", "previous", "gp")
  if (baseline) required <- c(required, "payment_2006")
  eligible <- complete.cases(data[required])
  missingness <- data |>
    mutate(included = eligible) |>
    group_by(.data$current, .data$previous) |>
    summarise(rows = n(), observed = sum(.data$included), .groups = "drop") |>
    mutate(sample = name)
  data <- data[eligible, ]
  data$cell <- 2 * data$current + data$previous
  if (!all(0:3 %in% data$cell)) stop("Missing reservation cell in ", name)
  stopifnot(all(is.finite(data$y)), length(unique(data$gp)) > 10)
  cells <- data |>
    group_by(.data$current, .data$previous) |>
    summarise(
      observations = n(), gps = n_distinct(.data$gp), mean = mean(.data$y),
      median = median(.data$y), minimum = min(.data$y), maximum = max(.data$y), .groups = "drop"
    ) |>
    mutate(sample = name)
  contrasts <- c("interaction", "both_vs_previous_only", "both_vs_current_only", "both_vs_neither")
  rows <- lapply(seq_along(contrasts), function(i) {
    contrast <- contrasts[i]
    fit <- fit_contrast(data, contrast, baseline)
    se <- clubSandwich::coef_test(fit,
      vcov = "CR2", cluster = data$gp,
      coefs = "target", test = "Satterthwaite"
    )
    ci <- se$beta + c(-1, 1) * qt(.975, se$df_Satt) * se$SE
    set.seed(seed + i)
    dqrng::dqset.seed(seed + i)
    boot <- fwildclusterboot::boottest(fit,
      param = "target", clustid = "gp",
      B = draws, type = "rademacher", impose_null = TRUE,
      bootstrap_type = "11", conf_int = FALSE,
      engine = "R", nthreads = 1
    )
    set.seed(seed + i)
    dqrng::dqset.seed(seed + i)
    webb <- fwildclusterboot::boottest(fit,
      param = "target", clustid = "gp",
      B = draws, type = "webb", impose_null = TRUE,
      bootstrap_type = "11", conf_int = FALSE,
      engine = "R", nthreads = 1
    )
    stopifnot(
      boot$N == nrow(data), length(boot$t_boot) == draws,
      all(is.finite(boot$t_boot)), all(is.finite(webb$t_boot)),
      length(webb$t_boot) == draws, boot$N_G == n_distinct(data$gp)
    )
    influence <- lapply(c("gp", "state"), function(group) {
      values <- vapply(unique(data[[group]]), function(value) {
        reduced <- data[data[[group]] != value, ]
        tryCatch(unname(coef(fit_contrast(reduced, contrast, baseline))["target"]),
          error = function(e) NA_real_
        )
      }, numeric(1))
      data.frame(
        group = group, minimum = min(values, na.rm = TRUE),
        maximum = max(values, na.rm = TRUE), failures = sum(is.na(values))
      )
    })
    influence <- bind_rows(influence)
    data.frame(
      sample = name, contrast = contrast, estimate = se$beta,
      cr2_se = se$SE, cr2_df = se$df_Satt, cr2_p = se$p_Satt,
      ci_low = ci[1], ci_high = ci[2], wild_p = boot$p_val,
      webb_p = webb$p_val, observations = nrow(data), gps = n_distinct(data$gp),
      states = n_distinct(data$state), bootstrap_draws = draws, seed = seed + i,
      design_rank = fit$rank, condition_number = kappa(model.matrix(fit)),
      max_leverage = max(hatvalues(fit)),
      fitted_out_of_range = if (grepl("jobcard", name)) {
        sum(fitted(fit) < 0 | fitted(fit) > 100)
      } else {
        NA_integer_
      },
      failed_bootstrap_draws = sum(!is.finite(boot$t_boot)),
      leave_gp_min = influence$minimum[1], leave_gp_max = influence$maximum[1],
      leave_gp_failures = influence$failures[1],
      leave_state_min = influence$minimum[2], leave_state_max = influence$maximum[2],
      leave_state_failures = influence$failures[2]
    )
  })
  state_support <- data |>
    group_by(.data$state, .data$current, .data$previous) |>
    summarise(observations = n(), gps = n_distinct(.data$gp), .groups = "drop") |>
    mutate(sample = name)
  list(
    estimates = bind_rows(rows), cells = cells, missingness = missingness,
    state_support = state_support
  )
}

update_sepri_readme <- function(estimates, cells) {
  labels <- c(
    land_payment_rupees = "Unofficial land-record payment (rupees)",
    jobcard_questionnaire_household_pp = "Job-card demand: questionnaire coding (pp)",
    jobcard_stata_labels_household_pp = "Job-card demand: Stata-label coding (pp)"
  )
  comparisons <- c(
    both_vs_previous_only = "Both vs previous only",
    both_vs_current_only = "Both vs current only"
  )
  show <- estimates$sample %in% names(labels) &
    estimates$contrast %in% names(comparisons)
  selected <- estimates[show, ]
  lines <- c(
    "| Outcome | Comparison | Difference | 95% CI (CR2) | Wild bootstrap p | GPs |",
    "|:--|:--|--:|:--|--:|--:|"
  )
  for (i in seq_len(nrow(selected))) {
    x <- selected[i, ]
    lines <- c(lines, sprintf(
      "| %s | %s | %.2f | %.2f to %.2f | %.3f | %d |",
      labels[x$sample], comparisons[x$contrast], x$estimate,
      x$ci_low, x$ci_high, x$wild_p, x$gps
    ))
  }
  control_rows <- cells$current == 0 & cells$previous == 0 &
    cells$sample %in% names(labels)
  controls <- cells[control_rows, ]
  lines <- c(lines, "", sprintf(
    paste(
      "Among GPs reserved in neither term, the reported land-record payment averages",
      "%.2f rupees. Among eligible households in that history, the job-card demand",
      "share is %.2f%% under questionnaire coding and %.2f%% under Stata-label coding.",
      "The coding changes both the outcome and which responses count as known."
    ),
    controls$mean[controls$sample == "land_payment_rupees"],
    controls$mean[controls$sample == "jobcard_questionnaire_household_pp"],
    controls$mean[controls$sample == "jobcard_stata_labels_household_pp"]
  ))
  path <- "README.md"
  text <- readLines(path)
  start <- which(text == "<!-- SEPRI_RESULTS_START -->")
  end <- which(text == "<!-- SEPRI_RESULTS_END -->")
  stopifnot(length(start) == 1, length(end) == 1, start < end)
  writeLines(c(text[seq_len(start)], "", lines, "", text[end:length(text)]), path)
}

main <- function() {
  root <- Sys.getenv("REDS_DATA_DIR", "../reds/data")
  pinned <- jsonlite::read_json("sources/sepri_inputs.json", simplifyVector = TRUE)
  for (path in names(pinned$sha256)) {
    observed <- digest::digest(file.path(root, path), algo = "sha256", file = TRUE)
    if (observed != pinned$sha256[[path]]) stop("Source changed: ", path)
  }
  out <- "output/sepri"
  dir.create(out, recursive = TRUE, showWarnings = FALSE)
  waves <- lapply(c("Sepri1", "Sepri2"), function(w) read_wave(root, w))
  village <- bind_rows(lapply(waves, `[[`, "village"))
  person <- bind_rows(lapply(waves, `[[`, "person"))
  audit <- bind_rows(lapply(waves, `[[`, "audit"))
  draws <- as.integer(Sys.getenv("BOOTSTRAP_DRAWS", "9999"))
  stopifnot(!is.na(draws), draws >= 199)
  seed <- 20261004L
  samples <- list()
  village$y <- village$payment
  samples$land_payment_rupees <- list(data = village, baseline = FALSE)
  village$y <- log1p(village$payment)
  samples$land_payment_log1p <- list(data = village, baseline = FALSE)
  village$y <- village$payment
  before_current <- !is.na(village$current_year) & village$current_year > 2006
  samples$land_payment_baseline_adjusted <- list(data = village[before_current, ], baseline = TRUE)
  for (scheme in c("questionnaire", "stata_labels")) {
    person$y <- 100 * person[[scheme]]
    samples[[paste0("jobcard_", scheme, "_person_pp")]] <- list(data = person, baseline = FALSE)
    household <- person |>
      group_by(.data$gp, .data$state, .data$current, .data$previous, .data$household) |>
      summarise(y = household_outcome(.data$y), .groups = "drop")
    household_name <- paste0("jobcard_", scheme, "_household_pp")
    samples[[household_name]] <- list(data = household, baseline = FALSE)
    gp <- household |>
      filter(!is.na(.data$y)) |>
      group_by(.data$gp, .data$state, .data$current, .data$previous) |>
      summarise(y = mean(.data$y), .groups = "drop")
    samples[[paste0("jobcard_", scheme, "_gp_pp")]] <- list(data = gp, baseline = FALSE)
  }
  results <- lapply(seq_along(samples), function(i) {
    message("Estimating ", names(samples)[i])
    estimate_sample(
      samples[[i]]$data, names(samples)[i], draws, seed + 100L * i,
      samples[[i]]$baseline
    )
  })
  estimates <- bind_rows(lapply(results, `[[`, "estimates"))
  estimates$wild_p_holm <- p.adjust(estimates$wild_p, method = "holm")
  write.csv(estimates, file.path(out, "estimates.csv"), row.names = FALSE, na = "")
  write.csv(bind_rows(lapply(results, `[[`, "cells")), file.path(out, "cell_summary.csv"),
    row.names = FALSE, na = ""
  )
  write.csv(bind_rows(lapply(results, `[[`, "missingness")), file.path(out, "sample_flow.csv"),
    row.names = FALSE, na = ""
  )
  write.csv(audit, file.path(out, "data_checks.csv"), row.names = FALSE, na = "")
  write.csv(bind_rows(lapply(results, `[[`, "state_support")),
    file.path(out, "state_support.csv"),
    row.names = FALSE, na = ""
  )
  paths <- unlist(lapply(c("Sepri1", "Sepri2"), function(w) {
    file.path(w, c(
      "Village/VILLAGE_DETAIL.dta", "Village/SECTION_11_D.dta",
      "Village/SECTION_05.dta", "HH/SECTION09.dta"
    ))
  }))
  provenance <- list(
    sources = setNames(lapply(paths, function(p) {
      digest::digest(file.path(root, p),
        algo = "sha256", file = TRUE
      )
    }), paths),
    packages = setNames(
      lapply(
        c("haven", "dplyr", "clubSandwich", "fwildclusterboot", "dqrng"),
        function(p) as.character(packageVersion(p))
      ),
      c("haven", "dplyr", "clubSandwich", "fwildclusterboot", "dqrng")
    ),
    r_version = as.character(getRversion()), draws = draws, seed = seed,
    design = paste(
      "Exploratory conditional associations, state fixed effects;",
      "no assignment rule established"
    ),
    intervals = "CR2 with Satterthwaite degrees of freedom; not bootstrap intervals",
    bootstrap = "Null-imposed WCR11, GP clusters, Rademacher and Webb weights, two-sided",
    multiplicity = "Holm adjustment across all reported outcome/contrast combinations",
    jobcard = paste(
      "Applicants without a card, definitive reasons under each coding;",
      "unresolved codebook conflict"
    ),
    land = "Village-reported current unofficial RoR payment: section 05 row 7, Now (Value) column",
    linkage = paste(
      "Exact normalized district/village labels, unique in both directions,",
      "compatible state; no fuzzy matches"
    )
  )
  jsonlite::write_json(provenance, file.path(out, "provenance.json"),
    pretty = TRUE, auto_unbox = TRUE
  )
  update_sepri_readme(estimates, bind_rows(lapply(results, `[[`, "cells")))
  display <- c("sample", "contrast", "estimate", "ci_low", "ci_high", "wild_p", "gps")
  print(estimates[display], row.names = FALSE)
}

if (sys.nframe() == 0L) main()
