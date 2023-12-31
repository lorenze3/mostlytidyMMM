% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/make_bound_statements.R
\name{get_decomps_irregardless}
\alias{get_decomps_irregardless}
\title{get decomps agnostic to multiplicative or additive model specification}
\usage{
get_decomps_irregardless(
  data_to_use = data3,
  recipe_to_use = recipe_finalized,
  model_obj = rethinking_results,
  predictors = get_predictors_vector(recipe_to_use),
  sample_size = 1000
)
}
\arguments{
\item{data_to_use}{defaults to data 3; a transformed dataset (likely produced via bake())}

\item{recipe_to_use}{defaults to recipe3; a recipe which has the roles assigned for the MMM}

\item{model_obj}{defaults to rethinking_results; an ulam fit object}

\item{predictors}{defaulst to get_predictors(recipe3)}

\item{sample_size}{seems to be useless input to link() function}
}
\value{
a tibble with one row per row in data_to_use, incluiding id columns as pulled from
the recipe_to_use (ie where role == group or role==time_id), and the one column
per predictor variable that shows the amount of the outcome variable due to that predictor.

Additionally, the columns decomp_base, decomp0_tot, pred, and decomp_ratio are appended.

decomp_base is the amount of the outcome variable due to intercept(s) and other no response
function needed variables.  decomp0_tot is the sum of the predictor var decomp columns prior
to rescaling.  decomp_ratio is the ratio of pred (the full predicted outcome) to decomp0_tot.
This has been applied as scaling factor -- it will generally be different from 1 for multiplicative models
and be 1 for additive models.
}
\description{
get decomps agnostic to multiplicative or additive model specification
}
\details{
The decomp algorithm works by first setting all predictors that are not _id variables (as found
by get_predictors_vector() to zero and calling link() to determine the prediction for this scenario.

That prediction becomes the initial decomp_base.

Then each predictor is set back to historical values one at a time, and the initial decomp for that
variable is set to the difference in prediction with that predictor 'on' and the decomp_base.

Finally, the sum of all the initial decomps is taken, and the ratio between the pred and the sum of decomps
is used to scale all decomps (so the sum is equal to prediction).

For additive models, this is equivalent to decomp = model_coef * modeled_independent_variable; for
multiplicative models this is equivalent to thinking of decomps as lift over base, with an adjustment to make it
additive.
}
