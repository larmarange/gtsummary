skip_on_cran()

# inline_text.tbl_summary tests --------------

test_inline1 <- trial %>% tbl_summary()
test_inline2 <- trial %>% tbl_summary(by = trt)
test_inline2b <- trial %>%
  tbl_summary(by = trt) %>%
  add_p()

test_that("inline_text.tbl_summary: no by", {
  expect_error(
    inline_text(test_inline1, variable = "age"),
    NA
  )
  expect_warning(
    inline_text(test_inline1, variable = "age"),
    NA
  )
  expect_error(
    inline_text(test_inline1, variable = "stage", level = "T1"),
    NA
  )
  expect_warning(
    inline_text(test_inline1, variable = "stage", level = "T1"),
    NA
  )

  expect_equal(
    inline_text(test_inline1, variable = "stage", level = "T1", pattern = "{p}%"),
    "26%"
  )
  expect_equal(
    inline_text(test_inline1, variable = "age", pattern = "The median is {median}"),
    "The median is 47"
  )
})

test_that("inline_text.tbl_summary: with by", {
  expect_error(
    inline_text(test_inline2, variable = "age", column = "Drug B"),
    NA
  )
  expect_warning(
    inline_text(test_inline2, variable = "age", column = "Drug B"),
    NA
  )
  expect_error(
    inline_text(test_inline2, variable = "stage", level = "T1", column = "Drug B"),
    NA
  )
  expect_warning(
    inline_text(test_inline2, variable = "stage", level = "T1", column = "Drug B"),
    NA
  )
  expect_error(
    inline_text(test_inline2b, variable = "stage", column = "p.value"),
    NA
  )
  expect_warning(
    inline_text(test_inline2b, variable = "stage", column = "p.value"),
    NA
  )
})


test_that("inline_text.tbl_summary: with by -  expect errors", {
  expect_error(
    inline_text(test_inline2, variable = "age", column = "Pla5cebo"),
    NULL
  )
  expect_error(
    inline_text(test_inline2, variable = "stage", level = "Tsdfgsdfg1", column = "Drug B"),
    NULL
  )

  expect_error(
    inline_text(test_inline2, variable = "st55age", level = "T1", column = "Drug B"),
    NULL
  )
})

test_that("inline_text.tbl_summary: no errors with empty string selection", {
  expect_error(
    trial %>%
      select(grade) %>%
      mutate(grade = ifelse(grade == "I", "", as.character(grade))) %>%
      tbl_summary() %>%
      inline_text(variable = grade, level = "III"),
    NA
  )
})


# inline_text.regression tests --------------

test_inline3 <- lm(marker ~ age + stage, trial) %>% tbl_regression()
test_inline4 <- glm(response ~ trt + age + stage, trial, family = binomial) %>%
  tbl_regression(exponentiate = TRUE)

test_that("inline_text.regression", {
  expect_error(
    inline_text(test_inline3, variable = "age"),
    NA
  )
  expect_warning(
    inline_text(test_inline3, variable = "age"),
    NA
  )
  expect_error(
    inline_text(test_inline4, variable = "stage", level = "T2"),
    NA
  )
  expect_warning(
    inline_text(test_inline4, variable = "stage", level = "T2"),
    NA
  )
})


test_that("inline_text.regression -  expect errors", {
  expect_error(
    inline_text(test_inline3, variable = "stage", level = "Tsdfgsdfg1"),
    NULL
  )

  expect_error(
    inline_text(test_inline3, variable = "st55age"),
    NULL
  )
})

# inline_text.tbl_survival tests  --------------
library(survival)
test_inline_surv_strata <-
  survfit(Surv(ttdeath, death) ~ trt, trial) %>%
  tbl_survival(
    times = c(12, 24),
    time_label = "{time} Months"
  )
test_inline_surv_nostrata <-
  survfit(Surv(ttdeath, death) ~ 1, trial) %>%
  tbl_survival(
    times = c(12, 24),
    time_label = "{time} Months"
  )

test_inline_surv_strata2 <-
  survfit(Surv(ttdeath, death) ~ trt, trial) %>%
  tbl_survival(
    probs = c(0.2, 0.5)
  )
test_inline_surv_nostrata2 <-
  survfit(Surv(ttdeath, death) ~ 1, trial) %>%
  tbl_survival(
    probs = c(0.2, 0.5)
  )

# test tbl_survival with strata
test_that("inline_text.tbl_survival - with strata", {
  expect_error(
    inline_text(test_inline_surv_strata, strata = "Drug B", time = 24),
    NA
  )
  expect_error(
    inline_text(test_inline_surv_strata2, strata = "Drug B", prob = 0.2),
    NA
  )
  expect_message(
    inline_text(test_inline_surv_strata, strata = "Drug B", time = 30),
    "Specified 'time'*"
  )
  expect_error(
    inline_text(test_inline_surv_strata, strata = "Drug B", time = -2),
    "Must specify a positive 'time'."
  )
  expect_error(
    inline_text(test_inline_surv_strata, strata = NULL, time = 24),
    "Must specify one of the following strata:*"
  )
  expect_error(
    inline_text(test_inline_surv_strata, strata = "Drururuug", time = 24),
    "Is the strata name spelled correctly*"
  )
})

# test tbl_survival with no strata
test_that("inline_text.tbl_survival - no strata", {
  expect_error(
    inline_text(test_inline_surv_nostrata, time = 24),
    NA
  )
  expect_error(
    inline_text(test_inline_surv_nostrata2, prob = 0.2),
    NA
  )
  expect_warning(
    inline_text(test_inline_surv_nostrata, strata = "Drug B", time = 24),
    "Ignoring strata =*"
  )
})

