# Get germplasm metadata for multiple trials

Wrapper around
[`getGermplasmFromSingleTrial`](https://jeanlucj.github.io/T3BrapiHelpers/reference/getGermplasmFromSingleTrial.md)
to retrieve and combine germplasm metadata for a vector of trial IDs.

## Usage

``` r
getGermplasmFromTrialVec(study_id_vec, brapiConnection, verbose = F)
```

## Arguments

- study_id_vec:

  A character vector of studyDbIds to query.

- brapiConnection:

  A BrAPI connection object as used in
  [`getGermplasmFromSingleTrial()`](https://jeanlucj.github.io/T3BrapiHelpers/reference/getGermplasmFromSingleTrial.md).

- verbose:

  Logical; passed on to
  [`getGermplasmFromSingleTrial()`](https://jeanlucj.github.io/T3BrapiHelpers/reference/getGermplasmFromSingleTrial.md)
  to control logging. If FALSE display purrr progress bar

## Value

A data frame obtained by row-binding the results of each trial, with one
row per germplasm per trial

## Examples

``` r
if (FALSE) { # \dontrun{
brapiConn <- BrAPI::createBrAPIConnection("wheat-sandbox.triticeaetoolbox.org", is_breedbase = TRUE)

all_germ <- getGermplasmFromTrialVec(c("8128", "9421"), brapiConn)
all_germ
} # }
```
