% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/make_bound_statements.R
\name{create_formula}
\alias{create_formula}
\title{Creates a string that represents a model formula from a recipe and the workflow controls data}
\usage{
create_formula(
  base_recipe = recipe3,
  control = workflow_controls,
  ignore_rands = FALSE
)
}
\arguments{
\item{base_recipe}{defaults to recipe3; is the recipe containing variables to build a formula for}

\item{control}{defaults to workflow_controls, should be a tibble with columns R_name and Value, which must have rows with R_name =='Y','list_rand_ints' and 'fft_terms'}

\item{ignore_rands}{defaults to FALSE, but if set to TRUE the created formula
will not contain random intercepts or slopes other than fourier transform
related slopes (if those are specified in the control frame)}
}
\value{
a string that reads like an lmer formula
}
\description{
Creates a string that represents a model formula from a recipe and the workflow controls data
}
