# Retrieve metadata for a set of trials by study IDs

Given a vector of BrAPI study IDs, query the `/studies/{studyDbId}`
endpoint for each and compile a tidy data frame of trial metadata.

## Usage

``` r
getTrialMetaDataFromTrialVec(study_id_vec, brapiConnection)
```

## Arguments

- study_id_vec:

  A character vector of BrAPI study IDs (studyDbId values) to query.

- brapiConnection:

  A BrAPI connection object, typically created by
  [`BrAPI::createBrAPIConnection()`](https://triticeaetoolbox.github.io/BrAPI.R/reference/createBrAPIConnection.html),
  with `$get()` method available.

## Value

A tibble-like data frame with one row per trial and cleaned column names
(via
[`janitor::clean_names()`](https://sfirke.github.io/janitor/reference/clean_names.html)).
Date columns `start_date` and `end_date` are converted to `POSIXct` in
UTC.

## Examples

``` r
brapiConn <- BrAPI::createBrAPIConnection("wheat-sandbox.triticeaetoolbox.org", is_breedbase = TRUE)

# Retrieve metadata for two trials
df <- getTrialMetaDataFromTrialVec(c("8128", "9421"), brapiConn)
df
#> # A tibble: 2 × 12
#>   study_db_id study_name  study_type study_description location_name trial_db_id
#>   <chr>       <chr>       <chr>      <chr>             <chr>         <chr>      
#> 1 8128        2017_WestL… NA         2017 trial        West Lafayet… 368        
#> 2 9421        2022_AYT_D… phenotypi… 2022 AYT Yield T… Dakota Lakes… 9627       
#> # ℹ 6 more variables: start_date <dttm>, end_date <dttm>, program_name <chr>,
#> #   common_crop_name <chr>, experimental_design <chr>, create_date <dttm>
```
