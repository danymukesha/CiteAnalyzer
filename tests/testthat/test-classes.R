library(testthat)
library(CiteAnalyzer)

test_that("calculate_h_index works correctly", {
    # Test case 1: Perfect h-index
    citations1 <- c(10, 9, 8, 7, 6, 5, 4, 3, 2, 1)
    expect_equal(calculate_h_index(citations1), 5)

    # Test case 2: No citations
    citations2 <- rep(0, 10)
    expect_equal(calculate_h_index(citations2), 0)

    # Test case 3: Mixed citations
    citations3 <- c(100, 50, 20, 15, 10, 5, 4, 3, 2, 1)
    expect_equal(calculate_h_index(citations3), 5)

    # Test case 4: Single paper
    citations4 <- c(5)
    expect_equal(calculate_h_index(citations4), 1)

    # Test case 5: Empty vector
    citations5 <- numeric(0)
    expect_equal(calculate_h_index(citations5), 0)

    # Test error handling
    expect_error(calculate_h_index("not numeric"), "citations must be a numeric vector")
})

test_that("calculate_i10_index works correctly", {
    # Test case 1: Some papers with 10+ citations
    citations1 <- c(15, 12, 10, 9, 8, 5, 3, 1)
    expect_equal(calculate_i10_index(citations1), 3)

    # Test case 2: No papers with 10+ citations
    citations2 <- c(9, 8, 7, 6, 5)
    expect_equal(calculate_i10_index(citations2), 0)

    # Test case 3: All papers with 10+ citations
    citations3 <- c(20, 15, 12, 10, 10)
    expect_equal(calculate_i10_index(citations3), 5)

    # Test error handling
    expect_error(calculate_i10_index("not numeric"), "citations must be a numeric vector")
})

test_that("calculate_m_index works correctly", {
    # Test case 1: Normal calculation
    expect_equal(calculate_m_index(10, 2010), 10 / (2024 - 2010 + 2), tolerance = 0.001)

    # Test case 2: Zero h-index
    expect_equal(calculate_m_index(0, 2010), 0)

    # Test case 3: Future publication year (should handle gracefully)
    expect_equal(calculate_m_index(5, 2030), 0) # Career years would be negative

    # Test error handling
    expect_error(calculate_m_index("not numeric", 2010), "h_index must be a non-negative numeric scalar")
    expect_error(calculate_m_index(10, "not numeric"), "first_publication_year must be numeric")
})

test_that("plot.ScholarProfile works for all plot types", {
    skip_if_not_installed("ggplot2")
    skip_if_not_installed("dplyr")

    profile <- new(
        "ScholarProfile",
        scholar_id = "abc123",
        name = "Test Scholar",
        publications = data.frame(
            title = paste("Paper", 1:10),
            year = 2013:2022,
            citedby = c(30, 25, 20, 15, 10, 8, 6, 4, 2, 1),
            stringsAsFactors = FALSE
        )
    )

    expect_silent(plot(profile, type = "citations"))
    expect_silent(plot(profile, type = "publications"))
    expect_silent(plot(profile, type = "h_index"))
})
