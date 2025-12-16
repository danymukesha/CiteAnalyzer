#' Get Scholar Metrics
#'
#' Calculate comprehensive metrics for a scholar profile
#'
#' @param scholar_profile ScholarProfile object
#' @param metrics Character vector of metrics to calculate
#'
#' @return list containing calculated metrics
#' @export
GetScholarMetrics <- function(scholar_profile,
                              metrics = c(
                                  "h_index",
                                  "i10_index",
                                  "m_index",
                                  "citations_per_paper"
                              )) {
    if (!inherits(scholar_profile, "ScholarProfile")) {
        stop("scholar_profile must be a ScholarProfile object")
    }

    result <- list()

    if ("h_index" %in% metrics) {
        result$h_index <- calculateMetrics(scholar_profile, "h_index")
    }

    if ("i10_index" %in% metrics) {
        result$i10_index <- calculateMetrics(scholar_profile, "i10_index")
    }

    if ("m_index" %in% metrics) {
        result$m_index <- calculateMetrics(scholar_profile, "m_index")
    }

    if ("citations_per_paper" %in% metrics) {
        total_pubs <- nrow(scholar_profile@publications)
        total_citations <- sum(scholar_profile@publications$citedby, na.rm = TRUE)
        result$citations_per_paper <- ifelse(total_pubs > 0, total_citations / total_pubs, 0)
    }

    return(result)
}

#' Compare Scholars
#'
#' Compare multiple scholars based on various metrics
#'
#' @param scholar_profiles list of ScholarProfile objects
#' @param metrics Character vector of metrics to compare
#'
#' @return data.frame with comparison results
#' @export
CompareScholars <- function(scholar_profiles, metrics = c("h_index", "i10_index", "citations_total", "publications_count")) {
    if (!is.list(scholar_profiles) || length(scholar_profiles) < 2) {
        stop("scholar_profiles must be a list with at least 2 ScholarProfile objects")
    }

    comparison_data <- data.frame()

    for (i in seq_along(scholar_profiles)) {
        profile <- scholar_profiles[[i]]

        if (!inherits(profile, "ScholarProfile")) {
            warning(sprintf("Element %d is not a ScholarProfile object, skipping", i))
            next
        }

        row <- data.frame(
            scholar_id = profile@scholar_id,
            name = profile@name,
            affiliation = profile@affiliation,
            h_index = profile@h_index,
            i10_index = profile@i10_index,
            citations_total = profile@citations_total,
            publications_count = nrow(profile@publications),
            stringsAsFactors = FALSE
        )

        comparison_data <- rbind(comparison_data, row)
    }

    if (nrow(comparison_data) == 0) {
        stop("No valid ScholarProfile objects found for comparison")
    }

    # Rank scholars for each metric
    for (metric in intersect(metrics, colnames(comparison_data))) {
        comparison_data[[paste0(metric, "_rank")]] <- rank(-comparison_data[[metric]], ties.method = "min")
    }

    # Calculate composite score (normalized rankings)
    rank_cols <- grep("_rank$", colnames(comparison_data), value = TRUE)
    if (length(rank_cols) > 0) {
        comparison_data$composite_score <- rowMeans(comparison_data[, rank_cols, drop = FALSE])
        comparison_data$overall_rank <- rank(comparison_data$composite_score, ties.method = "min")
    }

    return(comparison_data)
}

#' Analyze Citation Trends
#'
#' Analyze citation trends over time for a scholar or group of scholars
#'
#' @param scholar_data ScholarData object or list of ScholarProfile objects
#' @param time_period Character string specifying time period ("all", "5y", "10y")
#'
#' @return data.frame with trend analysis
#' @export
AnalyzeCitationTrends <- function(scholar_data, time_period = "all") {
    if (inherits(scholar_data, "ScholarData")) {
        profiles <- scholar_data@profiles
    } else if (is.list(scholar_data) && all(sapply(scholar_data, inherits, "ScholarProfile"))) {
        profiles <- scholar_data
    } else {
        stop("scholar_data must be a ScholarData object or list of ScholarProfile objects")
    }

    current_year <- as.numeric(format(Sys.Date(), "%Y"))

    # Determine year range based on time_period
    if (time_period == "5y") {
        start_year <- current_year - 5
    } else if (time_period == "10y") {
        start_year <- current_year - 10
    } else {
        start_year <- 1900 # Effectively "all" years
    }

    trend_data <- data.frame()

    for (profile in profiles) {
        pub_data <- profile@publications

        if (nrow(pub_data) > 0) {
            # Filter by year period
            pub_data <- pub_data[pub_data$year >= start_year & !is.na(pub_data$year), ]

            if (nrow(pub_data) > 0) {
                yearly_stats <- pub_data %>%
                    group_by(year) %>%
                    summarise(
                        publications = n(),
                        total_citations = sum(citedby, na.rm = TRUE),
                        avg_citations = mean(citedby, na.rm = TRUE),
                        h_index_estimate = sapply(unique(year), function(y) {
                            pubs_so_far <- pub_data[pub_data$year <= y, ]
                            citations <- sort(pubs_so_far$citedby, decreasing = TRUE)
                            h <- 0
                            for (i in seq_along(citations)) {
                                if (citations[i] >= i) h <- i else break
                            }
                            return(h)
                        }),
                        .groups = "drop"
                    )

                yearly_stats$scholar_id <- profile@scholar_id
                yearly_stats$scholar_name <- profile@name

                trend_data <- rbind(trend_data, yearly_stats)
            }
        }
    }

    return(trend_data)
}

