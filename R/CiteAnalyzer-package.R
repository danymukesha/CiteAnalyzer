#' @keywords internal
"_PACKAGE"

#' CiteAnalyzer: Citation Analysis from Google Scholar
#'
#' @section Key Features:
#' \itemize{
#'   \item \strong{Google Scholar Blocking Prevention}: Built-in rate limiting, automatic retries, and user-agent rotation
#'   \item \strong{Comprehensive Metrics}: Standard metrics (h-index, i10-index, m-index) plus advanced field-weighted impact scores
#'   \item \strong{Collaboration Networks}: Co-citation network analysis and research community detection
#'   \item \strong{Temporal Analysis}: Publication and citation trends over time with smoothing algorithms
#'   \item \strong{Multi-Scholar Comparison}: Normalized ranking system for fair comparison across disciplines
#'   \item \strong{Publication-Quality Visualizations}: Interactive plots ready for manuscripts and presentations
#'   \item \strong{Bioconductor Integration}: S4 classes, parallel processing support, and reproducible workflows
#' }
#'
#' @section Main Functions:
#' \describe{
#'   \item{\code{\link{ExtractScholarData}}}{Extract comprehensive data from Google Scholar profiles with rate limiting}
#'   \item{\code{\link{ScholarProfile}}}{Create complete scholar profiles with all analyses in one call}
#'   \item{\code{\link{CompareScholars}}}{Compare multiple scholars using normalized metrics and composite scoring}
#'   \item{\code{\link{AnalyzeCitationTrends}}}{Analyze publication and citation patterns over time}
#'   \item{\code{\link{FindCollaborators}}}{Identify potential research collaborators based on similarity metrics}
#'   \item{\code{\link{CreateCitationNetwork}}}{Generate co-citation networks from publication data}
#'   \item{\code{\link{PlotCitationImpact}}}{Create publication-quality visualizations of citation metrics}
#'   \item{\code{\link{PlotCollaborationNetwork}}}{Visualize research collaboration networks with customizable layouts}
#'   \item{\code{\link{PlotPublicationTrends}}}{Plot publication and citation trends with smoothing}
#' }
#'
#' @section S4 Classes:
#' \describe{
#'   \item{\code{\link{ScholarProfile-class}}}{S4 class for storing individual scholar data and publications}
#'   \item{\code{\link{ScholarData-class}}}{S4 class for storing comprehensive analysis results including networks and trends}
#' }
#'
#' @section Vignettes:
#' Get started with the package using the included vignettes:
#' \itemize{
#'   \item \code{vignette("CiteAnalyzer-vignette")} - Comprehensive tutorial covering all major functionality
#' }
#'
#' @section Best Practices:
#' \itemize{
#'   \item Always respect Google Scholar's terms of service and implement additional rate limiting
#'   \item Use caching to avoid repeated requests for the same data
#'   \item Handle errors gracefully using try-catch blocks
#'   \item Consider field-normalized metrics when comparing scholars from different disciplines
#' }
#'
#' @section Note:
#' This package is designed for research purposes only. Users must comply with Google Scholar's
#' terms of service and implement appropriate rate limiting to avoid service disruption. The package
#' includes built-in protections but users should add additional delays between requests when analyzing
#' multiple scholars.
#'
#' @author
#' \strong{Maintainer}: Dany Mukesha \email{danymukeshea@gmail.com}
#'
#' \strong{Authors}:
#' \describe{
#'   \item{Dany Mukesha}{Package creator and maintainer}
#' }
#'
#' @references
#' \itemize{
#'   \item Hirsch, J. E. (2005). An index to quantify an individual's scientific research output. Proceedings of the National Academy of Sciences, 102(46), 16569-16572.
#'   \item Bornmann, L., & Daniel, H. D. (2005). Does the h-index for ranking of scientists really work? Scientometrics, 65(3), 391-392.
#'   \item Waltman, L., & van Eck, N. J. (2012). The inconsistency of the h-index. Journal of the American Society for Information Science and Technology, 63(2), 406-415.
#' }
#'
#' @keywords package citation analysis google scholar bibliometrics
#' @name CiteAnalyzer-package
#' @aliases CiteAnalyzer
#' @useDynLib CiteAnalyzer
NULL
