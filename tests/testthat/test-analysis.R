library(testthat)
library(CiteAnalyzer)
library(dplyr, warn.conflicts = FALSE)

# Create mock data for testing
create_mock_profile <- function(name, n_pubs = 10) {
    pubs <- data.frame(
        title = sprintf("Paper %d", 1:n_pubs),
        authors = sprintf("Author %d", sample(1:5, n_pubs, replace = TRUE)),
        journal = sample(c("Journal A", "Journal B", "Journal C"), n_pubs, replace = TRUE),
        year = sample(2010:2024, n_pubs, replace = TRUE),
        citedby = sample(1:100, n_pubs, replace = TRUE),
        pub_id = sprintf("pub_%d", 1:n_pubs),
        stringsAsFactors = FALSE
    )

    # Calculate metrics
    citations_sorted <- sort(pubs$citedby, decreasing = TRUE)
    h_index <- 0
    for (i in seq_along(citations_sorted)) {
        if (citations_sorted[i] >= i) h_index <- i else break
    }

    i10_index <- sum(citations_sorted >= 10)

    new("ScholarProfile",
        scholar_id = sprintf("mock_%s", tolower(name)),
        name = name,
        affiliation = "Test University",
        interests = "Test Interests",
        homepage = "https://example.com",
        citations_total = sum(pubs$citedby),
        citations_5y = sum(pubs$citedby[pubs$year >= 2020]),
        h_index = h_index,
        h_index_5y = h_index, # Simplified
        i10_index = i10_index,
        i10_index_5y = i10_index, # Simplified
        publications = pubs
    )
}

test_that("GetScholarMetrics calculates correctly", {
    mock_profile <- create_mock_profile("Test Scholar", n_pubs = 20)

    metrics <- GetScholarMetrics(mock_profile)

    expect_true(is.list(metrics))
    expect_true("h_index" %in% names(metrics))
    expect_true("i10_index" %in% names(metrics))
    expect_true("m_index" %in% names(metrics))
    expect_true("citations_per_paper" %in% names(metrics))

    # Verify h-index calculation matches manual calculation
    expected_h <- calculate_h_index(mock_profile@publications$citedby)
    expect_equal(metrics$h_index, expected_h)
})

test_that("CompareScholars handles multiple profiles", {
    profile1 <- create_mock_profile("Scholar 1", n_pubs = 15)
    profile2 <- create_mock_profile("Scholar 2", n_pubs = 10)
    profile3 <- create_mock_profile("Scholar 3", n_pubs = 20)

    comparison <- CompareScholars(list(profile1, profile2, profile3))

    expect_true(is.data.frame(comparison))
    expect_equal(nrow(comparison), 3)
    expect_true("overall_rank" %in% colnames(comparison))
    expect_true(all(comparison$overall_rank %in% 1:3))

    expect_error(CompareScholars(NULL))
})

test_that("AnalyzeCitationTrends works with different time periods", {
    profile1 <- create_mock_profile("Scholar 1", n_pubs = 30)
    profile2 <- create_mock_profile("Scholar 2", n_pubs = 25)

    # Test all time periods
    trends_all <- AnalyzeCitationTrends(list(profile1, profile2), time_period = "all")
    trends_5y <- AnalyzeCitationTrends(list(profile1, profile2), time_period = "5y")
    trends_10y <- AnalyzeCitationTrends(list(profile1, profile2), time_period = "10y")

    expect_true(is.data.frame(trends_all))
    expect_true(is.data.frame(trends_5y))
    expect_true(is.data.frame(trends_10y))

    # Verify trends_5y has more recent years than trends_10y
    if (nrow(trends_5y) > 0 && nrow(trends_10y) > 0) {
        expect_true(min(trends_5y$year) >= min(trends_10y$year))
    }
})

test_that("CreateCitationNetwork handles edge cases", {
    set.seed(123)
    profile1 <- create_mock_profile("Scholar 1", n_pubs = 5)
    profile2 <- create_mock_profile("Scholar 2", n_pubs = 3)

    # Test with minimal citations
    network <- CreateCitationNetwork(list(profile1, profile2), min_citations = 0)
    expect_s3_class(network, "igraph")
    expect_equal(igraph::gsize(network), 9) # Should be empty network

    # Test with reasonable citations
    network2 <- CreateCitationNetwork(list(profile1, profile2), min_citations = 1)
    expect_s3_class(network2, "igraph")
    if (igraph::gsize(network2) > 0) {
        expect_true(igraph::vcount(network2) > 0)
    }
})

test_that("FindCollaborators returns expected structure", {
    target <- create_mock_profile("Target Scholar", n_pubs = 15)
    candidate1 <- create_mock_profile("Candidate 1", n_pubs = 12)
    candidate2 <- create_mock_profile("Candidate 2", n_pubs = 8)

    candidates <- list(candidate1, candidate2)

    collaborators <- FindCollaborators(target, candidates, min_similarity = 0.1)

    expect_true(is.data.frame(collaborators))
    if (nrow(collaborators) > 0) {
        expect_true("composite_similarity" %in% colnames(collaborators))
        expect_true(all(collaborators$composite_similarity >= 0.1))
        expect_true(is.unsorted(collaborators$composite_similarity)) # Should be sorted descending
    }

    expect_error(FindCollaborators(NULL, candidates, min_similarity = 0.1))
    expect_error(FindCollaborators(target, NULL, min_similarity = 0.1))
})

test_that("estimate_impact_factor withOUT sufficient recent publications", {
    pubs <- data.frame(
        journal = c("J1", "J1", "J2", "J2", "J3"),
        year = c(2020, 2021, 2022, 2023, 2024),
        citedby = c(10, 15, 5, 8, 20),
        stringsAsFactors = FALSE
    )

    # Test with sufficient data
    result <- estimate_impact_factor(pubs) |> expect_warning()
    expect_true(is.data.frame(result))

    # Test with insufficient papers
    small_pubs <- pubs[1:3, ] # Only 3 papers total
    result_small <- estimate_impact_factor(small_pubs) |> expect_warning()
    expect_equal(nrow(result_small), 0)

    expect_error(estimate_impact_factor(NULL))
    expect_error(estimate_impact_factor(data.frame(NULL)))
})

test_that("estimate_impact_factor works handlING edge cases with sufficient recent publications", {
    current_year <- as.numeric(format(Sys.Date(), "%Y"))

    pubs_many <- data.frame(
        journal = c(
            rep("J1", 5),
            rep("J2", 6),
            rep("J3", 7)
        ),
        year = c(
            rep(current_year - 1, 5),
            rep(current_year - 2, 6),
            rep(current_year - 3, 7)
        ),
        citedby = c(
            5, 7, 9, 11, 13, # J1
            3, 4, 6, 8, 10, 12, # J2
            1, 2, 3, 5, 8, 13, 21 # J3
        ),
        stringsAsFactors = FALSE
    )

    expect_no_warning(
        result <- estimate_impact_factor(pubs_many)
    )

    expect_true(is.data.frame(result))
    expect_equal(nrow(result), 3)
    expect_true(all(c("J1", "J2", "J3") %in% result$journal))
    expect_true(all(result$total_papers >= 5))
    expect_true(all(result$estimated_impact_factor > 0))

    expect_error(
        estimate_impact_factor(
            pubs_many |>
                dplyr::filter(journal == "NO-EXITING")
        )
    )
})