#' Create Citation Network
#'
#' Create a co-citation network from scholar publications
#'
#' @param scholar_profiles list of ScholarProfile objects
#' @param min_citations Integer minimum citations for a paper to be included
#'
#' @return igraph object representing the citation network
#' @export
CreateCitationNetwork <- function(scholar_profiles, min_citations = 5) {
    if (!is.list(scholar_profiles)) {
        stop("scholar_profiles must be a list of ScholarProfile objects")
    }

    # Extract all publications from all scholars
    all_publications <- data.frame()

    for (profile in scholar_profiles) {
        if (!inherits(profile, "ScholarProfile")) {
            warning("Skipping non-ScholarProfile object")
            next
        }

        pubs <- profile@publications
        pubs$scholar_id <- profile@scholar_id
        pubs$scholar_name <- profile@name

        all_publications <- rbind(all_publications, pubs)
    }

    if (nrow(all_publications) == 0) {
        stop("No publications found to create network")
    }

    # Filter by minimum citations
    all_publications <- all_publications[all_publications$citedby >= min_citations, ]

    if (nrow(all_publications) == 0) {
        stop(sprintf("No publications meet the minimum citation threshold of %d", min_citations))
    }

    # Create edges based on co-citations (simplified approach)
    # In a real implementation, you would need actual citation data between papers
    # This creates a network based on shared authors and similar topics as a proxy

    # Extract authors and create edges
    author_edges <- data.frame()

    for (i in 1:nrow(all_publications)) {
        authors_i <- strsplit(all_publications$authors[i], ",")[[1]]
        authors_i <- trimws(authors_i)

        for (j in (i + 1):nrow(all_publications)) {
            if (j > nrow(all_publications)) break

            authors_j <- strsplit(all_publications$authors[j], ",")[[1]]
            authors_j <- trimws(authors_j)

            # Find common authors
            common_authors <- intersect(authors_i, authors_j)

            if (length(common_authors) > 0) {
                weight <- length(common_authors) *
                    min(all_publications$citedby[i], all_publications$citedby[j]) / 100

                author_edges <- rbind(author_edges, data.frame(
                    from = paste0("paper_", i),
                    to = paste0("paper_", j),
                    weight = weight,
                    common_authors = length(common_authors)
                ))
            }
        }
    }

    # Create graph
    if (nrow(author_edges) > 0) {
        g <- igraph::graph_from_data_frame(author_edges, directed = FALSE)

        # Add vertex attributes
        V(g)$paper_title <- all_publications$title[as.numeric(gsub("paper_", "", V(g)$name))]
        V(g)$citations <- all_publications$citedby[as.numeric(gsub("paper_", "", V(g)$name))]
        V(g)$year <- all_publications$year[as.numeric(gsub("paper_", "", V(g)$name))]
        V(g)$scholar_name <- all_publications$scholar_name[as.numeric(gsub("paper_", "", V(g)$name))]

        # Normalize edge weights
        E(g)$weight <- E(g)$weight / max(E(g)$weight) * 10

        return(g)
    } else {
        warning("No edges found to create network - no shared authors between highly cited papers")
        return(igraph::make_empty_graph())
    }
}

