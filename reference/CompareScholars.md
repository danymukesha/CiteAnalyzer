# Compare Scholars

Compare multiple scholars based on various metrics

## Usage

``` r
CompareScholars(
  scholar_profiles,
  metrics = c("h_index", "i10_index", "citations_total", "publications_count")
)
```

## Arguments

- scholar_profiles:

  list of ScholarProfile objects

- metrics:

  Character vector of metrics to compare

## Value

data.frame with comparison results
