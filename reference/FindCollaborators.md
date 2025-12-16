# Find Collaborators

Identify potential collaborators based on research interests and
citation patterns

## Usage

``` r
FindCollaborators(target_scholar, candidate_scholars, min_similarity = 0.3)
```

## Arguments

- target_scholar:

  ScholarProfile object for the target scholar

- candidate_scholars:

  list of ScholarProfile objects for potential collaborators

- min_similarity:

  Numeric minimum similarity score (0-1)

## Value

data.frame with potential collaborators ranked by similarity
