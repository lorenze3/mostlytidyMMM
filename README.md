
<!-- README.md is generated from README.Rmd. Please edit that file -->

# mostlytidyMMM

<span style="color: red;"> **This is a pre-alpha release package! Assume
none of it works correctly!** </span>

<!-- badges: start -->

[![Codecov test
coverage](https://codecov.io/gh/lorenze3/mostlytidyMMM/branch/main/graph/badge.svg)](https://app.codecov.io/gh/lorenze3/mostlytidyMMM?branch=main)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

## Intent

mostlytidyMMM is a toolkit for building a marketing mix model.

Similar to Meta’s [Robyn](https://facebookexperimental.github.io/Robyn/)
and Google’s [lightweightMMM](https://github.com/google/lightweight_mmm)
in that it offers basic MMM capability without an analyst needing to
choose write their own functions. In terms of philosophy of MMM, this
package is somewhere between Robyn and lightweightMMM – it uses
pre-modelling transformations for time delayed effects (i.e. adstocking)
and saturation transformations like Robyn, but the final coefficients
are estimated via MCMC in Stan to take advantage of constrained, prior
informed regression models.

[tidymodels](https://github.com/tidymodels/tidymodels) provides the
hyperparameter tuning and McElreath’s
[rethinking](https://github.com/rmcelreath/rethinking) builds a link to
Stan.. To take those two foundations and build an MMM package,
mostlytidyMMM has recipe steps for adstock and saturation, functions to
build workflowsets out of multiple formulas, a translator from a string
formula to rethinking::ulam() input, and a custom decomposition formula.

Unlike either of those packages, mostlytidyMMM allows for complete
control on the part of the analyst to choose the level of data
granularity and model form (*welp*, currently only allows normal
regression, but it is a hierarchical bayesian regression and the
specification of that is entirely up to the analyst).

In general, mostlytidyMMM allows an analyst with a table ready for MMM
to specify a reasonable set of models and priors in an .xlsx
configuration file and quickly hone in on a ‘final’ model specification.

## On the Roadmap

I think the following features are in rough priority order:

- visualizing response functions
- poisson and log-normal regression
- a budget optimizer

## Thank thinkr for FUSEN!

This package is a package, and not a bunch of functions, thanks to
thinkr’s [fusen](https://thinkr-open.github.io/fusen/). I highly
recommend it.

## Installation

After installing [cmdstanr](https://mc-stan.org/cmdstanr/) and
[rethinking](https://github.com/rmcelreath/rethinking), mostlytidyMMM
can be installed directly from [GitHub](https://github.com/) via:

``` r
# install.packages("devtools")
devtools::install_github("lorenze3/mostlytidyMMM")
```

## Documentation

Full documentation website on:
<https://lorenze3.github.io/mostlytidyMMM>

## Straightfoward MMM walkthrough

When no tuning is required, a few function calls translate the .xlsx
file into a fitted model.

First we read in the configuration file:

``` r
suppressMessages(suppressWarnings(library(mostlytidyMMM)))
suppressMessages(suppressWarnings( library(tidyverse)))
suppressMessages(suppressWarnings(library(tidymodels)))
suppressMessages(suppressWarnings(library(rethinking)))


control_file<-system.file('no_tuning_example.xlsx',package='mostlytidyMMM')

#get each relevant table of the control file:
var_controls<-readxl::read_xlsx(control_file,'variables')
transform_controls<-readxl::read_xlsx(control_file,'role controls')
workflow_controls<-readxl::read_xlsx(control_file,"workflow") |> select(-desc)
```

The next few lines read in the data and then use the configuration files
to rename, group, and sort the file.

``` r
data1<-read.csv(system.file('example2.csv',package='mostlytidyMMM'))|>rename_columns_per_controls(variable_controls=var_controls)|>
  rename_columns_per_controls()|> mutate(week=as.Date(week,"%m/%d/%Y"))|>
  add_fourier_vars(vc=var_controls) |>  add_groups_and_sort(vc=var_controls) 
```

Now we create a recipe for the pre-processing and a model formula (in
the style of lmer()) based on the data and the 3 config tables

``` r
(no_tuning_recipe<-create_recipe(data1,vc=var_controls,mc=transform_controls,wc=workflow_controls))
#> Warning: Returning more (or less) than 1 row per `summarise()` group was deprecated in
#> dplyr 1.1.0.
#> i Please use `reframe()` instead.
#> i When switching from `summarise()` to `reframe()`, remember that `reframe()`
#>   always returns an ungrouped data frame and adjust accordingly.
#> i The deprecated feature was likely used in the recipes package.
#>   Please report the issue at <]8;;https://github.com/tidymodels/recipes/issueshttps://github.com/tidymodels/recipes/issues]8;;>.
#> This warning is displayed once every 8 hours.
#> Call `lifecycle::last_lifecycle_warnings()` to see where this warning was
#> generated.
#> Recipe
#> 
#> Inputs:
#> 
#>          role #variables
#>         group          2
#>       outcome          1
#>   postprocess          3
#>     predictor         17
#>         price          1
#>  programmatic          2
#>          time         11
#>       time_id          1
#>         trend          1
#>            tv          4
#> 
#> Operations:
#> 
#> Adstock Transformation with retention 0.5 on"TV1"
#> Saturation (asymptote= 250 saturation_speed= 1e-04 Transformation on"TV1"
#> Adstock Transformation with retention 0.5 on"TV2"
#> Saturation (asymptote= 250 saturation_speed= 1e-04 Transformation on"TV2"
#> Adstock Transformation with retention 0.5 on"ProgVideo1"
#> Saturation (asymptote= 200 saturation_speed= 0.0015 Transformation on"ProgVideo1"
#> Variables selected -has_role("postprocess")
#> Novel factor level assignment for all_of(<chr: "product", "store">)
#> Variable mutation for all_of(<chr: "product", "store">)

(formula_in_a_string<-create_formula(base_recipe=no_tuning_recipe,control=workflow_controls))
#> [1] "sales ~ price + TV1 + TV2 + ProgVideo1 + trend + sin1 + cos1 + (1|store) + (TV1|store)"
```

create a rethinking::ulam appropriate flist from the formula and the
config tables (priors from config, e.g.) and also a set of constraint
statements:

``` r
(expressions_for_ulam<-create_ulam_list(prior_controls=var_controls,model_formula=formula_in_a_string,
                 grand_intercept_prior='normal(45,25)') )
#> [[1]]
#> sales ~ normal(big_model, big_sigma)
#> <environment: 0x000000002d2bfcd8>
#> 
#> [[2]]
#> big_model <- big_model_1 + a0 + store_int[store_id] + b_TV1_interact_store[store_id]
#> 
#> [[3]]
#> big_model_1 <- b_price * price + b_TV1 * TV1 + b_TV2 * TV2 + 
#>     b_ProgVideo1 * ProgVideo1 + b_trend * trend + b_sin1 * sin1 + 
#>     b_cos1 * cos1
#> 
#> $b_TV1_interact_store
#> b_TV1_interact_store[store_id] ~ normal(0, slope_sigma)
#> <environment: 0x000000002d803440>
#> 
#> $store
#> store_int[store_id] ~ normal(65, int_sigma)
#> <environment: 0x000000002d7f2f68>
#> 
#> $b_trend
#> b_trend ~ normal(0, 10)
#> <environment: 0x000000002d807d70>
#> 
#> $b_sin1
#> b_sin1 ~ normal(0, 10)
#> <environment: 0x000000002d807d70>
#> 
#> $b_cos1
#> b_cos1 ~ normal(0, 10)
#> <environment: 0x000000002d807d70>
#> 
#> $b_price
#> b_price ~ normal(-20, 10)
#> <environment: 0x000000002d670630>
#> 
#> $b_TV1
#> b_TV1 ~ normal(6, 10)
#> <environment: 0x000000002d67b788>
#> 
#> $b_TV2
#> b_TV2 ~ normal(6, 10)
#> <environment: 0x000000002d6812e8>
#> 
#> $b_ProgVideo1
#> b_ProgVideo1 ~ normal(2, 10)
#> <environment: 0x000000002d682ef8>
#> 
#> [[13]]
#> a0 ~ normal(45, 25)
#> <environment: 0x000000002d2bfcd8>
#> 
#> [[14]]
#> big_sigma ~ half_cauchy(0, 100)
#> <environment: 0x000000002d2bfcd8>
#> 
#> [[15]]
#> int_sigma ~ half_cauchy(0, 10)
#> <environment: 0x000000002d2bfcd8>
#> 
#> [[16]]
#> slope_sigma ~ half_cauchy(0, 10)
#> <environment: 0x000000002d2bfcd8>


(bounds_for_ulam<-make_bound_statements(variable_controls=var_controls))
#> $b_price
#> [1] "upper=0"
#> 
#> $b_TV1
#> [1] "lower=0"
#> 
#> $b_TV2
#> [1] "lower=0"
#> 
#> $b_ProgVideo1
#> [1] "lower=0"
```

Bake data (ie, apply the transformations) and call rethinking::ulam to
fit the bayesian regression (in this case with random slopes and
intercepts). **NB:**In actual use, much higher iteration numbers are
preferred.

``` r
model_data<-no_tuning_recipe %>% prep() %>% bake(data1)

fitted_model_obj<-ulam(expressions_for_ulam, 
                     model_data,
                     constraints=bounds_for_ulam,
                     chains=2,
                     iter=100,
                     cores=2,
                     file='no_tuning_mod',#have a care to remove this if you want to resample!
                     declare_all_data=F,
                     messages=F
                   )
```

a predict method for ulam objects is included in the mostlytidyMMM
package

``` r
model_data$pred<-predict(fitted_model_obj,model_data)[,1]
```

Some basic charts of fit, as examples:

``` r
this_rsq<-rsq(model_data|>ungroup(),truth=sales,estimate=pred)['.estimate'] %>% unlist()
this_mape<-mape(model_data|>ungroup(),truth=sales,estimate=pred)['.estimate'] %>% unlist()
ggplot(model_data ,aes(x=sales,y=pred,color=store_id))+
  geom_point()+ geom_abline(slope=1,intercept=0)+ggthemes::theme_tufte()+
  ggtitle("Predicted vs Actual",subtitle=paste0('Rsq is ',round(this_rsq,2)))
```

<img src="man/figures/README-example 7-1.png" width="100%" />

``` r
model_preds_long<-model_data %>% pivot_longer(c(pred,sales))

ggplot(model_preds_long,aes(x=week,y=value,color=name))+geom_line()+
  ggtitle("Sales and Predicted Sales by Week",subtitle=paste('MAPE is',round(this_mape)))
```

<img src="man/figures/README-example 8-1.png" width="100%" />

a function for decomposition is included as well:

``` r
decomps<-get_decomps_irregardless(model_data %>% ungroup(),recipe_to_use=no_tuning_recipe,
                         model_obj=fitted_model_obj,
                         )
```

Roll those up to total by week and plot them:

``` r
decomps_natl<-decomps %>% select(week,all_of(!!get_predictors_vector(no_tuning_recipe))) %>% group_by(week) %>% summarise(across(where(is.numeric),sum))

decomps_natl<-decomps_natl %>% pivot_longer(cols=c(-week))

ggplot(data=decomps_natl,aes(x=week,y=value,fill=name)) + geom_area()+ggthemes::theme_tufte()+
  ggtitle("Decomposition By Week")+
  theme(legend.position = 'bottom')
```

<img src="man/figures/README-example 10-1.png" width="100%" />
