# convert columns that use row and values to format ----------------------------
.convert_table_header_to_styling <- function(x) {
  if (!is.null(x$table_styling)) {
    paste(
      "{.field gtsummary} object was created with code from with {.val <v1.4.0} and {.val >=v1.4.0}.",
      "Unexpected formatting may occur."
    ) %>%
      str_wrap() %>%
      cli_alert_info()
  }

  paste(
    "Updating {.field gtsummary} object from {.code x$table_header} to",
    "{.code x$table_styling} introduced in {.val v1.4.0}."
  ) %>%
    str_wrap() %>%
    cli_alert_info()

  x$table_styling$header <-
    x$table_header %>%
    mutate(interpret_spanning_header = "gt::md") %>%
    select(.data$column, .data$hide, .data$align,
      interpret_label = .data$text_interpret, .data$label,
      .data$interpret_spanning_header, .data$spanning_header
    )

  x <-
    x %>%
    .convert_header_to_rows_one_column("footnote") %>%
    .convert_header_to_rows_one_column("footnote_abbrev") %>%
    .convert_header_to_rows_one_column("missing_emdash") %>%
    .convert_header_to_rows_one_column("indent") %>%
    .convert_header_to_rows_one_column("bold") %>%
    .convert_header_to_rows_one_column("italic") %>%
    .convert_header_to_rows_one_column("fmt_fun")

  x$table_header <- NULL
  x
}


.convert_header_to_rows_one_column <- function(x, column) {
  if (column %in% c("footnote", "footnote_abbrev")) {
    x$table_styling[[column]] <-
      x$table_header %>%
      select(all_of(c("column", .env$column))) %>%
      set_names(c("column", "footnote")) %>%
      filter(!is.na(.data$footnote)) %>%
      mutate(
        rows = list(expr(NULL)),
        text_interpret = "gt::md"
      ) %>%
      select(all_of(c("column", "rows", "text_interpret", "footnote")))
  }
  else if (column %in% c("indent", "bold", "italic")) {
    x$table_styling$text_format <-
      x$table_header %>%
      select(all_of(c("column", .env$column))) %>%
      filter(!is.na(.data[[column]])) %>%
      set_names(c("column", "rows")) %>%
      mutate(
        rows = map(.data$rows, parse_expr),
        format_type = .env$column,
        undo_text_format = FALSE
      ) %>%
      bind_rows(x$table_styling$text_format)
  }
  else if (column %in% "missing_emdash") {
    x$table_styling[["fmt_missing"]] <-
      x$table_header %>%
      select(all_of(c("column", .env$column))) %>%
      filter(!is.na(.data[[column]])) %>%
      set_names(c("column", "rows")) %>%
      mutate(
        rows = map(.data$rows, parse_expr),
        symbol = get_theme_element("tbl_regression-str:ref_row_text",
          default = "\U2014"
        )
      )
  }
  else if (column %in% "fmt_fun") {
    x$table_styling[[column]] <-
      x$table_header %>%
      select(all_of(c("column", .env$column))) %>%
      filter(!map_lgl(.data[[column]], is.null)) %>%
      mutate(rows = list(expr(NULL))) %>%
      select(all_of(c("column", "rows", .env$column)))
  }

  # return gtsummary table
  x
}

# takes a table_body and a character rows expression, and returns the resulting row numbers
.rows_expr_to_row_numbers <- function(table_body, rows, return_when_null = NA) {
  rows_evaluated <- rlang::eval_tidy(rows, data = table_body)

  if (is.null(rows_evaluated)) {
    return(return_when_null)
  }
  which(rows_evaluated)
}

.cols_to_show <- function(x) {
  x$table_styling$header %>%
    filter(!.data$hide) %>%
    pull(.data$column)
}


