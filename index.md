# CiteAnalyzer 📦

Toolkit for analyzing citation data from Google Scholar. Provides data
extraction with rate limiting, citation metrics, collaboration network
analysis, and publication impact visualization. Addresses common
challenges including Google Scholar blocking, data reproducibility, and
multi-scholar comparison.

## Table of Contents

- [Key Features](#key-features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Analysis](#analysis)
- [Documentation](#documentation)

## Key Features

### Google Scholar Blocking Prevention

- Built-in rate limiting with adaptive delays
- Automatic retry mechanisms with exponential backoff
- User-agent rotation to prevent IP blocking
- Request timeout handling with graceful recovery

### Metric Calculation

- Standard metrics: h-index, i10-index, m-index
- Advanced metrics: field-weighted citation impact, citations per paper
- Temporal analysis: 5-year and 10-year trend comparisons
- Journal impact factor estimation from citation patterns

### Collaboration Network Analysis

- Co-citation network generation from publication data
- Research community detection using clustering algorithms
- Interactive network visualization with customizable layouts
- Potential collaborator identification based on research interests

### Publication Impact Visualization

- Publication and citation timeline analysis
- Multi-scholar comparison with normalized ranking
- Interactive plots for exploring citation patterns
- Publication-quality visualizations ready for manuscripts

### Reproducible Research Workflows

- S4 class system for structured data storage
- Complete analysis pipelines with single function calls
- Data caching and export capabilities
- Integration with Bioconductor parallel processing

## Installation

### From GitHub (development version)

``` r
if (!require("remotes", quietly = TRUE))
    install.packages("remotes")

remotes::install_github("danymukesha/CiteAnalyzer")
```

### From Source

``` bash
# Clone repository
git clone https://github.com/danymukesha/CiteAnalyzer.git
cd CiteAnalyzer

# Build and install
R CMD build .
R CMD INSTALL CiteAnalyzer_1.0.0.tar.gz
```

## Quick Start

### Basic Scholar Profile Analysis

``` r
library(CiteAnalyzer)

# Extract data for a scholar (using example ID - replace with actual ID)
# Example ID: "qc6CJjYAAAAJ" - replace with your target scholar's ID
scholar_data <- ExtractScholarData("qc6CJjYAAAAJ", max_publications = 20)

# View basic information about the scholar
cat("Name:", scholar_data@name, "\n")
cat("Affiliation:", scholar_data@affiliation, "\n")
cat("Research Interests:", scholar_data@interests, "\n")
cat("Total Publications:", nrow(scholar_data@publications), "\n")
cat("Total Citations:", scholar_data@citations_total, "\n")
cat("h-index:", scholar_data@h_index, "\n")
cat("i10-index:", scholar_data@i10_index, "\n")

# Plot top publications by citations
PlotCitationImpact(scholar_data@, plot_type = "summary")

# Plot publication and citation trends over time
PlotCitationImpact(scholar_data@profiles, plot_type = "timeline")
```

### Multi-Scholar Comparison

``` r
# Extract data for multiple scholars
scholar1 <- ExtractScholarData("qc6CJjYAAAAJ", max_publications = 30)
scholar2 <- ExtractScholarData("M4SrmDIAAAAJ", max_publications = 30) 
scholar3 <- ExtractScholarData("9cHj9xMAAAAJ", max_publications = 30)

# Compare scholars comprehensively
comparison_results <- CompareScholars(list(scholar1, scholar2, scholar3))

# View comparison table
print(comparison_results)

# Create visualization comparing all three scholars
PlotCitationImpact(scholar1, plot_type = "comparison", 
                  compare_with = list(scholar2, scholar3))
```

### Finding Potential Collaborators

``` r
# Identify potential collaborators based on research similarity
collaborators <- FindCollaborators(
    target_scholar = scholar1,
    candidate_scholars = list(scholar2, scholar3),
    min_similarity = 0.25
)

# View ranked list of potential collaborators
print(collaborators)

# Focus on top collaborator
if (nrow(collaborators) > 0) {
    top_collaborator <- collaborators$candidate_name[1]
    cat(sprintf("Top potential collaborator: %s\n", top_collaborator))
}
```

## Analysis

### Citation Trend Analysis

``` r
# Analyze citation trends over different time periods
trends_5y <- AnalyzeCitationTrends(
    list(scholar1, scholar2, scholar3),
    time_period = "5y"
)

# Plot publication and citation trends
PlotPublicationTrends(
    list(scholar1, scholar2, scholar3),
    trend_type = "both",
    smoothing_span = 0.4
)
```

### Collaboration Network Visualization

``` r
# Create and visualize collaboration network
network <- CreateCitationNetwork(
    list(scholar1, scholar2, scholar3),
    min_citations = 5
)

# Plot the network with Fruchterman-Reingold layout
if (igraph::gsize(network) > 0) {
    PlotCollaborationNetwork(
        network,
        layout_type = "fr",
        highlight_scholar = scholar1@scholar_id
    )
}
```

### Journal Impact Analysis

``` r
# Estimate journal impact factors from publication data
journal_impact <- estimate_impact_factor(
    scholar1@publications,
    year_range = 5
)

# View top journals by estimated impact factor
print(journal_impact)
```

## Documentation

### Vignettes

The package includes comprehensive vignettes demonstrating advanced
usage:

``` r
# View available vignettes
browseVignettes("CiteAnalyzer")

# Access main vignette
vignette("CiteAnalyzer-vignette", package = "CiteAnalyzer")
```

### Function Documentation

``` r
# View help for specific functions
?ExtractScholarData
?CompareScholars
?PlotCollaborationNetwork
?ScholarProfile

# List all exported functions
ls("package:CiteAnalyzer")
```

### Classes and Methods

``` r
# View S4 class definitions
showClass("ScholarProfile")
showClass("ScholarData")

# View available methods
showMethods("calculateMetrics")
showMethods("plot")
```
