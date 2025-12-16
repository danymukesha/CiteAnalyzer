library(testthat)
library(ggplot2)
library(dplyr)
library(igraph)
library(CiteAnalyzer)

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
    )
)

create_mock_scholar_profile <- function(scholar_id, name, affiliation, interests, homepage,
                                        citations_total, citations_5y, h_index, h_index_5y,
                                        i10_index, i10_index_5y, publications) {
    new("ScholarProfile",
        scholar_id = scholar_id,
        name = name,
        affiliation = affiliation,
        interests = interests,
        homepage = homepage,
        citations_total = citations_total,
        citations_5y = citations_5y,
        h_index = h_index,
        h_index_5y = h_index_5y,
        i10_index = i10_index,
        i10_index_5y = i10_index_5y,
        publications = publications
    )
}

scholar_profile_1 <- create_mock_scholar_profile(
    scholar_id = "qc6CJjYAAAAJ",
    name = "Albert Einstein",
    affiliation = "Institute of Advanced Studies, Princeton",
    interests = "Physics",
    homepage = "",
    citations_total = 189291,
    citations_5y = 51326,
    h_index = 129,
    h_index_5y = 67,
    i10_index = 380,
    i10_index_5y = 214,
    publications = data.frame(
        title = c("Paper A", "Paper B", "Paper C"),
        citedby = c(100, 200, 150),
        year = c(2018, 2019, 2020)
    )
)

scholar_profile_2 <- create_mock_scholar_profile(
    scholar_id = "VWCHlwkAAAAJ",
    name = "Alan Turin",
    affiliation = "Reader, University of Manchester",
    interests = "Mathematics, Computer Science, Cryptography, Artificial Intelligence, Morphogenesis",
    homepage = "",
    citations_total = 78841,
    citations_5y = 30014,
    h_index = 48,
    h_index_5y = 30,
    i10_index = 150,
    i10_index_5y = 57,
    publications = data.frame(
        title = c("Paper D", "Paper D", "Paper C"),
        citedby = c(100, 200, 150),
        year = c(2018, 2019, 2020)
    )
)

test_that("PlotCitationImpact creates the correct plot", {
    p <- PlotCitationImpact(scholar_profile_1, plot_type = "summary")
    expect_s3_class(p, "gg")

    p <- PlotCitationImpact(scholar_profile_1, plot_type = "timeline")
    expect_s3_class(p, "gg")

    p <- PlotCitationImpact(scholar_profile_1,
        plot_type = "comparison",
        compare_with = list(scholar_profile_2)
    )
    expect_s3_class(p, "gg")

    expect_warning(PlotCitationImpact(scholar_profile_1,
        plot_type = "comparison",
        compare_with = list(NULL)
    ))

    expect_no_error(PlotCitationImpact(scholar_profile_1,
        plot_type = "comparison",
        compare_with = list(scholar_profile_2),
        radar_coord = "polar"
    ))


    expect_error(PlotCitationImpact(NULL))



    expect_error(
        PlotCitationImpact(scholar_profile_1,
            plot_type = "invalid_type"
        )
    )
})

create_mock_collaboration_network <- function(num_papers = 10, num_authors = 5) {
    papers <- paste("paper", 1:num_papers, sep = "_")
    scholars <- paste("author", 1:num_authors, sep = "_")
    set.seed(123)
    paper_authors <- lapply(1:num_papers, function(i) sample(scholars, size = sample(2:num_authors, 1), replace = FALSE))

    edges <- list()
    for (i in 1:(num_papers - 1)) {
        for (j in (i + 1):num_papers) {
            common_authors <- intersect(paper_authors[[i]], paper_authors[[j]])
            if (length(common_authors) > 0) {
                edges <- append(edges, list(c(i, j, length(common_authors))))
            }
        }
    }

    g <- graph_from_edgelist(do.call(rbind, edges)[, 1:2], directed = FALSE)

    V(g)$name <- papers

    V(g)$citations <- sample(100:1000, num_papers, replace = TRUE)
    V(g)$year <- sample(2000:2022, num_papers, replace = TRUE)
    V(g)$scholar_name <- sample(scholars, num_papers, replace = TRUE)

    E(g)$weight <- as.numeric(do.call(rbind, edges)[, 3])

    return(g)
}

mock_network <- create_mock_collaboration_network(num_papers = 10, num_authors = 5)

test_that("PlotCollaborationNetwork creates the correct plot", {
    p <- PlotCollaborationNetwork(mock_network)
    expect_s3_class(p, "gg")

    p <- PlotCollaborationNetwork(mock_network, highlight_scholar = V(mock_network)$name[1])
    expect_s3_class(p, "gg")

    expect_no_error(PlotCollaborationNetwork(mock_network, layout_type = "kk"))
    expect_no_error(PlotCollaborationNetwork(mock_network, layout_type = "lgl"))

    expect_error(PlotCollaborationNetwork(NULL), "network must be an igraph object")
    expect_error(PlotCollaborationNetwork(sample_gnp(0, p = 0.1)), "Network has no edges to visualize")
})

test_that("PlotPublicationTrends creates the correct plot", {
    scholar_data <- list(scholar_profile_1, scholar_profile_2)

    p <- PlotPublicationTrends(scholar_data, trend_type = "publications")
    expect_s3_class(p, "gg")

    p <- PlotPublicationTrends(scholar_data, trend_type = "citations")
    expect_s3_class(p, "gg")

    p <- PlotPublicationTrends(scholar_data, trend_type = "both")
    expect_s3_class(p, "gg")

    expect_error(PlotPublicationTrends(scholar_data, trend_type = "invalid_type"))
    expect_error(PlotPublicationTrends(NULL))

    expect_error(PlotPublicationTrends(list()), "No scholar profiles provided")
    expect_error(PlotPublicationTrends(NULL), "scholar_data must be a ScholarData object or list of ScholarProfile objects")
})
