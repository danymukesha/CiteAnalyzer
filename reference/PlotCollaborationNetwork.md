# Plot Collaboration Network

Visualize collaboration network between scholars

## Usage

``` r
PlotCollaborationNetwork(network, layout_type = "fr", highlight_scholar = NULL)
```

## Arguments

- network:

  igraph object representing collaboration network

- layout_type:

  Character string specifying layout algorithm ("fr", "kk", "lgl")

- highlight_scholar:

  Character string scholar ID to highlight (optional)

## Value

ggplot object
