#' Convert a BrAPI study result into a single-row data frame
#'
#' Takes a single study object from a BrAPI `studies` response and converts it
#' into a one-row \code{data.frame} with key metadata fields. This is a helper
#' used by functions that assemble trial metadata tables.
#'
#' @param tr A list representing a single trial result from a BrAPI
#'   \code{/studies} endpoint, typically \code{brapiConnection$get("studies/ID")$content$result}.
#'
#' @return A one-row \code{data.frame} with columns such as
#'   \code{studyDbId}, \code{studyName}, \code{studyType},
#'   \code{studyDescription}, \code{locationName}, \code{trialDbID},
#'   \code{startDate}, \code{endDate}, \code{programName},
#'   \code{commonCropName}, and \code{experimentalDesign}.
#'
#' @details This function assumes the infix operator \code{\%||\%} is available
#'   in the calling environment to replace \code{NULL} with \code{NA}.
#'
#' @examples
#' # Create mock trial result
#' tr <- list(
#'   studyDbId = "12345",
#'   studyName = "Mock Trial",
#'   studyType = "Yield Trial",
#'   studyDescription = "Example",
#'   locationName = "Loc1",
#'   trialDbId = "trial123",
#'   startDate = "2020-01-01T00:00:00Z",
#'   endDate = "2020-02-01T00:00:00Z",
#'   additionalInfo = list(programName = "Program A"),
#'   commonCropName = "wheat",
#'   experimentalDesign = list(description = "RCBD")
#' )
#'
#' makeRowFromTrialResult(tr)
#'
makeRowFromTrialResult <- function(tr){
  return(
    tibble::tibble(
      studyDbId = tr$studyDbId %||% NA,
      studyName = tr$studyName %||% NA,
      studyType = tr$studyType %||% NA,
      studyDescription = tr$studyDescription %||% NA,
      locationName = tr$locationName %||% NA,
      trialDbID = tr$trialDbId %||% NA,
      startDate = tr$startDate %||% NA,
      endDate = tr$endDate %||% NA,
      programName = tr$additionalInfo$programName %||% NA,
      commonCropName = tr$commonCropName %||% NA,
      experimentalDesign = tr$experimentalDesign$description,
    )
  )
}

#' Retrieve metadata for a set of trials by study IDs
#'
#' Given a vector of BrAPI study IDs, query the \code{/studies/{studyDbId}}
#' endpoint for each and compile a tidy data frame of trial metadata.
#'
#' @param study_id_vec A character vector of BrAPI study IDs (studyDbId values)
#'   to query.
#' @param brapiConnection A BrAPI connection object, typically created by
#'   \code{BrAPI::createBrAPIConnection()},
#'   with \code{$get()} method available.
#'
#' @return A tibble-like data frame with one row per trial and cleaned column
#'   names (via \code{janitor::clean_names()}). Date columns \code{start_date}
#'   and \code{end_date} are converted to \code{POSIXct} in UTC.
#'
#' @importFrom dplyr bind_rows mutate
#' @importFrom janitor clean_names
#'
#' @examples
#' brapiConn <- BrAPI::createBrAPIConnection("wheat-sandbox.triticeaetoolbox.org", is_breedbase = TRUE)
#'
#' # Retrieve mock metadata for two trials
#' df <- getTrialMetaDataFromStudyVec(c("8128", "9421"), brapiConn)
#' df
#'
#' @export
getTrialMetaDataFromTrialVec <- function(study_id_vec, brapiConnection){

  getSingleStudy <- function(id){
    return(brapiConnection$get(paste0("studies/", id))$content$result)
  }
  trials_list <- lapply(study_id_vec, getSingleStudy)
  trials_df <- trials_list |>
    lapply(makeRowFromTrialResult) |>
    dplyr::bind_rows() |>
    dplyr::mutate(
      startDate = as.POSIXct(
        startDate, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"
      ),
      endDate = as.POSIXct(
        endDate, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"
      )
    ) |>
    janitor::clean_names()

  return(trials_df)
}

#' Retrieve metadata on all trials for a given crop
#'
#' Queries the BrAPI \code{/search/studies} endpoint for all studies matching
#' a given common crop name, handles polling if needed, and compiles the
#' results into a trial metadata data frame.
#'
#' @param brapiConnection A BrAPI connection object, typically created by
#'   \code{BrAPI::createBrAPIConnection()},
#'   with \code{$get()} and \code{$post()} methods available.
#' @param cropName A character string giving the BrAPI \code{commonCropName}
#'   to search for (e.g. \code{"wheat"}).
#'
#' @return A tibble-like data frame with one row per trial, containing
#'   standardized trial metadata with cleaned column names and \code{POSIXct}
#'   \code{start_date} and \code{end_date} columns.
#'
#' @importFrom dplyr bind_rows mutate
#' @importFrom janitor clean_names
#'
#' @examples
#' brapiConn <- BrAPI::createBrAPIConnection("wheat-sandbox.triticeaetoolbox.org", is_breedbase = TRUE)
#'
#' # Retrieve mock trial metadata for "wheat"
#' all_trials <- getAllTrialMetaData(brapiConn, "Wheat")
#' all_trials
#'
#' @export
getAllTrialMetaData <- function(brapiConnection, cropName){

  ## pull list of all trials from T3
  trials_search <- brapiConnection$post(
    "search/studies",
    body = list(commonCropNames = cropName)
  )

  # Check if immediate data is available
  if (!is.null(trials_search$content$result$data)){
    trials_result <- trials_search$content$result$data
  } else{
    # Otherwise, get the searchResultsDbId and poll the results
    search_id <- trials_search$content$result$searchResultsDbId

    trials_result_response <- brapiConnection$get(
      paste0("search/studies/", search_id),
      pageSize = 10000
    )

    trials_result <- trials_result_response$content$result$data
  }

  # Compile the BrAPI results into a data frame
  trials_df <- trials_result |>
    lapply(makeRowFromTrialResult) |>
    dplyr::bind_rows() |>
    dplyr::mutate(
      startDate = as.POSIXct(
        startDate, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"
      ),
      endDate = as.POSIXct(
        endDate, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"
      )
    ) |>
    janitor::clean_names()

  return(trials_df)
}

#' Retrieve what traits were measured for a set of trials by study IDs
#'
#' Given a vector of BrAPI study IDs, use the wizard function of a Breedbase
#' connection to compile a vector of all traits measured in at least one trial
#'
#' @param study_id_vec A character vector of BrAPI study IDs (studyDbId values)
#'   to query.
#' @param brapiConnection A BrAPI connection object, typically created by
#'   \code{BrAPI::createBrAPIConnection()},
#'   with \code{$get()} method available.
#' @param namesOrIds A string. If "names" return the names of the traits else
#' return the trait DB IDs.
#'
#' @return A vector of either trait names or trait DB IDs.
#'
#' @importFrom dplyr if_else
#'
#' @examples
#' brapiConn <- BrAPI::createBrAPIConnection("wheat-sandbox.triticeaetoolbox.org", is_breedbase = TRUE)
#'
#' traits <- getTraitsFromTrialVec(c("8128", "9421"), brapiConn)
#' traits
#'
#' @export
getTraitsFromTrialVec <- function(study_db_id, brapiConnection,
                                  namesOrIds="names"){
  traitList <- brapiConnection$wizard("traits", filter=list(trials=study_db_id))
  traitList <- traitList$content[[1]]
  namesOrIds <- dplyr::if_else(namesOrIds == "names", 2, 1)
  traits <- sapply(traitList, function(tl) return(tl[[namesOrIds]]))
  return(traits)
}
