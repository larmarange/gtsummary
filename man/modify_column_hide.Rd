% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/modify_column_hide.R
\name{modify_column_hide}
\alias{modify_column_hide}
\alias{modify_column_unhide}
\title{Modify Hidden Columns}
\usage{
modify_column_hide(x, columns)

modify_column_unhide(x, columns)
}
\arguments{
\item{x}{gtsummary object}

\item{columns}{vector or selector of columns in \code{x$table_body}}
}
\description{
\lifecycle{experimental}
Use these functions to hide or unhide columns in a gtsummary tables.
}
\section{Example Output}{

\if{html}{Example 1}

\if{html}{\figure{modify_column_hide_ex1.png}{options: width=45\%}}
}

\examples{
# Example 1 ----------------------------------
# hide 95\% CI, and replace with standard error
modify_column_hide_ex1 <-
  lm(age ~ marker + grade, trial) \%>\%
  tbl_regression() \%>\%
  modify_column_hide(columns = ci) \%>\%
  modify_column_unhide(columns = std.error)
}
\seealso{
Other Advanced modifiers: 
\code{\link{modify_fmt_fun}()},
\code{\link{modify_table_body}()},
\code{\link{modify_table_styling}()}
}
\concept{Advanced modifiers}
