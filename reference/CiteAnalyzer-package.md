# CiteAnalyzer: Citation Analysis from Google Scholar

Toolkit for analyzing citation data from Google Scholar. Provides data
extraction with rate limiting, citation metrics, collaboration network
analysis, and publication impact visualization. Addresses common
challenges including Google Scholar blocking, data reproducibility, and
multi-scholar comparison.

## Key Features

- **Google Scholar Blocking Prevention**: Built-in rate limiting,
  automatic retries, and user-agent rotation

- **Comprehensive Metrics**: Standard metrics (h-index, i10-index,
  m-index) plus advanced field-weighted impact scores

- **Collaboration Networks**: Co-citation network analysis and research
  community detection

- **Temporal Analysis**: Publication and citation trends over time with
  smoothing algorithms

- **Multi-Scholar Comparison**: Normalized ranking system for fair
  comparison across disciplines

- **Publication-Quality Visualizations**: Interactive plots ready for
  manuscripts and presentations

- **Bioconductor Integration**: S4 classes, parallel processing support,
  and reproducible workflows

## Main Functions

- [`ExtractScholarData`](https://danymukesha.github.io/CiteAnalyzer/reference/ExtractScholarData.md):

  Extract comprehensive data from Google Scholar profiles with rate
  limiting

- [`ScholarProfile`](https://danymukesha.github.io/CiteAnalyzer/reference/ScholarProfile.md):

  Create complete scholar profiles with all analyses in one call

- [`CompareScholars`](https://danymukesha.github.io/CiteAnalyzer/reference/CompareScholars.md):

  Compare multiple scholars using normalized metrics and composite
  scoring

- [`AnalyzeCitationTrends`](https://danymukesha.github.io/CiteAnalyzer/reference/AnalyzeCitationTrends.md):

  Analyze publication and citation patterns over time

- [`FindCollaborators`](https://danymukesha.github.io/CiteAnalyzer/reference/FindCollaborators.md):

  Identify potential research collaborators based on similarity metrics

- [`CreateCitationNetwork`](https://danymukesha.github.io/CiteAnalyzer/reference/CreateCitationNetwork.md):

  Generate co-citation networks from publication data

- [`PlotCitationImpact`](https://danymukesha.github.io/CiteAnalyzer/reference/PlotCitationImpact.md):

  Create publication-quality visualizations of citation metrics

- [`PlotCollaborationNetwork`](https://danymukesha.github.io/CiteAnalyzer/reference/PlotCollaborationNetwork.md):

  Visualize research collaboration networks with customizable layouts

- [`PlotPublicationTrends`](https://danymukesha.github.io/CiteAnalyzer/reference/PlotPublicationTrends.md):

  Plot publication and citation trends with smoothing

## S4 Classes

- [`ScholarProfile-class`](https://danymukesha.github.io/CiteAnalyzer/reference/ScholarProfile-class.md):

  S4 class for storing individual scholar data and publications

- [`ScholarData-class`](https://danymukesha.github.io/CiteAnalyzer/reference/ScholarData-class.md):

  S4 class for storing comprehensive analysis results including networks
  and trends

## Vignettes

Get started with the package using the included vignettes:

- `vignette("CiteAnalyzer-vignette")` - Comprehensive tutorial covering
  all major functionality

## Best Practices

- Always respect Google Scholar's terms of service and implement
  additional rate limiting

- Use caching to avoid repeated requests for the same data

- Handle errors gracefully using try-catch blocks

- Consider field-normalized metrics when comparing scholars from
  different disciplines

## Note

This package is designed for research purposes only. Users must comply
with Google Scholar's terms of service and implement appropriate rate
limiting to avoid service disruption. The package includes built-in
protections but users should add additional delays between requests when
analyzing multiple scholars.

## References

- Hirsch, J. E. (2005). An index to quantify an individual's scientific
  research output. Proceedings of the National Academy of Sciences,
  102(46), 16569-16572.

- Bornmann, L., & Daniel, H. D. (2005). Does the h-index for ranking of
  scientists really work? Scientometrics, 65(3), 391-392.

- Waltman, L., & van Eck, N. J. (2012). The inconsistency of the
  h-index. Journal of the American Society for Information Science and
  Technology, 63(2), 406-415.

## See also

Useful links:

- <https://github.com/danymukesha/CiteAnalyzer>

- <https://danymukesha.github.io/CiteAnalyzer>

- Report bugs at <https://github.com/danymukesha/CiteAnalyzer/issues>

## Author

**Maintainer**: Dany Mukesha <danymukesha@gmail.com>
([ORCID](https://orcid.org/0009-0001-9514-751X))