# inline_text.tbl_survfit tests  --------------
fit1 <- survfit(Surv(ttdeath, death) ~ trt, trial)
fit2 <- survfit(Surv(ttdeath, death) ~ 1, trial)

tbl1 <-
  tbl_survfit(
    fit1,
    times = c(12, 24),
    label = "Treatment",
    label_header = "**{time} Month**"
  ) %>%
  add_p()

tbl2 <- tbl_survfit(
  fit2,
  probs = 0.5
)

test_that("inline_text.tbl_survfit", {
  expect_error(
    inline_text(tbl1, time = 24, level = "Drug A"),
    NA
  )
  expect_warning(
    inline_text(tbl1, time = 24, level = "Drug A"),
    NA
  )

  expect_error(
    tbl1_pvalue <- inline_text(tbl1, column = p.value),
    NA
  )
  expect_equal(tbl1_pvalue, "p=0.2")

  expect_error(
    tbl1_pattern <-
      inline_text(tbl1,
        time = 24, level = "Drug A",
        pattern = "{estimate}", estimate_fun = ~ style_percent(., digits = 3, symbol = TRUE)
      ),
    NA
  )
  expect_equal(tbl1_pattern, "46.939%")

  expect_error(
    inline_text(tbl2, prob = 0.5),
    NA
  )
  expect_warning(
    inline_text(tbl2, prob = 0.5),
    NA
  )
})

# inline_text.tbl_cross tests --------------
test_that("inline_text.tbl_cross", {
  tbl_cross <-
    tbl_cross(trial, row = trt, col = response) %>%
    add_p(percent = "cell")

  expect_equal(
    inline_text(tbl_cross, row_level = "Drug A", col_level = "1"),
    "28"
  )
  expect_equal(
    inline_text(tbl_cross, row_level = "Total", col_level = "1"),
    "61"
  )
  expect_equal(
    inline_text(tbl_cross, col_level = "p.value"),
    "p=0.7"
  )
})



test_that("inline_text.tbl_cross- expect error args aren't present", {
  tbl_cross <-
    tbl_cross(trial, row = trt, col = response) %>%
    add_p(percent = "cell")

  expect_error(
    inline_text(tbl_cross, row_level = "Drug A"),
    NULL
  )
  expect_error(
    inline_text(tbl_cross, col_level = "0"),
    NULL
  )

  expect_error(
    inline_text(tbl_cross),
    NULL
  )
})


# inline_text.tbl_svysummary tests --------------
test_inline1 <- trial %>%
  survey::svydesign(data = ., ids = ~1, weights = ~1) %>%
  tbl_svysummary()
test_inline2 <- trial %>%
  survey::svydesign(data = ., ids = ~1, weights = ~1) %>%
  tbl_svysummary(by = trt)
test_inline2b <- trial %>%
  survey::svydesign(data = ., ids = ~1, weights = ~1) %>%
  tbl_svysummary(by = trt) %>%
  add_p()

test_that("inline_text.tbl_svysummary: no by", {
  expect_error(
    inline_text(test_inline1, variable = "age"),
    NA
  )
  expect_warning(
    inline_text(test_inline1, variable = "age"),
    NA
  )
  expect_error(
    inline_text(test_inline1, variable = "stage", level = "T1"),
    NA
  )
  expect_warning(
    inline_text(test_inline1, variable = "stage", level = "T1"),
    NA
  )

  expect_equal(
    inline_text(test_inline1, variable = "stage", level = "T1", pattern = "{p}%"),
    "26%"
  )
  expect_equal(
    inline_text(test_inline1, variable = "age", pattern = "The median is {median}"),
    "The median is 47"
  )
})

test_that("inline_text.tbl_svysummary: with by", {
  expect_error(
    inline_text(test_inline2, variable = "age", column = "Drug B"),
    NA
  )
  expect_warning(
    inline_text(test_inline2, variable = "age", column = "Drug B"),
    NA
  )
  expect_error(
    inline_text(test_inline2, variable = "stage", level = "T1", column = "Drug B"),
    NA
  )
  expect_warning(
    inline_text(test_inline2, variable = "stage", level = "T1", column = "Drug B"),
    NA
  )
  expect_error(
    inline_text(test_inline2b, variable = "stage", column = "p.value"),
    NA
  )
  expect_warning(
    inline_text(test_inline2b, variable = "stage", column = "p.value"),
    NA
  )
})


test_that("inline_text.tbl_svysummary: with by -  expect errors", {
  expect_error(
    inline_text(test_inline2, variable = "age", column = "Pla5cebo"),
    NULL
  )
  expect_error(
    inline_text(test_inline2, variable = "stage", level = "Tsdfgsdfg1", column = "Drug B"),
    NULL
  )

  expect_error(
    inline_text(test_inline2, variable = "st55age", level = "T1", column = "Drug B"),
    NULL
  )
})

test_that("inline_text.tbl_svysummary: no errors with empty string selection", {
  expect_error(
    trial %>%
      select(grade) %>%
      mutate(grade = ifelse(grade == "I", "", as.character(grade))) %>%
      survey::svydesign(data = ., ids = ~1, weights = ~1) %>%
      tbl_svysummary() %>%
      inline_text(variable = grade, level = "III"),
    NA
  )
})
