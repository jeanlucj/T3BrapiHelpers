# Retrieve what traits were measured for a set of trials by study IDs

Given a vector of BrAPI study IDs, use the search function of a
Breedbase connection to compile a vector of all traits measured in each
trial in the study_id_vec

## Usage

``` r
getTraitsFromTrialVec(
  study_id_vec,
  brapiConnection,
  namesOrIds = "names",
  verbose = F
)
```

## Arguments

- study_id_vec:

  A character vector of BrAPI study IDs (studyDbId values) to query.

- brapiConnection:

  A BrAPI connection object, typically created by
  [`BrAPI::createBrAPIConnection()`](https://triticeaetoolbox.github.io/BrAPI.R/reference/createBrAPIConnection.html),
  with `$search()` method.

- namesOrIds:

  A string. If "names" return the names of the traits else return the
  trait DB IDs.

- verbose:

  A logical. If TRUE a lot of info on the traits in the studies else a
  purrr progress bar

## Value

A vector of either trait names or trait DB IDs.

## Examples

``` r
if (FALSE) { # \dontrun{
brapiConn <- BrAPI::createBrAPIConnection("wheat-sandbox.triticeaetoolbox.org", is_breedbase = TRUE)

traits <- getTraitsFromTrialVec(c("8128", "9421"), brapiConn)
traits
} # }
```
