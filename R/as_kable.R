#' Convert gtsummary object to a kable object
#'
#' @description Function converts a gtsummary object to a knitr_kable object.
#' This function is used in the background when the results are printed or knit.
#' A user can use this function if they wish to add customized formatting
#' available via [knitr::kable].
#'
#' @description Output from [knitr::kable] is less full featured compared to
#' summary tables produced with [gt](https://gt.rstudio.com/index.html).
#' For example, kable summary tables do not include indentation, footnotes,
#' or spanning header rows.
#'
#' @details Tip: To better distinguish variable labels and level labels when
#' indenting is not supported, try [bold_labels()] or [italicize_levels()].
#'
#' @inheritParams as_gt
#' @param x Object created by a function from the gtsummary package
#' (e.g. [tbl_summary] or [tbl_regression])
#' @inheritParams as_gt
#' @inheritParams as_tibble.gtsummary
#' @param exclude DEPRECATED
#' @param ... Additional arguments passed to [knitr::kable]
#' @export
#' @return A `knitr_kable` object
#' @family gtsummary output types
#' @author Daniel D. Sjoberg
#' @examples
#' trial %>%
#'   tbl_summary(by = trt) %>%
#'   bold_labels() %>%
#'   as_kable()
as_kable <- function(x, include = everything(), return_calls = FALSE,
                     exclude = NULL, ...) {
  # DEPRECATION notes ----------------------------------------------------------
  if (!rlang::quo_is_null(rlang::enquo(exclude))) {
    lifecycle::deprecate_stop(
      "1.2.5",
      "gtsummary::as_kable(exclude = )",
      "as_kable(include = )",
      details = paste0(
        "The `include` argument accepts quoted and unquoted expressions similar\n",
        "to `dplyr::select()`. To exclude commands, use the minus sign.\n",
        "For example, `include = -cols_hide`"
      )
    )
  }

  # running pre-conversion function, if present --------------------------------
  x <- do.call(get_theme_element("pkgwide-fun:pre_conversion", default = identity), list(x))

  # converting row specifications to row numbers, and removing old cmds --------
  x <- .clean_table_styling(x)

  # creating list of kable calls -----------------------------------------------
  kable_calls <-
    table_styling_to_kable_calls(x = x, ...)
  if (return_calls == TRUE) {
    return(kable_calls)
  }

  # converting to character vector ---------------------------------------------
  include <-
    .select_to_varnames(
      select = {{ include }},
      var_info = names(kable_calls),
      arg_name = "include"
    )

  # making list of commands to include -----------------------------------------
  # this ensures list is in the same order as names(x$kable_calls)
  include <- names(kable_calls) %>% intersect(include)
  # user cannot exclude the first 'kable' command
  include <- "tibble" %>% union(include)

  # taking each kable function call, concatenating them with %>% separating them
  kable_calls[include] %>%
    # removing NULL elements
    unlist() %>%
    compact() %>%
    # concatenating expressions with %>% between each of them
    reduce(function(x, y) expr(!!x %>% !!y)) %>%
    # evaluating expressions
    eval()
}

table_styling_to_kable_calls <- function(x, ...) {
  dots <- rlang::enexprs(...)

  kable_calls <- table_styling_to_tibble_calls(x, col_labels = FALSE)


  # fmt_missing ----------------------------------------------------------------
  kable_calls[["fmt_missing"]] <- expr(dplyr::mutate_all(~ ifelse(is.na(.), "", .)))

  # kable ----------------------------------------------------------------------
  df_col_labels <-
    dplyr::filter(x$table_styling$header, .data$hide == FALSE)

  if (!is.null(x$table_styling$caption)) {
    kable_calls[["kable"]] <-
      expr(knitr::kable(caption = !!x$table_styling$caption, col.names = !!df_col_labels$label, !!!dots))
  } else {
    kable_calls[["kable"]] <-
      expr(knitr::kable(col.names = !!df_col_labels$label, !!!dots))
  }

  kable_calls
}
