% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/modify_table1.R
\name{px_creation_date}
\alias{px_creation_date}
\alias{px_creation_date.px}
\title{CREATION-DATE}
\usage{
px_creation_date(x, value, validate)

\method{px_creation_date}{px}(x, value, validate = TRUE)
}
\arguments{
\item{x}{A px object}

\item{value}{Optional. A character string. If missing, the current CREATION-DATE is returned. If NULL, CREATION-DATE is removed.}

\item{validate}{Optional. If TRUE a number of validation checks are performed on the px object, and an error is thrown if the object is not valid. If FALSE, the checks are skipped, which can be usefull for large px objects where the check can be time consuming. Use \code{\link[=px_validate]{px_validate()}} to manually preform the check.}
}
\value{
A px object or a character string.
}
\description{
Inspect or change CREATION-DATE.
}
\examples{
# Set CREATION-DATE
x1 <-
   px(population_gl) |>
   px_creation_date('19960612 14:20')

# Print CREATION-DATE
px_creation_date(x1)

# Remove CREATION-DATE
x2 <- px_creation_date(x1, NULL)
px_creation_date(x2)
}
\seealso{
\href{https://www.scb.se/globalassets/vara-tjanster/px-programmen/px-file_format_specification_2013.pdf#\%5B\%7B\%22num\%22\%3A42\%2C\%22gen\%22\%3A0\%7D\%2C\%7B\%22name\%22\%3A\%22XYZ\%22\%7D\%2C184\%2C176\%2C0\%5D}{Statistics Sweden's documentation}
}
