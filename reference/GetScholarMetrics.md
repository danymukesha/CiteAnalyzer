# Get Scholar Metrics

Calculate comprehensive metrics for a scholar profile

## Usage

``` r
GetScholarMetrics(
  scholar_profile,
  metrics = c("h_index", "i10_index", "m_index", "citations_per_paper")
)
```

## Arguments

- scholar_profile:

  ScholarProfile object

- metrics:

  Character vector of metrics to calculate

## Value

list containing calculated metrics
