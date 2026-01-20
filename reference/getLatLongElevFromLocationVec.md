# Get location info from a vector of locations via BrAPI

Queries the BrAPI `/search/locations` endpoint and returns a data frame
of lat, long, and elevation values for those locations

## Usage

``` r
getLatLongElevFromLocationVec(loc_vec, brapiConnection, id_or_name = "name")
```

## Arguments

- loc_vec:

  A vector of location names or DB IDs for which you want lat, long, and
  elevation values

- brapiConnection:

  A BrAPI connection object, typically from
  [`BrAPI::createBrAPIConnection()`](https://triticeaetoolbox.github.io/BrAPI.R/reference/createBrAPIConnection.html),
  with a `$search()` method.

- id_or_name:

  A string. If "name" will expect loc_vec to be a vector of location
  names else a vector of location DB IDs.

## Value

A data frame of lattitude, longitude and elevation values for the
loactions

## Examples

``` r
if (FALSE) { # \dontrun{
brapiConn <- BrAPI::createBrAPIConnection("wheat.triticeaetoolbox.org", is_breedbase = TRUE)

locs_df <- getLatLongElevFromLocationVec(c("31", "143"), brapiConn)
locs_df
} # }
```
