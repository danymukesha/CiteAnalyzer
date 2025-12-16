# Plot Publication Trends

Create interactive publication trends visualization

## Usage

``` r
PlotPublicationTrends(scholar_data, trend_type = "both", smoothing_span = 0.3)
```

## Arguments

- scholar_data:

  ScholarData object or list of ScholarProfile objects

- trend_type:

  Character string ("publications", "citations", "both")

- smoothing_span:

  Numeric smoothing parameter for LOESS (0-1)

## Value

ggplot object
