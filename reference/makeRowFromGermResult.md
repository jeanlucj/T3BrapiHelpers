# Convert a BrAPI germplasm result into a single-row data frame

Takes a single germplasm object from a BrAPI germplasm search and
converts it into a one-row `data.frame` with key identifiers and synonym
metadata.

## Usage

``` r
makeRowFromGermResult(gr, study_id)
```

## Arguments

- gr:

  A list representing a single germplasm result from a BrAPI germplasm
  search.

- study_id:

  The studyDbId (character or numeric) associated with this germplasm in
  the current context.

## Value

A one-row `data.frame` with columns `studyDbId`, `germplasmDbId`,
`germplasmName`, and `synonym`.

## Details

If synonyms are present, only the first synonym is extracted.
