% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bulk_update_role.R
\name{add_steps_media}
\alias{add_steps_media}
\title{loops over the variable control table to add media transformations based on either variable specific transformations or tunable ranges}
\usage{
add_steps_media(
  this_recipe,
  var_specific_controls = var_controls,
  media_controls = transform_controls
)
}
\arguments{
\item{this_recipe}{a recipe object}

\item{media_controls}{Defaults to transform_controls; a tibble containing groups of variables (ie role2 values) that assignes ranges to asymptote, saturation_speed, and retention IF there are no values for the individual variables}

\item{var_specfic_controls}{Defaults to var_controls; a tibble containing variable name, role, role2, asymptote, saturation_speed, sign , and retention values (or blanks)}
}
\value{
a recipe
}
\description{
loops over the variable control table to add media transformations based on either variable specific transformations or tunable ranges
}