# 1. Converts row expressions to row numbers, and only keeps the most recent.
# 2. Deletes NA footnote, text_formatting undoings, etc. as they will not be used
.clean_table_styling <- function(x) {
  if (is.null(x$table_styling)) x <- .convert_table_header_to_styling(x)

  # text_format ----------------------------------------------------------------
  x$table_styling$text_format <-
    x$table_styling$text_format %>%
    filter(.data$column %in% .cols_to_show(x)) %>%
    rowwise() %>%
    mutate(
      row_numbers =
        switch(nrow(.) == 0,
          integer(0)
        ) %||%
          .rows_expr_to_row_numbers(
            x$table_body, .data$rows,
            return_when_null = seq_len(nrow(x$table_body))
          ) %>%
          list(),
    ) %>%
    select(-.data$rows) %>%
    unnest(.data$row_numbers) %>%
    group_by(.data$column, .data$row_numbers, .data$format_type) %>%
    filter(row_number() == n()) %>%
    filter(.data$undo_text_format == FALSE) %>%
    # dropping undoing cmds
    group_by(.data$column, .data$format_type) %>%
    nest(row_numbers = .data$row_numbers) %>%
    mutate(row_numbers = map(.data$row_numbers, ~ unlist(.x) %>% unname())) %>%
    select(.data$column, .data$row_numbers, everything()) %>%
    ungroup()

  # fmt_missing ----------------------------------------------------------------
  x$table_styling$fmt_missing <-
    x$table_styling$fmt_missing %>%
    filter(.data$column %in% .cols_to_show(x)) %>%
    rowwise() %>%
    mutate(
      row_numbers =
        switch(nrow(.) == 0,
          integer(0)
        ) %||%
          .rows_expr_to_row_numbers(x$table_body, .data$rows) %>% list(),
    ) %>%
    select(-.data$rows) %>%
    unnest(.data$row_numbers) %>%
    group_by(.data$column, .data$row_numbers) %>%
    filter(row_number() == n()) %>%
    select(.data$column, .data$row_numbers, .data$symbol) %>%
    ungroup()

  # footnote -------------------------------------------------------------------
  x$table_styling$footnote <-
    .clean_table_styling_footnote(x, "footnote")

  # footnote_abbrev ------------------------------------------------------------
  x$table_styling$footnote_abbrev <-
    .clean_table_styling_footnote(x, "footnote_abbrev")

  # fmt_fun --------------------------------------------------------------------
  x$table_styling$fmt_fun <-
    x$table_styling$fmt_fun %>%
    # filter(.data$column %in% .cols_to_show(x)) %>%
    rowwise() %>%
    mutate(
      row_numbers =
        switch(nrow(.) == 0,
          integer(0)
        ) %||%
          .rows_expr_to_row_numbers(x$table_body, .data$rows,
            return_when_null = seq_len(nrow(x$table_body))
          ) %>% list()
    ) %>%
    select(-.data$rows) %>%
    unnest(.data$row_numbers) %>%
    group_by(.data$column, .data$row_numbers) %>%
    filter(row_number() == n()) %>%
    ungroup() %>%
    nest(row_numbers = .data$row_numbers) %>%
    mutate(row_numbers = map(.data$row_numbers, ~ unlist(.x) %>% unname()))

  # cols_merge -----------------------------------------------------------------
  x$table_styling$cols_merge <-
    x$table_styling$cols_merge %>%
    group_by(.data$column) %>%
    filter(dplyr::row_number() == dplyr::n(), !is.na(.data$pattern)) %>%
    rowwise() %>%
    mutate(
      row_numbers =
        switch(nrow(.) == 0,
          integer(0)
        ) %||%
          .rows_expr_to_row_numbers(
            x$table_body, .data$rows,
            return_when_null = seq_len(nrow(x$table_body))
          ) %>%
          list(),
    ) %>%
    select(-.data$rows, rows = .data$row_numbers)

  x
}

.clean_table_styling_footnote <- function(x, footnote_type) {
  df_clean <-
    x$table_styling[[footnote_type]] %>%
    filter(.data$column %in% .cols_to_show(x))
  if (nrow(df_clean) == 0) {
    return(tibble(
      column = character(0), tab_location = character(0), row_numbers = logical(0),
      text_interpret = character(0), footnote = character(0)
    ))
  }

  df_clean <-
    df_clean %>%
    rowwise() %>%
    mutate(
      row_numbers =
        switch(nrow(.) == 0,
          integer(0)
        ) %||%
          .rows_expr_to_row_numbers(x$table_body, .data$rows) %>% list(),
      tab_location = ifelse(identical(.data$row_numbers, NA), "header", "body")
    ) %>%
    select(-.data$rows) %>%
    unnest(cols = .data$row_numbers) %>%
    group_by(.data$column, .data$tab_location, .data$row_numbers) %>%
    filter(row_number() == n()) %>%
    # keeping the most recent addition
    filter(!is.na(.data$footnote)) # keep non-missing additions

  if (footnote_type == "footnote_abbrev") {
    # order the footnotes by where they first appear in the table,
    df_clean <-
      df_clean %>%
      inner_join(
        x$table_styling$header %>%
          select(.data$column) %>%
          mutate(column_id = row_number()),
        by = "column"
      ) %>%
      arrange(desc(.data$tab_location), .data$column_id, .data$row_numbers) %>%
      ungroup() %>%
      mutate(footnote = paste(unique(.data$footnote), collapse = ", "))
  }

  df_clean %>%
    select(all_of(c("column", "tab_location", "row_numbers", "text_interpret", "footnote")))
}

# this function orders the footnotes by where they first appear in the table,
# and assigns them an sequential ID
.number_footnotes <- function(x) {
  if (nrow(x$table_styling$footnote) == 0 &&
    nrow(x$table_styling$footnote_abbrev) == 0) {
    return(tibble(
      footnote_id = integer(), footnote = character(), column = character(),
      tab_location = character(), row_numbers = integer()
    ))
  }
  bind_rows(
    x$table_styling$footnote,
    x$table_styling$footnote_abbrev
  ) %>%
    inner_join(
      x$table_styling$header %>%
        select(.data$column) %>%
        mutate(column_id = row_number()),
      by = "column"
    ) %>%
    arrange(desc(.data$tab_location), .data$column_id, .data$row_numbers) %>%
    group_by(.data$footnote) %>%
    nest() %>%
    ungroup() %>%
    mutate(footnote_id = row_number()) %>%
    unnest(cols = .data$data) %>%
    select(
      .data$footnote_id, .data$footnote, .data$column,
      .data$tab_location, .data$row_numbers
    )
}

.table_styling_cols_merge <- function(x) {
  if (nrow(x$table_styling$cols_merge) == 0) {
    return(x)
  }
  x_cleaned <- .clean_table_styling(x)
  if (nrow(x_cleaned$table_styling$cols_merge) == 0) {
    return(x)
  }

  # replacing numeric columns with formatted/character,merged columns
  merging_columns <- x_cleaned$table_styling$cols_merge$column
  df_merged <- as_tibble(x, include = c("tibble", "fmt", "cols_merge"))
  x$table_body[merging_columns] <- df_merged[merging_columns]

  # removing merging instructions ----------------------------------------------
  x$table_styling$cols_merge <-
    x$table_styling$cols_merge %>%
    filter(FALSE)

  # replacing formatting functions for merged columns --------------------------
  x <- modify_fmt_fun(x, update = inject(!!merging_columns ~ as.character))

  # return merged gtsummary table ----------------------------------------------
  x
}
