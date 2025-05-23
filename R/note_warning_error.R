# Helper functions for throwing errors, warnings and notes.

#' Throw error
#'
#' @param msg String, error message
#'
#' @returns Nothing
#' @keywords internal
error <- function(msg) {
  stop(msg, call. = FALSE)
}

error_if_excel_sheet_does_not_exist <- function(sheet_name, excel_path) {
  if (! excel_sheet_exists(sheet_name, excel_path)) {
    error(stringr::str_glue("The sheet '{sheet_name}' is missing in: {excel_path}."))
  }
}

error_if_more_than_one_time_variable <- function(time_variable) {
  if (length(time_variable) > 1) {
    error(stringr::str_glue("The metadata has more than one variable where ",
                            "`timeval=TRUE`. Change the type of the variables ",
                            "{time_variable}, so only one has `timeval=TRUE`."
                            )
          )
  }
}

error_if_not_exactly_one_figures_variable <- function(figures_var) {
  if (length(figures_var) == 0) {
    error(stringr::str_glue("There is no figures variable. Change the metadata ",
                            "so one variable has `pivot=FIGURES`."
                            )
         )
  } else if (length(figures_var) > 1) {
    error(stringr::str_glue("There are more than one variable with figures. ",
                            "Change the type of the variables {figures_var}, so ",
                            "only one has `pivot=FIGURES`."
                            )
         )
  }
}

error_if_not_exactly_one_data_line <- function(data_line_index) {
  if(length(data_line_index) != 1) {
    error(stringr::str_glue("There are {length(data_line_index)} lines in the ",
                            "PX-file like this: 'DATA='. There needs to be ",
                            "exactly 1."
                            )
         )
  }
}

excel_max_lines <- function() {
  1048576
}

error_if_too_many_rows_for_excel <- function(df) {
  data_lines <- nrow(df)
  excel_max_lines <- excel_max_lines()

  if(data_lines > excel_max_lines) {
   error(stringr::str_glue("The data cube contains {data_lines} data lines ",
                           "which is more than the {excel_max_lines} lines ",
                           "supported by Excel. Use argument `rds_data_path=` ",
                           "to store the data in an .rds file instead."
                           )
        )
  }
}

unexpected_error <- function() {
  error(paste("An unexpected error occurred. Please report the issue on GitHub,",
              "ideally with a minimal reproducible example.",
              "https://github.com/StatisticsGreenland/pxmake/issues "
              )
       )
}

#' A list of which variables should be in each sheet
#' @keywords internal
get_mandatory_variables <- function() {
  list("Table"     = c("keyword", "value"),
       "Table2"    = c("keyword", "code"),
       "Variables" = c("pivot", "order", "variable-code", "variable-label", "variable-type"),
       "Cells"     = c("variable-code", "sortorder", "code", "code-label", "precision")
  )
}

error_if_mandatory_keyword <- function(x, keyword) {
  if (keyword %in% mandatory_keywords()) {
    error(stringr::str_glue("Keyword '{keyword}' is mandatory and cannot be removed."))
  } else if (keyword %in% "TITLE") {
    if (is.null(px_description(x))) {
      error("Keyword TITLE cannot be removed unless DESCRIPTION is defined.")
    }
  } else if (keyword %in% "DESCRIPTION") {
    if (is.null(px_title(x))) {
      error("Keyword DESCRIPTION cannot be removed unless TITLE is defined.")
    }
  }
}

## validate_px checks
error_if_not_list <- function(x) {
  if (! is.list(x)) {
    error("px object must be a list")
  }
}

error_if_not_class_px <- function(x) {
  if (! inherits(x, "px")) {
    error("px object must have class 'px'")
  }
}

error_if_not_list_of_data_frames <- function(x) {
  if (! all(sapply(x, is.data.frame))) {
    error("px object must be a list of data frames")
  }
}

error_if_list_names_are_wrong <- function(x) {
  px_target <- get_base_px()

  input_names  <- names(x)
  target_names <- names(px_target)

  missing_names <- setdiff(target_names, input_names)
  invalid_names <- setdiff(input_names, target_names)

  if (length(missing_names) > 0) {
    error(paste0("px object is missing these names: ",
                 paste0(missing_names, collapse = ", ")
                 )
          )
  }

  if (length(invalid_names) > 0) {
    error(paste0("px object contains these invalid names: ",
                 paste0(invalid_names, collapse = ", ")
                 )
          )
  }
}

