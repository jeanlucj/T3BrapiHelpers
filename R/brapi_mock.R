#' Create a Mock BrAPI Connection Object
#'
#' `mock_brapi_connection()` constructs a lightweight stand-in for a BrAPI
#' connection object. This is useful for:
#'
#' * **package examples** (so examples do not call real servers)
#' * **unit tests** with `testthat`
#' * developing functions that consume a BrAPI connection without requiring
#'   internet access or a real database
#'
#' The mock object implements minimal versions of the two BrAPI methods:
#'
#' * `$get(endpoint, ...)`
#' * `$post(endpoint, body)`
#'
#' and returns deterministic, small, fake responses that mimic the structure of
#' real BrAPI responses from The Triticeae Toolbox (T3).
#'
#' ## Supported Mock Endpoints
#'
#' The mock handles the following endpoint patterns:
#'
#' * `"studies/<id>"` – returns a single fake trial metadata record
#' * `"search/studies"` – returns a single fake trial in the `data` block
#' * `"search/studies/<searchId>"` – same as above
#' * `"search/germplasm"` – returns a single germplasm record with a synonym
#'
#' Any unrecognized endpoint returns an empty `data` list.
#'
#' ## When to Use
#'
#' * In examples for functions that take a BrAPI connection
#' * When building tutorials or vignettes without T3 login credentials
#' * When unit-testing BrAPI workflows
#'
#' ## When *Not* to Use
#'
#' * When validating real BrAPI server behavior
#' * When timing or stress-testing real API queries
#'
#' @return
#' A list of class `"MockBrAPI"` with `$get()` and `$post()` methods that return
#' mock BrAPI JSON-like structures.
#'
#' @examples
#' # Create a mock connection
#' mock <- mock_brapi_connection()
#'
#' # Example: pretend to query a study
#' study_result <- mock$get("studies/study1")
#' study_result$content$result$studyName
#'
#' # Example: pretend to search for trials
#' trials <- mock$post("search/studies", body = list(commonCropNames = "wheat"))
#' names(trials$content$result$data[[1]])
#'
#' # Example: pretend to retrieve germplasm metadata
#' germ <- mock$post("search/germplasm", body = list(studyDbIds = "study1"))
#' germ$content$result$data[[1]]$germplasmName
#'
#' @export
mock_brapi_connection <- function() {
  structure(
    list(
      get = function(endpoint, page = NULL, pageSize = NULL) {
        if (grepl("studies/", endpoint)) {
          list(content = list(result = list(
            studyDbId = "study1",
            studyName = "Mock Study",
            studyType = "Yield Trial",
            studyDescription = "Mock description",
            locationName = "Mockville",
            trialDbId = "trial123",
            startDate = "2020-01-01T00:00:00Z",
            endDate = "2020-06-01T00:00:00Z",
            additionalInfo = list(programName = "Mock Program"),
            commonCropName = "wheat",
            experimentalDesign = list(description = "RCBD")
          )))
        } else if (grepl("search/studies/", endpoint)) {
          list(content = list(result = list(data = list(
            list(
              studyDbId = "study1",
              studyName = "Mock Study",
              studyType = "Yield Trial",
              studyDescription = "Mock description",
              locationName = "Mockville",
              trialDbId = "trial123",
              startDate = "2020-01-01T00:00:00Z",
              endDate = "2020-06-01T00:00:00Z",
              additionalInfo = list(programName = "Mock Program"),
              commonCropName = "wheat",
              experimentalDesign = list(description = "RCBD")
            )
          ))))
        } else {
          list(content = list(result = list(data = list())))
        }
      },
      post = function(endpoint, body) {
        if (endpoint == "search/studies") {
          list(content = list(result = list(
            data = list(
              list(
                studyDbId = "study1",
                studyName = "Mock Study",
                studyType = "Yield Trial",
                studyDescription = "Mock description",
                locationName = "Mockville",
                trialDbId = "trial123",
                startDate = "2020-01-01T00:00:00Z",
                endDate = "2020-06-01T00:00:00Z",
                additionalInfo = list(programName = "Mock Program"),
                commonCropName = "wheat",
                experimentalDesign = list(description = "RCBD")
              )
            )
          )))
        } else if (endpoint == "search/germplasm") {
          list(content = list(result = list(
            data = list(
              list(
                germplasmDbId = "G1",
                germplasmName = "Germ1",
                synonyms = list(list(synonym = "G1-alt"))
              )
            )
          )))
        } else {
          list(content = list(result = list(data = NULL)))
        }
      }
    ),
    class = "MockBrAPI"
  )
}
