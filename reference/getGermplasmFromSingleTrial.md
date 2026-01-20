# Get germplasm metadata for a single trial via BrAPI

Queries the BrAPI `/search/germplasm` endpoint for a given trial and
returns a data frame of germplasm accessions associated with that trial

## Usage

``` r
getGermplasmFromSingleTrial(study_id, brapiConnection, verbose = F)
```

## Arguments

- study_id:

  A single studyDbId to query germplasm for.

- brapiConnection:

  A BrAPI connection object, typically from
  [`BrAPI::createBrAPIConnection()`](https://triticeaetoolbox.github.io/BrAPI.R/reference/createBrAPIConnection.html),
  with a `$search()` method.

- verbose:

  Logical; if `TRUE`, print messages about the retrieval process.

## Value

A data frame of germplasm metadata for the given trial, with one row per
germplasm. Columns include `studyDbId`, `germplasmDbId`,
`germplasmName`, and `synonym`. If no result is found, not sure what
happens.

## Examples

``` r
if (FALSE) { # \dontrun{
brapiConn <- BrAPI::createBrAPIConnection("wheat-sandbox.triticeaetoolbox.org", is_breedbase = TRUE)

germ_df <- getGermplasmFromSingleTrial("8128", brapiConn)
germ_df
} # }
```
