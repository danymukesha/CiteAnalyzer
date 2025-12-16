# Get Citation History for a Publication

Retrieves the citation history for a specific publication over time

## Usage

``` r
GetCitationHistory(pub_id, rate_limit_seconds = 5)
```

## Arguments

- pub_id:

  Character string containing the Google Scholar publication ID

- rate_limit_seconds:

  Numeric seconds to wait between requests

## Value

data.frame with year and citation count
