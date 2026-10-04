library(testthat)
source("scripts/sepri_analysis.R")

test_that("missing and invalid reservation codes stay missing", {
  expect_equal(yes_no(c(1, 2, 5, NA)), c(1, 0, NA, NA))
})

test_that("reason coding respects eligibility and codebook ambiguity", {
  card <- c(2, 2, 2, 1, 2, NA, 2)
  applied <- c(1, 1, 1, 1, 2, 1, 1)
  reason <- c(1, 2, 3, 2, 2, 2, 9)
  expect_equal(
    reason_outcome(card, applied, reason, "questionnaire"),
    c(0, 1, NA, NA, NA, NA, NA)
  )
  expect_equal(
    reason_outcome(card, applied, reason, "stata_labels"),
    c(NA, 0, 1, NA, NA, NA, NA)
  )
  expect_error(reason_outcome(card, applied, reason, "unknown"))
})

test_that("household negatives require all applicant reasons to be observed", {
  expect_equal(household_outcome(c(100, NA)), 100)
  expect_equal(household_outcome(c(0, 0)), 0)
  expect_true(is.na(household_outcome(c(0, NA))))
  expect_true(is.na(household_outcome(c(NA, NA))))
})

test_that("joins reject multiplication and preserve unmatched rows", {
  left <- data.frame(key = c(1, 1, 2), x = 1:3)
  right <- data.frame(key = 1, y = 4)
  result <- safe_join(left, right, "key")
  expect_equal(nrow(result), 3L)
  expect_true(is.na(result$y[3]))
  expect_error(safe_join(left, rbind(right, right), "key"), "duplicate")
})

fixture <- expand.grid(current = 0:1, previous = 0:1, replicate = 1:20, member = 1:3)
fixture$state <- rep(c("A", "B"), each = 4, length.out = nrow(fixture))
fixture$gp <- as.integer(interaction(fixture$current, fixture$previous, fixture$replicate))
set.seed(731)
fixture$y <- 40 + 10 * fixture$current - 10 * fixture$previous -
  10 * fixture$current * fixture$previous +
  rnorm(80)[fixture$gp] + rnorm(nrow(fixture), sd = .1)

test_that("direct contrasts and clustered variances recover linear combinations", {
  model <- lm(y ~ current * previous + factor(state), data = fixture)
  covariance <- clubSandwich::vcovCR(model, cluster = fixture$gp, type = "CR2")
  combinations <- list(
    interaction = c("current:previous"),
    both_vs_previous_only = c("current", "current:previous"),
    both_vs_current_only = c("previous", "current:previous"),
    both_vs_neither = c("current", "previous", "current:previous")
  )
  for (contrast in names(combinations)) {
    terms <- combinations[[contrast]]
    fit <- fit_contrast(fixture, contrast)
    v <- clubSandwich::vcovCR(fit, cluster = fixture$gp, type = "CR2")
    expect_equal(unname(coef(fit)["target"]), sum(coef(model)[terms]), tolerance = 1e-10)
    expect_equal(unname(v["target", "target"]), sum(covariance[terms, terms]), tolerance = 1e-10)
  }
})

test_that("the bootstrap uses GP clusters and reproducible draws", {
  first <- estimate_sample(fixture, "fixture", 199L, 731L)$estimates
  second <- estimate_sample(fixture, "fixture", 199L, 731L)$estimates
  expect_equal(first, second)
  expect_true(all(first$gps == 80))
  expect_true(all(first$bootstrap_draws == 199))
  expect_true(all(first$failed_bootstrap_draws == 0))
  expect_true(all(first$wild_p >= 0 & first$wild_p <= 1))
  truth <- c(-10, 0, -20, -10)
  expect_true(all(first$ci_low < truth & first$ci_high > truth))
})
