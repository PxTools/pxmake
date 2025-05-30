test_that("Error data is specified when input is not .xlsx", {
  expect_data_input_error <- function(input, data) {
    expect_error(px(input = input, data = data),
                 regexp = "'data' can only be used if 'input' is an .xlsx file"
    )
  }

  expect_data_input_error(input = data.frame(),
                          data = data.frame()
  )

  expect_data_input_error(input = get_px_file_path("TUX01"),
                          data = data.frame()
  )
})

test_that("Error if data is not NULL, a data frame, .rds or .parquet file", {
  expect_data_error <- function(data) {
    expect_error(px(input = get_metadata_path("FOTEST"), data = data),
                 regexp = "'data' has wrong format"
    )
  }

  expect_data_error(data = base::matrix())
  expect_data_error(data = list())
  expect_data_error(data = get_metadata_path("BEXSTA"))
})

test_that("Error if multiple time vars in variable", {
  expect_error(px(input = get_metadata_path("error_two_timevals")),
               regexp = "time"
               )
})

test_that("Error if timeval is not stub or heading", {
  expect_error(px(population_gl) %>% px_timeval("n"),
               regexp = "TIMEVAL has to be a STUB or")
})

test_that("Error if contvariable is not stub or heading", {
  expect_error(px(population_gl) %>% px_contvariable("n"),
               regexp = "CONTVARIABLE has to be a STUB or")
})

test_that("Error wrong input", {
  expect_input_error <- function(input, data = NULL) {
    expect_error(px(input = input, data = data),
                 regexp = "'input' has wrong format"
                 )
  }

  expect_input_error(input = list())
})

test_that("Error if any value contains quotation marks", {
  x <- px(input = population_gl)

  expect_quotation_error <- function(input) {
    expect_error(input,
                 regexp = "quotation marks"
                 )
  }

  expect_quotation_error(x %>% px_language(value = 'd"a'))
  expect_quotation_error(x %>% px_matrix(value = 'quotation"marks"'))
  expect_quotation_error(x %>% px_contents(value = 'val " with quo'))
  expect_quotation_error(x %>% px_note(value = 'val " with quo'))
  expect_quotation_error(x %>% px_valuenote(value = data.frame(valuenote ='"')))
  expect_quotation_error(x %>% px_cellnote(value = data.frame(cellnote ='"')))
})

# px_micro()

test_that("px_micro arguments are validated", {
  expect_error(px_micro(x = data.frame()),
               regexp = "px object"
               )

  expect_error(px_micro(x = px(women), out_dir = 5),
               regexp = "character"
               )

  expect_error(px_micro(x = px(women), out_dir = "not/a/directory"),
               regexp = "directory does not exist"
               )
})

test_that("px with duplicates in data table cannot be saved", {
  duplicated_df <-
    dplyr::bind_rows(population_gl, population_gl)

  # px object can be created with duplicated data, which is necessary when
  # micro data is created
  x <- px(input = duplicated_df)

  # However, an error is raised when saving, becuase it will created lists
  # in figures.
  expect_error(x %>%
                 px_save(temp_px_file()),
               regexp = "contains duplicates"
               )

  expect_error(x %>%
                 px_save(temp_xlsx_file()),
               regexp = "contains duplicates"
               )
})
