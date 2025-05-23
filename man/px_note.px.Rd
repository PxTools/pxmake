% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/modify_note.R
\name{px_note}
\alias{px_note}
\alias{px_note.px}
\title{NOTE}
\usage{
px_note(x, value, validate)

\method{px_note}{px}(x, value, validate = TRUE)
}
\arguments{
\item{x}{A px object}

\item{value}{Optional. A character string, a data frame, or a list.
\itemize{
\item Use character, to set NOTE for the entire table across all languages.
\item Use a data frame with columns 'language' and 'value' to set
NOTE for the entire table in a specific language.
\item Use a data frame with the columns 'variable-code' and 'note',
to set NOTE for a specific variable across all languages. Add the
column 'language' to set NOTE for specific language.
\item Use a list of the above elements to set NOTE in muliple ways.
This is the same as calling NOTE multiple times with different values.
\item If missing, the current NOTE is returned.
\item If NULL, NOTE is removed for the table and all variables.
}}

\item{validate}{Optional. If TRUE a number of validation checks are performed on the px object, and an error is thrown if the object is not valid. If FALSE, the checks are skipped, which can be usefull for large px objects where the check can be time consuming. Use \code{\link[=px_validate]{px_validate()}} to manually preform the check.}
}
\value{
A px object, a character string, a data frame, or a list of character strings and/or data frames.
}
\description{
Inspect or change NOTE.
}
\details{
NOTE has a lot of possible ways to specify \code{value}, because
it can be set both for the entire PX-file and for individual variables.
}
\examples{
library(tibble)

# Set NOTE for entire PX-file
x1 <-
  px(population_gl) |>
  px_note('Note about PX-file')

# Print NOTE
px_note(x1)

# Set NOTE for entire PX-file in multiple languages
x2 <-
  x1 |>
  px_languages(c('en', 'kl')) |>
  px_note(tribble(~language,            ~value,
                       'en',    'English note',
                       'kl', 'Kalaallisut note'
                 )
         )
px_note(x2)

# Set NOTE for variables
x3 <-
  x1 |>
  px_note(tribble(~`variable-code`, ~note,
                 'year', 'Some data collected in following year',
                 'age',  'Is rounded down'
                 )
        )
px_note(x3)

# Remove all NOTEs
x4 <- px_note(x3, NULL)
}
\seealso{
\href{https://www.scb.se/globalassets/vara-tjanster/px-programmen/px-file_format_specification_2013.pdf#\%5B\%7B\%22num\%22\%3A50\%2C\%22gen\%22\%3A0\%7D\%2C\%7B\%22name\%22\%3A\%22XYZ\%22\%7D\%2C184\%2C411\%2C0\%5D}{Statistics Sweden's documentation}
}
