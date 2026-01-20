# Retrieve metadata on all trials for a given crop

Queries the BrAPI `/search/studies` endpoint for all studies matching a
given common crop name, handles polling if needed, and compiles the
results into a trial metadata data frame.

## Usage

``` r
getAllTrialMetaData(brapiConnection, cropName)
```

## Arguments

- brapiConnection:

  A BrAPI connection object, typically created by
  [`BrAPI::createBrAPIConnection()`](https://triticeaetoolbox.github.io/BrAPI.R/reference/createBrAPIConnection.html),
  with `$search()` method available.

- cropName:

  A character string giving the BrAPI `commonCropName` to search for
  (e.g. `"wheat"`).

## Value

A tibble-like data frame with one row per trial, containing standardized
trial metadata with cleaned column names and `POSIXct` `start_date` and
`end_date` columns.

## Examples

``` r
if (FALSE) { # \dontrun{
brapiConn <- BrAPI::createBrAPIConnection("wheat-sandbox.triticeaetoolbox.org", is_breedbase = TRUE)

# Retrieve trial metadata for "Wheat"
all_trials <- getAllTrialMetaData(brapiConn, "Wheat")
all_trials
} # }
```
