# NA

| Data type | Search endpoint | What they return | Common filters |
|----|----|----|----|
| **Studies (Trials)** | `/search/studies` | Study / trial metadata including dates, location, design, crop, program | `studyDbIds`, `studyNames`, `commonCropNames`, `locationDbIds`, `programDbIds`, date ranges |
| **Germplasm** | `/search/germplasm` | Germplasm records (accessions, breeding lines, varieties) | `germplasmDbIds`, `germplasmNames`, `studyDbIds`, `commonCropNames`, `externalReferenceIds` |
| **Observations** | `/search/observations` | Individual trait measurements with values and timestamps | `studyDbIds`, `germplasmDbIds`, `observationVariableDbIds`, `locationDbIds`, time ranges |
| **Observation Units** | `/search/observationunits` | Observation units such as plots, plants, rows, or samples | `studyDbIds`, `germplasmDbIds`, `observationUnitDbIds`, `observationUnitType` |
| **Observation Variables (Traits)** | `/search/variables` | Trait definitions including method, scale, and ontology references | `observationVariableDbIds`, `observationVariableNames`, `ontologyDbIds`, `traitClasses` |
| **Locations** | `/search/locations` | Trial and nursery locations with geographic metadata | `locationDbIds`, `countryCodes`, latitude/longitude bounds |
| **Programs** | `/search/programs` | Breeding or research program metadata | `programDbIds`, `programNames`, `abbreviations` |
| **People** | `/search/people` | Person and contact records associated with studies or programs | `personDbIds`, `names`, `emailAddresses`, `roles` |
| **Markers** | `/search/markers` | Marker metadata (IDs, names, positions, reference alleles) | `markerDbIds`, `markerNames`, `genomeDbIds`, `linkageGroupNames` |
| **Marker Profiles** | `/search/markerprofiles` | Associations between germplasm and genotype datasets | `markerProfileDbIds`, `germplasmDbIds`, `studyDbIds` |
| **Allele Matrices** | `/search/allelematrices` | Genotype call matrices (SNPs or other markers) | `markerProfileDbIds`, `markerDbIds`, `germplasmDbIds` |
| **Samples** | `/search/samples` | Biological sample metadata (DNA, tissue, seed lots) | `sampleDbIds`, `germplasmDbIds`, `studyDbIds`, `sampleType` |
| **Images** | `/search/images` | Image metadata and links associated with plots or units | `studyDbIds`, `observationUnitDbIds`, `imageDbIds`, date ranges |
| **Events** | `/search/events` | Management or environmental events (planting, harvest, treatments) | `studyDbIds`, `eventTypes`, date ranges |
