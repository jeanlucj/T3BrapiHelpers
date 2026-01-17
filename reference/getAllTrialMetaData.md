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
brapiConn <- BrAPI::createBrAPIConnection("wheat-sandbox.triticeaetoolbox.org", is_breedbase = TRUE)

# Retrieve trial metadata for "Wheat"
all_trials <- getAllTrialMetaData(brapiConn, "Wheat")
all_trials
#> # A tibble: 3,819 × 12
#>    study_db_id study_name study_type study_description location_name trial_db_id
#>    <chr>       <chr>      <chr>      <chr>             <chr>         <chr>      
#>  1 7658        1RS-Dry_2… phenotypi… , 1RS drought ex… Davis, CA     343        
#>  2 7040        1RS-Irr_2… phenotypi… , 1RS drought ex… Davis, CA     343        
#>  3 8128        2017_West… NA         2017 trial        West Lafayet… 368        
#>  4 8129        2018_West… NA         2018 trial        West Lafayet… 368        
#>  5 8200        2020_Y1_1  phenotypi… 2020 Y1-1 ACRE    West Lafayet… 9287       
#>  6 8202        2020_Y1_2  phenotypi… 2020 Y1-2 ACRE    West Lafayet… 9287       
#>  7 8189        2020_Y1_3  phenotypi… 2019-2020 Y1-3 A… West Lafayet… 9287       
#>  8 8194        2020_Y2_1  Prelimina… 2019-2020 Y2-1 A… West Lafayet… 9287       
#>  9 8195        2020_Y2_2  Prelimina… 2019-2020 Y2-2 A… West Lafayet… 9287       
#> 10 8191        2020_Y2_3  Prelimina… 2019-2020 Y2-3 A… West Lafayet… 9287       
#> # ℹ 3,809 more rows
#> # ℹ 6 more variables: start_date <dttm>, end_date <dttm>, program_name <chr>,
#> #   common_crop_name <chr>, experimental_design <chr>, create_date <dttm>
```