error_if_data_frame_is_missing_column <- function(x) {
  px_target <- get_base_px()

  for (name in names(px_target)) {
    target_columns <- colnames(px_target[[name]])
    input_columns  <- colnames(x[[name]])

    missing_columns <- setdiff(target_columns, input_columns)

    if (length(missing_columns) > 0) {
      error(paste0("px object: '", name, "' is missing these columns: ",
                   paste0(missing_columns, collapse = ", ")
                   )
            )
    }
  }
}

error_if_multiple_time_variables <- function(x) {
  if (length(px_timeval(x)) > 1) {
    error(paste0("px object has more than one time variable: ",
                 paste0(px_timeval(x), collapse = ", ")))
  }
}

error_if_timeval_isnot_heading_or_stub <- function(x) {
  if (!is.null(px_timeval(x))) {
    if (! px_timeval(x) %in% c(px_heading(x), px_stub(x))) {
      error("TIMEVAL has to be a STUB or HEADING variable.")
    }
  }
}

error_if_contvariable_isnot_heading_or_stub <- function(x) {
  if (!is.null(px_contvariable(x))) {
    if (! px_contvariable(x) %in% c(px_heading(x), px_stub(x))) {
      error("CONTVARIABLE has to be a STUB or HEADING variable.")
    }
  }
}

error_if_variable_label_is_na <- function(x) {
  if (any(is.na(x$variables2$`variable-label`))) {
    error("px object: in x$variables2 'variable-label' has NA values.")
  }
}

error_if_misplaced_keywords_in_table <- function(x, table_name) {
  if (table_name == "table1") {
    other_keywords <-
      px_keywords %>%
      dplyr::filter(! (.data$table_meta & !.data$language_dependent)) %>%
      dplyr::pull(.data$keyword)
  } else if (table_name == "table2") {
    other_keywords <-
      px_keywords %>%
      dplyr::filter(! (.data$table_meta & .data$language_dependent)) %>%
      dplyr::pull(.data$keyword)
  } else {
    unexpected_error()
  }

  misplaced_keywords <- intersect(x[[table_name]]$keyword, other_keywords)

  if (length(misplaced_keywords) > 0) {
    error(paste0("px object: '", table_name, "' contains misplaced keywords: ",
                 paste0(misplaced_keywords, collapse = ", ")
                 )
          )
  }
}

error_if_variable_code_not_in_data <- function(x, table_name) {
  variables_not_in_data <- setdiff(x[[table_name]]$`variable-code`, names(x$data))

  if (length(variables_not_in_data) > 0) {
    error(paste0("px object: x$", table_name, " contains variable-codes not in x$data: ",
                 paste0(variables_not_in_data, collapse = ", ")
                 )
          )
  }
}

error_if_used_languages_are_not_defined <- function(x) {
  languages_in_tables <-
    unique(c(x$table2$language,
             x$variables2$language,
             x$cells2$language)
           ) %>%
    na.omit() %>%
    as.character()

  undefined_languages <- setdiff(languages_in_tables, defined_languages(x))

  if (length(undefined_languages) > 0) {
    error(paste0("px object contains languages that are not defined in 'x$languages' ",
                 "or as keyword 'LANGUAGES' in x$table1: ",
                 paste0(undefined_languages, collapse = ", "))
          )
  }
}

error_if_language_not_in_languages <- function(x) {
  if (length(px_languages(x)) > 0) {
    if (! any(is.null(px_language(x)), px_language(x) %in% px_languages(x))) {
      error("px object: LANGUAGE is not in x$languages.")
    }
  }
}

error_if_language_is_undefined <- function(language, x) {
  if (! language %in% defined_languages(x)) {
    error(paste0("Language '", language, "' is not defined in the px object."))
  }
}

error_if_data_column_is_not_defined <- function(x, table_name) {
  undefined_variables <- setdiff(colnames(x$data), x[[table_name]]$`variable-code`)

  if (length(undefined_variables) > 0) {
    error(paste0("px object: x$data contains columns that are not defined in x$",
                 table_name, ": ", paste0(undefined_variables, collapse = ", ")
                 )
          )
  }
}

