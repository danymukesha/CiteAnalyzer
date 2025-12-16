#' @name ScholarProfile-class
#' @title ScholarProfile S4 Class
#' @description S4 class for storing Google Scholar profile data
#' @slot scholar_id Character string containing the Google Scholar ID
#' @slot name Character string with scholar's name
#' @slot affiliation Character string with institutional affiliation
#' @slot interests Character vector of research interests
#' @slot homepage Character string with homepage URL
#' @slot citations_total Numeric total citations
#' @slot citations_5y Numeric citations in last 5 years
#' @slot h_index Numeric h-index
#' @slot h_index_5y Numeric h-index for last 5 years
#' @slot i10_index Numeric i10-index
#' @slot i10_index_5y Numeric i10-index for last 5 years
#' @slot publications data.frame containing publication details
#' @import methods
#' @export
setClass("ScholarProfile",
    slots = c(
        scholar_id = "character",
        name = "character",
        affiliation = "character",
        interests = "character",
        homepage = "character",
        citations_total = "numeric",
        citations_5y = "numeric",
        h_index = "numeric",
        h_index_5y = "numeric",
        i10_index = "numeric",
        i10_index_5y = "numeric",
        publications = "data.frame"
    ),
    prototype = list(
        scholar_id = character(0),
        name = character(0),
        affiliation = character(0),
        interests = character(0),
        homepage = character(0),
        citations_total = numeric(0),
        citations_5y = numeric(0),
        h_index = numeric(0),
        h_index_5y = numeric(0),
        i10_index = numeric(0),
        i10_index_5y = numeric(0),
        publications = data.frame()
    )
)

#' @name ScholarData-class
#' @title ScholarData S4 Class
#' @description S4 class for storing comprehensive scholar data including citation history
#' @slot profiles list of ScholarProfile objects
#' @slot citation_history data.frame containing historical citation data
#' @slot collaboration_network igraph object representing collaboration network
#' @slot analysis_date Date object when analysis was performed
#' @import igraph
#' @export
setClass("ScholarData",
    slots = c(
        profiles = "list",
        citation_history = "data.frame",
        collaboration_network = "ANY",
        analysis_date = "Date"
    ),
    prototype = list(
        profiles = list(),
        citation_history = data.frame(),
        collaboration_network = igraph::make_empty_graph(),
        analysis_date = Sys.Date()
    )
)

#' @name calculateMetrics
#' @title Calculate Citation Metrics
#' @description Calculates various citation metrics (e.g., h-index, i10-index, m-index) for a scholar's profile.
#'
#' @param object An object of class `ScholarProfile`.
#' @param metric A character string specifying the metric to calculate. Options are: "h_index", "i10_index", or "m_index".
#' @param ... Additional arguments passed to the generic function (currently unused).
#'
#' @return A numeric value representing the chosen citation metric.
#'
#' @examples
#' scholar_profile <- new("ScholarProfile", publications = data.frame(citedby = c(10, 20, 30, 40), year = c(2000, 2005, 2010, 2015)))
#' calculateMetrics(scholar_profile, metric = "h_index")
#' calculateMetrics(scholar_profile, metric = "i10_index")
#' calculateMetrics(scholar_profile, metric = "m_index")
#'
#' @export
setGeneric("calculateMetrics", function(object, ...) standardGeneric("calculateMetrics"))

#' @method calculateMetrics ScholarProfile
#' @rdname calculateMetrics
setMethod(
    "calculateMetrics", "ScholarProfile",
    function(object, metric = c("h_index", "i10_index", "m_index")) {
        metric <- match.arg(metric)

        citations <- sort(object@publications$citedby, decreasing = TRUE)

        if (metric == "h_index") {
            h <- 0
            for (i in seq_along(citations)) {
                if (citations[i] >= i) {
                    h <- i
                } else {
                    break
                }
            }
            return(h)
        } else if (metric == "i10_index") {
            return(sum(citations >= 10))
        } else if (metric == "m_index") {
            h <- calculateMetrics(object, "h_index")
            valid_years <- na.omit(object@publications$year)
            time_diff <- difftime(Sys.Date(), min(valid_years), units = "days")
            career_years <- as.numeric(time_diff) / 365.25
            return(ifelse(career_years > 0, h / career_years, 0))
        }
    }
)

#' @name plot
#' @title Plot Scholar Profile Metrics
#' @description Plot various metrics (citations, publications, or h-index) for a scholar's profile.
#'
#' @param x An object of class `ScholarProfile`.
#' @param y Ignored, for method consistency.
#' @param type A character string indicating the type of plot to generate. Options are: "citations", "publications", or "h_index".
#'
#' @param ... Additional parameters passed to ggplot or other functions.
#'
#' @return A `ggplot2` object representing the plot.
#'
#' @examples
#' scholar_profile <- new("ScholarProfile", publications = data.frame(citedby = c(10, 20, 30, 40), year = c(2000, 2005, 2010, 2015), title = c("Paper1", "Paper2", "Paper3", "Paper4")))
#' plot(scholar_profile, type = "citations")
#' plot(scholar_profile, type = "publications")
#' plot(scholar_profile, type = "h_index")
#'
#' @export
setGeneric("plot", function(x, y, ...) standardGeneric("plot"))

#' @method plot ScholarProfile
#' @rdname plot
#' @export
setMethod(
    "plot", "ScholarProfile",
    function(x, y, type = c("citations", "publications", "h_index"), ...) {
        type <- match.arg(type)

        if (type == "citations") {
            pub_data <- x@publications %>%
                arrange(desc(year)) %>%
                head(20)

            p <- ggplot(pub_data, aes(x = reorder(title, citedby), y = citedby)) +
                geom_bar(stat = "identity", fill = "steelblue") +
                coord_flip() +
                labs(
                    title = sprintf("Top 20 Publications by Citations - %s", x@name),
                    x = "Publication Title",
                    y = "Number of Citations"
                ) +
                theme_minimal() +
                theme(axis.text = element_text(size = 8))

            print(p)
        } else if (type == "publications") {
            yearly_pubs <- x@publications %>%
                group_by(year) %>%
                summarise(count = n(), total_citations = sum(citedby, na.rm = TRUE))

            p <- ggplot(yearly_pubs, aes(x = year, y = count)) +
                geom_line(color = "blue", size = 1.2) +
                geom_point(size = 3) +
                labs(
                    title = sprintf("Publications per Year - %s", x@name),
                    x = "Year",
                    y = "Number of Publications"
                ) +
                theme_minimal()

            print(p)
        } else if (type == "h_index") {
            yearly_data <- x@publications %>%
                arrange(year) %>%
                mutate(cumulative_citations = cumsum(citedby)) %>%
                group_by(year) %>%
                summarise(
                    total_pubs = n(),
                    total_citations = sum(citedby)
                )

            yearly_data$h_index <- sapply(seq_along(yearly_data$year), function(i) {
                pubs_so_far <- x@publications %>% filter(year <= yearly_data$year[i])
                citations <- sort(pubs_so_far$citedby, decreasing = TRUE)
                h <- 0
                for (j in seq_along(citations)) {
                    if (citations[j] >= j) h <- j else break
                }
                return(h)
            })

            p <- ggplot(yearly_data, aes(x = year, y = h_index)) +
                geom_line(color = "darkgreen", size = 1.5) +
                geom_point(size = 3) +
                labs(
                    title = sprintf("h-index Evolution - %s", x@name),
                    x = "Year",
                    y = "h-index"
                ) +
                theme_minimal()

            print(p)
        }
    }
)
