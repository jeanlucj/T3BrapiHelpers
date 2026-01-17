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
brapiConn <- BrAPI::createBrAPIConnection("wheat-sandbox.triticeaetoolbox.org", is_breedbase = TRUE)

germ_df <- getGermplasmFromSingleTrial("8128", brapiConn)
germ_df
#> # A tibble: 276 × 5
#>    studyDbId germplasmDbId germplasmName   synonyms  pedigree                
#>    <chr>     <chr>         <chr>           <list>    <chr>                   
#>  1 8128      1281721       P0175A1-37-4-1  <chr [2]> 981419/97397            
#>  2 8128      1344336       P2114           <chr [2]> NA/NA                   
#>  3 8128      219113        TRUMAN          <chr [1]> MO11769/MADISON         
#>  4 8128      219183        VA10W-663       <NULL>    NA/NA                   
#>  5 8128      219210        MO081537        <NULL>    KY90C-383-18-1/IL94-1653
#>  6 8128      219264        IL04-24668      <chr [1]> IL98-13404/IL97-3578    
#>  7 8128      219303        VA09W-46        <NULL>    NA/NA                   
#>  8 8128      219311        VA09W-73        <NULL>    NA/NA                   
#>  9 8128      219414        KY93C-1238-17-1 <chr [1]> NA/NA                   
#> 10 8128      219435        SHIRLEY         <chr [3]> NA/NA                   
#> # ℹ 266 more rows
```