error_if_value_contains_quotation_marks <- function(x) {
  df_contains_quotation_marks <-
    lapply(x, function(df) {
      df %>%
        dplyr::mutate(across(everything(), ~grepl('"', .))) %>%
        unlist() %>%
        any()
    }) %>%
    unlist()

  if (any(df_contains_quotation_marks)) {
    error("px object: values cannot contain quotation marks")
  }
}

error_if_data_table_contains_duplicates <- function(x) {
  duplicates <-
    x %>%
    px_data() %>%
    dplyr::select(-px_figures(x)) %>%
    dplyr::group_by(across(everything())) %>%
    dplyr::filter(dplyr::n() > 1)

  if (nrow(duplicates) > 0) {
    error(paste0("px save: cannot save because data table contains duplicates:\n\n",
                 paste(utils::capture.output(print(duplicates)),
                       collapse = "\n"
                       )
                 )
          )
  }
}

is_url <- function(path) {
  if (!is.character(path) || length(path) != 1) {
    return(FALSE)
  }

  stringr::str_detect(path, "^https?://")
}

#' Check all arguments to px()
#'
#' @inheritParams px
#'
#' @returns Nothing
#' @keywords internal
validate_px_arguments <- function(input, data) {
  if (! any(is_px_file(input), is_xlsx_file(input), is.data.frame(input),
            is_rds_file(input), is_parquet_file(input), is.null(input),
            is_url(input))) {
    error("Argument 'input' has wrong format. See ?px.")
  }

  if (is_rds_file(input)) {
    if (! "data.frame" %in% class(readRDS(input))) {
      error(paste0("Argument 'input' has wrong format. The .rds file does not ",
                   "contain a data frame. See ?px."
                   )
            )
    }
  }

  if (! any(is.null(data), is.data.frame(data), is_rds_file(data), is_parquet_file(data))) {
    error("Argument 'data' has wrong format. See ?px.")
  }

  if (! is.null(data) & ! is_xlsx_file(input)) {
      error("Argument 'data' can only be used if 'input' is an .xlsx file.")
  }
}

#' Check all arguments to px_save()
#'
#' @inheritParams px_save
#'
#' @returns Nothing
#' @keywords internal
validate_px_save_arguments <- function(x, path, save_data, data_path) {
  if (! any(is_px_file(path), is_xlsx_file(path), is_r_file(path))) {
    error("Argument 'path' must be a path to an .px, .xlsx or .R file.")
  }

  if (! is.logical(save_data)) {
    error("Argument 'save_data' must be TRUE or FALSE.")
  }

  if (all(!is.null(data_path), all(!is_rds_file(data_path), !is_parquet_file(data_path)))) {
    error("Argument 'data_path' must be a path to an .rds or .parquet file.")
  }

  if (all(!is.null(data_path), all(!is_xlsx_file(path), !is_r_file(path)))) {
    error("Argument 'data_path' can only be used if 'path' is an .xlsx or .R file.")
  }

  if (all(!is.null(data_path), isFALSE(save_data))) {
    error("Argument 'data_path' can only be used if 'save_data' is TRUE.")
  }

  if (all(isFALSE(save_data), !is_xlsx_file(path))) {
    error("Argument 'save_data' can only be FALSE if 'path' is an .xlsx file.")
  }

  if (all(is_xlsx_file(path),
          save_data,
          is.null(data_path),
          nrow(x$data) > excel_max_lines())
      ) {
    error(paste0("x$data has too many rows to be saved as an .xlsx file. Use ",
                 "'save_data = FALSE' or 'data_path' instead.")
          )
  }

  error_if_data_table_contains_duplicates(x)
}

#' Check all arguments to px_micro()
#'
#' @inheritParams px_micro
#'
#' @returns Nothing
#' @keywords internal
validate_px_micro_arguments <- function(x, out_dir) {
  if (! inherits(x, "px")) {
    error("Argument 'x' must be a px object.")
  }

  if (! is.null(out_dir)) {
    if (! is.character(out_dir)) {
      error("Argument 'out_dir' must be a character string.")
    }

    if (! dir.exists(out_dir)) {
      error("Argument 'out_dir' directory does not exist.")
    }
  }
}

