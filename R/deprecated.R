#' Deprecated functions
#'
#' \lifecycle{deprecated}
#' Some functions have been deprecated and are no longer being actively
#' supported.
#'
#' @name deprecated
#' @keywords internal
NULL

# tentative deprecation schedule
# "warn" for at least 9 month
# "stop" after 12 months
# "delete" after 24 months?

# v1.1.0 (2019-08-08) ----------------------------------------------------------
#' @rdname deprecated
#' @export
add_comparison <- function(...) {
  lifecycle::deprecate_stop("1.1.0", "gtsummary::add_comparison()", "add_p()")
}

#' @rdname deprecated
#' @export
add_global <- function(...) {
  lifecycle::deprecate_stop("1.1.0", "gtsummary::add_global()", "add_global_p()")
}

# v1.2.0 (2019-08-19) ----------------------------------------------------------
#' @rdname deprecated
#' @export

tab_style_bold_p <- function(...) {
  lifecycle::deprecate_stop("1.2.0", "gtsummary::tab_style_bold_p()", "bold_p()")
}

#' @rdname deprecated
#' @export
tab_style_bold_labels <- function(...) {
  lifecycle::deprecate_stop("1.2.0", "gtsummary::tab_style_bold_labels()", "bold_labels()")
}

#' @rdname deprecated
#' @export
tab_style_italicize_levels <- function(...) {
  lifecycle::deprecate_stop("1.2.0", "gtsummary::tab_style_italicize_levels()", "italicize_levels()")
}

#' @rdname deprecated
#' @export
tab_style_italicize_labels <- function(...) {
  lifecycle::deprecate_stop("1.2.0", "gtsummary::tab_style_italicize_labels()", "italicize_labels()")
}

#' @rdname deprecated
#' @export
tab_style_bold_levels <- function(...) {
  lifecycle::deprecate_stop("1.2.0", "gtsummary::tab_style_bold_levels()", "bold_levels()")
}

# v1.2.5 (2020-02-11) ----------------------------------------------------------
#' @rdname deprecated
#' @export
tbl_summary_ <- function(...) {
  lifecycle::deprecate_stop("1.2.5", "gtsummary::tbl_summary_()", "tbl_summary()")
}

#' @rdname deprecated
#' @export
add_p_ <- function(...) {
  lifecycle::deprecate_stop("1.2.5", "gtsummary::add_p_()", "add_p()")
}

# v1.3.3 (2020-08-11) ----------------------------------------------------------
#' @rdname deprecated
#' @export
as_flextable <- function(...) {
  lifecycle::deprecate_warn(
    "1.3.3", "gtsummary::as_flextable()", "as_flex_table()",
    details = paste(
      "The `as_flextable()` function graduated",
      "from 'Experimental' status in v1.3.3. The function's name was changed",
      "to avoid a name conflict with `flextable::as_flextable()`.",
      "If you are trying to use the function",
      "from {flextable}, for the time being, use the double colon notation",
      "when both {gtsummary} and {flextable}",
      "are loaded, e.g. `flextable::as_flextable(...)`."
    ) %>%
      stringr::str_wrap()
  )

  # passing args to `as_flex_table()` ------------------------------------------
  as_flex_table(...)
}

# v1.3.6 -----------------------------------------------------------------------
#' @rdname deprecated
#' @export
all_numeric <- function() {
  lifecycle::deprecate_warn(
    "1.3.6", "gtsummary::all_numeric()",
    details = paste0(
      "The {tidyselect} and {dplyr} packages have implemented functions to ",
      "select variables by class and type, and the {gtsummary} version is ",
      "now deprecated.\n\n",
      "Use `where(is.numeric)` instead."
    )
  )

  where(is.numeric)
}


#' @rdname deprecated
#' @export
all_character <- function() {
  lifecycle::deprecate_warn(
    "1.3.6", "gtsummary::all_character()",
    details = paste0(
      "The {tidyselect} and {dplyr} packages have implemented functions to ",
      "select variables by class and type, and the {gtsummary} version is ",
      "now deprecated.\n\n",
      "Use `where(is.character)` instead."
    )
  )

  where(is.character)
}

#' @rdname deprecated
#' @export
all_integer <- function() {
  lifecycle::deprecate_warn(
    "1.3.6", "gtsummary::all_integer()",
    details = paste0(
      "The {tidyselect} and {dplyr} packages have implemented functions to ",
      "select variables by class and type, and the {gtsummary} version is ",
      "now deprecated.\n\n",
      "Use `where(is.integer)` instead."
    )
  )

  where(is.integer)
}

#' @rdname deprecated
#' @export
all_double <- function() {
  lifecycle::deprecate_warn(
    "1.3.6", "gtsummary::all_double()",
    details = paste0(
      "The {tidyselect} and {dplyr} packages have implemented functions to ",
      "select variables by class and type, and the {gtsummary} version is ",
      "now deprecated.\n\n",
      "Use `where(is.double)` instead."
    )
  )

  where(is.double)
}

#' @rdname deprecated
#' @export
all_logical <- function() {
  lifecycle::deprecate_warn(
    "1.3.6", "gtsummary::all_logical()",
    details = paste0(
      "The {tidyselect} and {dplyr} packages have implemented functions to ",
      "select variables by class and type, and the {gtsummary} version is ",
      "now deprecated.\n\n",
      "Use `where(is.logical)` instead."
    )
  )

  where(is.logical)
}

#' @rdname deprecated
#' @export
all_factor <- function() {
  lifecycle::deprecate_warn(
    "1.3.6", "gtsummary::all_factor()",
    details = paste0(
      "The {tidyselect} and {dplyr} packages have implemented functions to ",
      "select variables by class and type, and the {gtsummary} version is ",
      "now deprecated.\n\n",
      "Use `where(is.factor)` instead."
    )
  )

  where(is.factor)
}

# this is a copy of the tidyselect where function. it can be deleted after the
# all_factor, all_character, etc. functions are fully deprecated
where <- function(fn) {
  predicate <- rlang::as_function(fn)

  function(x, ...) {
    out <- predicate(x, ...)

    if (!rlang::is_bool(out)) {
      abort("`where()` must be used with functions that return `TRUE` or `FALSE`.")
    }

    out
  }
}
