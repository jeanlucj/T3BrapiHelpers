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
brapiConn <- BrAPI::createBrAPIConnection("wheat-sandbox.triticeaetoolbox.org", is_breedbase = TRUE)

all_germ <- getGermplasmFromTrialVec(c("8128", "9421"), brapiConn)
#>  ■■■■■■■■■■■■■■■■                  50% |  ETA:  4s
all_germ
#> # A tibble: 402 × 5
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
#> # ℹ 392 more rows
```
