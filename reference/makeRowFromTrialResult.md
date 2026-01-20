# Convert a BrAPI study result into a single-row data frame

Takes a single study object from a BrAPI `studies` response and converts
it into a one-row `data.frame` with key metadata fields. This is a
helper used by functions that assemble trial metadata tables.

## Usage

``` r
makeRowFromTrialResult(tr)
```

## Arguments

- tr:

  A list representing a single trial result from a BrAPI `/studies`
  endpoint, typically
  `brapiConnection$get("studies/ID")$content$result`.

## Value

A one-row `data.frame` with columns such as `studyDbId`, `studyName`,
`studyType`, `studyDescription`, `locationName`, `trialDbID`,
`startDate`, `endDate`, `programName`, `commonCropName`, and
`experimentalDesign`.

## Details

This function assumes the infix operator `%||%` is available in the
calling environment to replace `NULL` with `NA`.