#' Find Collaborators
#'
#' Identify potential collaborators based on research interests and citation patterns
#'
#' @param target_scholar ScholarProfile object for the target scholar
#' @param candidate_scholars list of ScholarProfile objects for potential collaborators
#' @param min_similarity Numeric minimum similarity score (0-1)
#'
#' @return data.frame with potential collaborators ranked by similarity
#' @export
FindCollaborators <- function(target_scholar, candidate_scholars, min_similarity = 0.3) {
    if (!inherits(target_scholar, "ScholarProfile")) {
        stop("target_scholar must be a ScholarProfile object")
    }

    if (!is.list(candidate_scholars) || length(candidate_scholars) == 0) {
        stop("candidate_scholars must be a non-empty list of ScholarProfile objects")
    }

    # Extract research interests keywords
    target_interests <- strsplit(tolower(target_scholar@interests), "[,;\\.]")[[1]]
    target_interests <- trimws(target_interests)
    target_interests <- target_interests[target_interests != ""]

    results <- data.frame()

    for (candidate in candidate_scholars) {
        if (!inherits(candidate, "ScholarProfile")) {
            next
        }

        # Skip if same scholar
        if (candidate@scholar_id == target_scholar@scholar_id) {
            next
        }

        # Calculate interest similarity
        candidate_interests <- strsplit(tolower(candidate@interests), "[,;\\.]")[[1]]
        candidate_interests <- trimws(candidate_interests)
        candidate_interests <- candidate_interests[candidate_interests != ""]

        if (length(target_interests) > 0 && length(candidate_interests) > 0) {
            # Simple Jaccard similarity
            intersection <- length(intersect(target_interests, candidate_interests))
            union <- length(union(target_interests, candidate_interests))
            interest_similarity <- ifelse(union > 0, intersection / union, 0)
        } else {
            interest_similarity <- 0
        }

        # Calculate citation pattern similarity (simplified)
        # In a real implementation, you'd use more sophisticated methods
        target_h_index <- target_scholar@h_index
        candidate_h_index <- candidate@h_index

        h_index_similarity <- 1 - abs(log(target_h_index + 1) - log(candidate_h_index + 1)) /
            max(log(target_h_index + 1), log(candidate_h_index + 1), 1)

        # Composite similarity score
        composite_similarity <- (0.7 * interest_similarity) + (0.3 * h_index_similarity)

        if (composite_similarity >= min_similarity) {
            row <- data.frame(
                candidate_name = candidate@name,
                candidate_id = candidate@scholar_id,
                candidate_affiliation = candidate@affiliation,
                interest_similarity = round(interest_similarity, 3),
                h_index_similarity = round(h_index_similarity, 3),
                composite_similarity = round(composite_similarity, 3),
                target_h_index = target_h_index,
                candidate_h_index = candidate_h_index,
                stringsAsFactors = FALSE
            )

            results <- rbind(results, row)
        }
    }

    # Sort by composite similarity
    if (nrow(results) > 0) {
        results <- results[order(-results$composite_similarity), ]
        rownames(results) <- NULL
    }

    return(results)
}

#' Estimate Impact Factor
#'
#' Estimate journal impact factor based on citation data
#'
#' @param publications data.frame containing publication data
#' @param year_range Integer number of years to consider (default: 5)
#'
#' @return data.frame with estimated impact factors by journal
#' @export
estimate_impact_factor <- function(publications, year_range = 5) {
    if (!is.data.frame(publications)) {
        stop("publications must be a data.frame")
    }

    required_cols <- c("journal", "year", "citedby")
    if (!all(required_cols %in% colnames(publications))) {
        stop(sprintf("publications must contain columns: %s", paste(required_cols, collapse = ", ")))
    }

    current_year <- as.numeric(format(Sys.Date(), "%Y"))
    cutoff_year <- current_year - year_range

    # Filter recent publications
    recent_pubs <- publications[publications$year >= cutoff_year, ]

    if (nrow(recent_pubs) == 0) {
        stop("No recent publications found for impact factor estimation")
    }

    # Calculate citations per paper per journal
    journal_stats <- recent_pubs %>%
        group_by(journal) %>%
        summarise(
            total_papers = n(),
            total_citations = sum(citedby, na.rm = TRUE),
            avg_citations = mean(citedby, na.rm = TRUE),
            median_citations = median(citedby, na.rm = TRUE),
            h5_index = sapply(unique(journal), function(j) {
                journal_pubs <- recent_pubs[recent_pubs$journal == j, ]
                citations <- sort(journal_pubs$citedby, decreasing = TRUE)
                h <- 0
                for (i in seq_along(citations)) {
                    if (citations[i] >= i) h <- i else break
                }
                return(h)
            }),
            .groups = "drop"
        )

    # Filter journals with sufficient papers
    journal_stats <- journal_stats[journal_stats$total_papers >= 5, ]

    if (nrow(journal_stats) == 0) {
        warning("No journals with sufficient papers (>=5) for reliable impact factor estimation")
        return(data.frame())
    }

    # Estimate impact factor (simplified - actual IF calculation is more complex)
    journal_stats$estimated_impact_factor <- journal_stats$avg_citations * 0.8

    # Sort by estimated impact factor
    journal_stats <- journal_stats[order(-journal_stats$estimated_impact_factor), ]

    return(journal_stats)
}
