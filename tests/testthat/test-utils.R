library(testthat)
library(CiteAnalyzer)

test_that("get_co_citation_network handles inputs correctly", {
    # Test with valid inputs
    pub_ids <- sprintf("pub_%d", 1:10)
    network <- get_co_citation_network(pub_ids, max_connections = 50)

    expect_s3_class(network, "igraph")
    expect_true(igraph::vcount(network) <= 10)

    # Test with invalid inputs
    expect_error(get_co_citation_network(123), "publication_ids must be a non-empty character vector")
    expect_error(get_co_citation_network(character(0)), "publication_ids must be a non-empty character vector")
})

test_that("ScholarProfile function creates proper object", {
    # Skip actual web requests in testing
    skip_on_cran()

    # Create a mock scholar profile using test data
    test_file <- system.file("extdata", "example_scholars.csv", package = "CiteAnalyzer")

    if (file.exists(test_file)) {
        test_data <- read.csv(test_file, stringsAsFactors = FALSE)
        if (nrow(test_data) > 0) {
            # Use first scholar ID from test data
            test_id <- test_data$scholar_id[1]

            # This will be slow due to actual web requests, so we limit publications
            profile_data <- ScholarProfile(test_id, max_publications = 3, include_network = FALSE)

            expect_s4_class(profile_data, "ScholarData")
            expect_equal(length(profile_data@profiles), 1)
            expect_true(is.data.frame(profile_data@citation_history))
        }
    }
})

test_that("ScholarProfile skips network creation when include_network = FALSE", {
    skip_on_cran()

    mock_profile <- methods::new(
        "ScholarProfile",
        name = "Test Scholar",
        scholar_id = "test123",
        citations_total = 10,
        h_index = 2,
        publications = data.frame(
            title = "Paper",
            year = 2022,
            citedby = 10
        )
    )

    local_mocked_bindings(
        ExtractScholarData = function(...) mock_profile,
        GetScholarMetrics = function(...) data.frame(),
        AnalyzeCitationTrends = function(...) data.frame()
    )

    result <- ScholarProfile("test123", include_network = FALSE)

    expect_s4_class(result, "ScholarData")
    expect_equal(igraph::gsize(result@collaboration_network), 0)
})

test_that("ScholarProfile validates scholar_id input", {
    expect_error(
        ScholarProfile(""),
        "scholar_id must be a non-empty character string"
    )

    expect_error(
        ScholarProfile(NA),
        "scholar_id must be a non-empty character string"
    )

    expect_error(
        ScholarProfile(123),
        "scholar_id must be a non-empty character string"
    )
})

test_that("ScholarProfile executes and returns ScholarData", {
    mock_profile <- methods::new(
        "ScholarProfile",
        name = "Test Scholar",
        scholar_id = "abc123",
        citations_total = 12,
        h_index = 3,
        publications = data.frame(
            title = "Paper 1",
            year = 2022,
            citedby = 12,
            stringsAsFactors = FALSE
        )
    )

    testthat::local_mocked_bindings(
        ExtractScholarData = function(...) mock_profile,
        GetScholarMetrics = function(...) data.frame(),
        AnalyzeCitationTrends = function(...) data.frame(),
        CreateCitationNetwork = function(...) igraph::make_empty_graph(),
        .env = asNamespace("CiteAnalyzer")
    )

    result <- ScholarProfile("abc123", include_network = FALSE)

    expect_s4_class(result, "ScholarData")
    expect_equal(length(result@profiles), 1)

    expect_no_error(ScholarProfile("abc123", include_network = TRUE))

    expect_error(ScholarProfile("", include_network = TRUE))
})

# extra

test_that("ScholarProfile returns valid ScholarData object", {
    skip_on_cran()

    mock_profile <- methods::new(
        "ScholarProfile",
        name = "Test Scholar",
        scholar_id = "test123",
        citations_total = 42,
        h_index = 5,
        publications = data.frame(
            title = c("Paper A", "Paper B"),
            year = c(2020, 2021),
            citedby = c(20, 22),
            stringsAsFactors = FALSE
        )
    )

    local_mocked_bindings(
        ExtractScholarData = function(scholar_id, max_publications) {
            mock_profile
        },
        GetScholarMetrics = function(profile) {
            data.frame(
                h_index = profile@h_index,
                i10_index = 2
            )
        },
        AnalyzeCitationTrends = function(profiles) {
            data.frame(
                year = 2020:2021,
                citations = c(20, 22)
            )
        },
        CreateCitationNetwork = function(profiles) {
            igraph::make_ring(2)
        }
    )

    result <- expect_message(
        ScholarProfile("test123", max_publications = 5, include_network = TRUE)
    )


    expect_s4_class(result, "ScholarData")
    expect_length(result@profiles, 1)
    expect_true(is.data.frame(result@citation_history))
    expect_s3_class(result@collaboration_network, "igraph")
    expect_equal(result@profiles[[1]]@name, "Test Scholar")
})
