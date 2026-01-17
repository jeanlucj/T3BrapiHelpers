# Get genotyping protocol metadata for a single germplasm

Queries the T3 AJAX interface using the `$wizard()` method of a
brapiConnection to determine which genotyping protocols have been used
for a specific germplasm

## Usage

``` r
getGenoProtocolFromSingleGerm(germ_id, brapiConnection, verbose = F)
```

## Arguments

- germ_id:

  The germplasmDbId for the accession of interest.

- brapiConnection:

  A BrAPI connection object, typically from
  [`BrAPI::createBrAPIConnection()`](https://triticeaetoolbox.github.io/BrAPI.R/reference/createBrAPIConnection.html),
  with a `$wizard()` method.

## Value

A tibble with a single row containing `germplasmDbId`,
`genoProtocolDbId`, and `genoProtocolName`. The genotyping protocol
columns are list columns, potentially containing multiple protocol
IDs/names.

## Examples

``` r
brapiConn <- BrAPI::createBrAPIConnection("wheat-sandbox.triticeaetoolbox.org", is_breedbase = TRUE)

winner_geno_protocols <- getGenoProtocolFromGermVec("1284387", brapiConn)
winner_geno_protocols
#> # A tibble: 1 × 3
#>   germplasmDbId genoProtocolDbId genoProtocolName
#>   <chr>         <list>           <list>          
#> 1 1284387       <lgl [1]>        <lgl [1]>       
```
