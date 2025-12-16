library(testthat)
library(CiteAnalyzer)

test_that("ExtractScholarData handles invalid inputs", {
    expect_error(ExtractScholarData(123), "scholar_id must be a non-empty character string")
    expect_error(ExtractScholarData(""), "scholar_id must be a non-empty character string")
    expect_error(ExtractScholarData("valid_id", max_publications = -1), "max_publications must be a positive integer")
    expect_error(ExtractScholarData("valid_id", rate_limit_seconds = -1), "rate_limit_seconds must be non-negative")
})

test_that("ExtractScholarData returns ScholarProfile object", {
    # Skip actual web requests in testing
    skip_on_cran()
    skip_if_offline()

    # Test with a known scholar ID (mocked for testing)
    test_id <- "qc6CJjYAAAAJ"

    scholar_profile <- ExtractScholarData(test_id, max_publications = 5, rate_limit_seconds = 1)

    expect_s4_class(scholar_profile, "ScholarProfile")
    expect_true(length(scholar_profile@scholar_id) > 0)
    expect_true(is.data.frame(scholar_profile@publications))

    expect_error(ExtractScholarData(test_id, max_publications = 5, rate_limit_seconds = -1))
})

test_that("GetCitationHistory handles invalid inputs", {
    expect_error(GetCitationHistory(123), "pub_id must be a non-empty character string")
    expect_error(GetCitationHistory(""), "pub_id must be a non-empty character string")
})

test_that("GetCitationHistory returns data.frame", {
    # Skip actual web requests
    skip_on_cran()
    skip_if_offline()

    result <- GetCitationHistory("qc6CJjYAAAAJ", rate_limit_seconds = 0.1)

    expect_true(is.data.frame(result))
    expect_true("year" %in% colnames(result))
    expect_true("citations" %in% colnames(result))
})
