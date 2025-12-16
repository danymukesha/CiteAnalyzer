# Calculate Citation Metrics

Calculates various citation metrics (e.g., h-index, i10-index, m-index)
for a scholar's profile.

## Usage

``` r
calculateMetrics(object, ...)

# S4 method for class 'ScholarProfile'
calculateMetrics(object, metric = c("h_index", "i10_index", "m_index"))
```

## Arguments

- object:

  An object of class \`ScholarProfile\`.

- ...:

  Additional arguments passed to the generic function (currently
  unused).

- metric:

  A character string specifying the metric to calculate. Options are:
  "h_index", "i10_index", or "m_index".

## Value

A numeric value representing the chosen citation metric.

## Examples

``` r
scholar_profile <- new("ScholarProfile", publications = data.frame(citedby = c(10, 20, 30, 40), year = c(2000, 2005, 2010, 2015)))
calculateMetrics(scholar_profile, metric = "h_index")
#> [1] 4
calculateMetrics(scholar_profile, metric = "i10_index")
#> [1] 4
calculateMetrics(scholar_profile, metric = "m_index")
#> [1] 0.07148457
```
