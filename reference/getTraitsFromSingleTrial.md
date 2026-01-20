# Get traits measured from a single trial via BrAPI

Queries the BrAPI `/search/variables` endpoint for a given trial and
returns a data frame of traits and their DbIds measured in that trial

## Usage

``` r
getTraitsFromSingleTrial(study_id, brapiConnection, verbose = F)
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

A data frame of traits for the given trial, with one row per trait
Columns include `observationVariableDbId` and `observationVariableName`.
If no result is found, not sure what happens...

## Examples

``` r
if (FALSE) { # \dontrun{
brapiConn <- BrAPI::createBrAPIConnection("wheat-sandbox.triticeaetoolbox.org", is_breedbase = TRUE)

traits_df <- getTraitsFromSingleTrial("8128", brapiConn)
traits_df
} # }
```