#' Throw error if argument is not a character string
#' @keywords internal
error_if_agument_is_not_character_string <- function(name, value) {
  if (! all(is.character(value), length(value) == 1)) {
    error(paste0("Argument '", name, "' must be a character string."))
  }
}

#' Check all arguments to px_classification
#'
#' @inheritParams px_classification
#'
#' @returns Nothing
#' @keywords internal
validate_px_classification_arguments <- function(name,
                                                 prestext,
                                                 domain,
                                                 df,
                                                 vs_path,
                                                 agg_paths){
  any_path_argument_is_defined <- (!missing(vs_path) | !missing(agg_paths))

  any_non_path_argument_is_defined <-
    (!missing(name) | !missing(prestext) | !missing(domain) | !missing(df))

  if (any_path_argument_is_defined & any_non_path_argument_is_defined) {
    error(paste0("Cannot use path arguments and other aguments together. ",
                 "Either define only name/prestext/domain/df, or only ",
                 "vs_path/agg_paths."
                 )
          )
  }

  if (any_path_argument_is_defined) {
    if (! missing(vs_path)) {
      if (! is.character(vs_path)) {
        error("Argument 'vs_path': must be a character string.")
      }

      if (! file.exists(vs_path)) {
        error("Argument 'vs_path': file does not exist.")
      }
    }

    if (! missing(agg_paths)) {
      if (! is.character(agg_paths)) {
        error("Argument 'agg_paths': must be a character vector.")
      }
    }
  }

  if (all(any_path_argument_is_defined, missing(vs_path))) {
    error(paste0("Argument 'vs_path' is missing. If 'agg_paths' is defined, ",
                 "'vs_path' must also be defined."
                 )
          )
  }

  if (any_non_path_argument_is_defined) {
    error_if_agument_is_not_character_string("name", name)
    error_if_agument_is_not_character_string("prestext", prestext)
    error_if_agument_is_not_character_string("domain", domain)

    if (! is.data.frame(df)) {
      error("Argument 'df' must be a data frame.")
    }

    if (! "valuecode" %in% names(df)) {
      error("Argument 'df' is missing column 'valuecode'.")
    }
  }
}

#' Check all arguments to px_data
#'
#' @inheritParams px_data
#'
#' @returns Nothing
#' @keywords internal
validate_px_data_arguments <- function(x, value, labels, validate) {
  if (! inherits(x, "px")) {
    error("Argument 'x' must be a px object.")
  }

  if (! missing(value)) {
    if (! (is.data.frame(value) | is.null(value))) {
      error("Argument 'value' must be a data frame or NULL.")
    }
  }

  if (! missing(labels)) {
    if (! is.logical(labels) & ! is.character(labels)) {
      error("Argument 'labels' must be TRUE/FALSE or a character string.")
    }
  }

  # labels can only be used if value is missing
  if (! missing(value) & ! isFALSE(labels)) {
    error("Argument 'labels' can only be used if 'value' is missing.")
  }

  if (! missing(validate)) {
    if (! is.logical(validate)) {
      error("Argument 'validate' must be TRUE or FALSE.")
    }
  }
}

error_if_vs_file_is_missing_mandatory_headings <- function(vs_lines) {
  headings <-
    stringr::str_extract_all(vs_lines,
                             classification_file_section_heading_regexp()
                             )

  missing_headings <- setdiff(c("[Descr]", "[Domain]", "[Valuecode]"),
                              headings
                              )

  if (length(missing_headings) > 0) {
    error(paste(".vs file is missing mandatory sections: ",
                paste0(missing_headings, collapse = ", ")
                )
          )
  }
}

error_if_aggregation_file_is_missing_mandatory_headings <- function(agg_lines) {
  headings <-
    stringr::str_extract_all(agg_lines,
                             classification_file_section_heading_regexp()
                             )

  missing_headings <- setdiff(c("[Aggreg]", "[Aggtext]"), headings)

  if (length(missing_headings) > 0) {
    error(paste(".agg file is missing mandatory sections: ",
                paste0(missing_headings, collapse = ", ")
                )
          )
  }
}
