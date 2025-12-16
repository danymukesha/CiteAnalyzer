# Extract Scholar Data from Google Scholar

Extracts comprehensive citation data for a Google Scholar profile with
built-in rate limiting to prevent blocking. This function addresses the
common challenge of Google Scholar blocking requests when too many are
made in a short period.

## Usage

``` r
ExtractScholarData(
  scholar_id,
  max_publications = 100,
  rate_limit_seconds = 5,
  retry_attempts = 3,
  user_agent = NULL,
  cache_dir = NULL
)
```

## Arguments

- scholar_id:

  Character string containing the Google Scholar ID (e.g.,
  "qc6CJjYAAAAJ")

- max_publications:

  Integer maximum number of publications to retrieve (default: 100)

- rate_limit_seconds:

  Numeric seconds to wait between requests (default: 5)

- retry_attempts:

  Integer number of retry attempts if request fails (default: 3)

- user_agent:

  Character string for custom user agent (optional)

- cache_dir:

  Directory for storing cached data (default: NULL for temporary cache)

## Value

ScholarProfile object containing scholar data and publications

## Examples

``` r
if (FALSE) { # \dontrun{
# Extract data for a scholar (replace with actual ID)
scholar_data <- ExtractScholarData("qc6CJjYAAAAJ", max_publications = 50)
} # }
```
