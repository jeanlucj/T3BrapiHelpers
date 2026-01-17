# Determine genotyping protocol metadata for a set of accessions

Wrapper for getGenoProtocolFromSingleGerm.

## Usage

``` r
getGenoProtocolFromGermVec(germ_id_vec, brapiConnection, verbose = F)
```

## Arguments

- germ_id_vec:

  A vector of germplasm DbIds.

- brapiConnection:

  A BrAPI connection object, typically from
  [`BrAPI::createBrAPIConnection()`](https://triticeaetoolbox.github.io/BrAPI.R/reference/createBrAPIConnection.html),
  with a `$wizard()` method.

- verbose:

  Logical; if `FALSE` (default), display purrr progress bar else print
  for each `germplasmDbId`

## Value

A tibble with one row per germplasm, including genotyping protocol IDs
and names as list columns.

## Examples

``` r
brapiConn <- BrAPI::createBrAPIConnection("wheat-sandbox.triticeaetoolbox.org", is_breedbase = TRUE)

germ_geno_protocols <- getGenoProtocolFromGermVec(
  c("1284387", "1382716", "1415479"), brapiConn)
germ_geno_protocols
#> # A tibble: 3 × 3
#>   germplasmDbId genoProtocolDbId genoProtocolName
#>   <chr>         <list>           <list>          
#> 1 1284387       <lgl [1]>        <lgl [1]>       
#> 2 1382716       <lgl [1]>        <lgl [1]>       
#> 3 1415479       <lgl [1]>        <lgl [1]>       
```
