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
brapiConn <- BrAPI::createBrAPIConnection("wheat-sandbox.triticeaetoolbox.org", is_breedbase = TRUE)

traits_df <- getTraitsFromSingleTrial("8128", brapiConn)
traits_df
#> # A tibble: 18 × 2
#>    observationVariableDbId observationVariableName                              
#>    <chr>                   <chr>                                                
#>  1 85465                   Aboveground biomass at maturity - g|CO_321:0501159   
#>  2 84161                   Grain number per spike - grain/spike|CO_321:0001200  
#>  3 84800                   Grain weight - 1000 kernels - g/1000 grain|CO_321:00…
#>  4 84440                   Grain weight per spike - g|CO_321:0001647            
#>  5 84527                   Grain yield - kg/ha|CO_321:0001218                   
#>  6 84336                   Heading time - Julian date (JD)|CO_321:0001233       
#>  7 84666                   Maturity time - physiological - Julian date (JD)|CO_…
#>  8 84308                   Plant height - cm|CO_321:0001301                     
#>  9 84167                   Spike number - spike/m2|CO_321:0001599               
#> 10 85465                   Aboveground biomass at maturity - g|CO_321:0501159   
#> 11 84161                   Grain number per spike - grain/spike|CO_321:0001200  
#> 12 84800                   Grain weight - 1000 kernels - g/1000 grain|CO_321:00…
#> 13 84440                   Grain weight per spike - g|CO_321:0001647            
#> 14 84527                   Grain yield - kg/ha|CO_321:0001218                   
#> 15 84336                   Heading time - Julian date (JD)|CO_321:0001233       
#> 16 84666                   Maturity time - physiological - Julian date (JD)|CO_…
#> 17 84308                   Plant height - cm|CO_321:0001301                     
#> 18 84167                   Spike number - spike/m2|CO_321:0001599               
```
