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

## Examples

``` r
# Create fake trial result
tr <- list(
  studyDbId = "12345",
  studyName = "Fake Trial",
  studyType = "Yield Trial",
  studyDescription = "Example",
  locationName = "Loc1",
  trialDbId = "trial123",
  startDate = "2020-01-01T00:00:00Z",
  endDate = "2020-02-01T00:00:00Z",
  additionalInfo = list(programName = "Program A"),
  commonCropName = "wheat",
  experimentalDesign = list(description = "RCBD")
)

makeRowFromTrialResult(tr)
#> Error in makeRowFromTrialResult(tr): could not find function "makeRowFromTrialResult"
```
