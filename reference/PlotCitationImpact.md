# Plot Citation Impact

Create comprehensive visualization of citation impact metrics

## Usage

``` r
PlotCitationImpact(
  scholar_profile,
  plot_type = "summary",
  compare_with = NULL,
  radar_coord = c("radar", "polar")
)
```

## Arguments

- scholar_profile:

  ScholarProfile object

- plot_type:

  Character string specifying plot type ("summary", "timeline",
  "comparison")

- compare_with:

  list of additional ScholarProfile objects for comparison (optional)

- radar_coord:

  Character string: "radar" (default) or "polar" for radar plot style

## Value

ggplot object
