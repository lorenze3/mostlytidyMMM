% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/step_saturation.R
\name{saturation_speed}
\alias{saturation_speed}
\title{dial (ie from the tune package) for saturation_speed}
\usage{
saturation_speed(range = c(1e-04, 0.009))
}
\arguments{
\item{range}{defaults to c(.0001,.009), should be a length 2 numeric vector that has the minimum and maximum possible saturation speed. Small changes in this value have large impact of rate of saturation.}
}
\value{
a quant param dial
}
\description{
dial (ie from the tune package) for saturation_speed
}
