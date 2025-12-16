# Create Citation Network

Create a co-citation network from scholar publications

## Usage

``` r
CreateCitationNetwork(scholar_profiles, min_citations = 5)
```

## Arguments

- scholar_profiles:

  list of ScholarProfile objects

- min_citations:

  Integer minimum citations for a paper to be included

## Value

igraph object representing the citation network
