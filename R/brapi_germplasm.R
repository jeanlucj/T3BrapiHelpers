#' Convert a BrAPI germplasm result into a single-row data frame
#'
#' Takes a single germplasm object from a BrAPI germplasm search and converts
#' it into a one-row \code{data.frame} with key identifiers and synonym
#' metadata.
#'
#' @param gr A list representing a single germplasm result from a BrAPI
#'   germplasm search.
#' @param study_id The studyDbId (character or numeric) associated with this
#'   germplasm in the current context.
#'
#' @return A one-row \code{data.frame} with columns \code{studyDbId},
#'   \code{germplasmDbId}, \code{germplasmName}, and \code{synonym}.
#'
#' @details If synonyms are present, only the first synonym is extracted.
#'
#' @examples
#' gr <- list(
#'   germplasmDbId = "G1",
#'   germplasmName = "Germ1",
#'   synonyms = list(list(synonym = "G1-alt"))
#' )
#'
#' makeRowFromGermResult(gr, study_id = "study1")
#'
makeRowFromGermResult <- function(gr, study_id){
  return(
    data.frame(
      studyDbId = study_id,
      germplasmDbId = gr$germplasmDbId %||% NA,
      germplasmName = gr$germplasmName %||% NA,
      synonym = if (!is.null(gr$synonyms) && length(gr$synonyms) > 0){
        gr$synonyms[[1]]$synonym %||% NA
      } else{
        NA
      },
      stringsAsFactors = FALSE
    )
  )
}

#' Get germplasm metadata for a single study via BrAPI
#'
#' Queries the BrAPI \code{/search/germplasm} endpoint for a given study and
#' returns a data frame of germplasm accessions associated with that study.
#' Polling is handled if the search is asynchronous.
#'
#' @param study_id A single studyDbId to query germplasm for.
#' @param brapiConnection A BrAPI connection object, typically from
#'   \code{BrAPI::createBrAPIConnection()},
#'   with \code{$post()} and \code{$get()} methods.
#' @param verbose Logical; if \code{TRUE}, print messages about the retrieval
#'   process (direct result vs polling, empty results, etc.).
#'
#' @return A data frame of germplasm metadata for the given study, with one
#'   row per germplasm. Columns include \code{studyDbId}, \code{germplasmDbId},
#'   \code{germplasmName}, and \code{synonym}. If no result is found, this
#'   function may return \code{NULL} or an empty data frame, depending on how
#'   you choose to handle that case.
#'
#' @importFrom dplyr bind_rows
#'
#' @examples
#' mock <- mock_brapi_connection()
#'
#' germ_df <- getGermplasmSingleStudy("study1", mock)
#' germ_df
#'
#' @export
getGermplasmSingleStudy <- function(study_id, brapiConnection, verbose = TRUE){
  germ_search <- brapiConnection$post(
    "search/germplasm",
    body = list(studyDbIds = study_id)
  )

  # Check if polling is needed
  result_data <- germ_search$content$result$data

  if (!is.null(result_data)) {
    if (verbose) message(" → Got direct result (no polling)")
    germ_result <- result_data
  } else if (!is.null(germ_search$content$result$searchResultsDbId)) {
    if (verbose) message(" → Polling for result")

    germ_search_id <- germ_search$content$result$searchResultsDbId
    page <- 0
    pageSize <- 1000
    all_germ <- list()

    repeat {
      germ_response <- brapiConnection$get(
        paste0("search/germplasm/", germ_search_id),
        page = page,
        pageSize = pageSize
      )

      this_page <- germ_response$content$result$data

      if (length(this_page) == 0) break

      all_germ <- c(all_germ, this_page)
      page <- page + 1
    }

    germ_result <- all_germ
  } else {
    if (verbose) message(" → No result found for study: ", study_id)
    # Consider returning NULL or an empty data frame here
    return(NULL)
  }

  # Build data frame
  if (length(germ_result) > 0) {
    germ_df <- germ_result |>
      lapply(makeRowFromGermResult, study_id = study_id) |>
      dplyr::bind_rows()
  } else {
    if (verbose) message(" → Germplasm list was empty for study: ", study_id)
    germ_df <- NULL
  }

  return(germ_df)
}

#' Get germplasm metadata for multiple studies
#'
#' Wrapper around \code{\link{getGermplasmSingleStudy}} to retrieve and combine
#' germplasm metadata for a vector of study IDs.
#'
#' @param study_id_vec A character vector of studyDbIds to query.
#' @param brapiConnection A BrAPI connection object as used in
#'   \code{getGermplasmSingleStudy()}.
#' @param verbose Logical; passed on to \code{getGermplasmSingleStudy()} to
#'   control logging.
#'
#' @return A data frame obtained by row-binding the results of each study, with
#'   one row per germplasm per study.
#'
#' @importFrom dplyr bind_rows
#'
#' @examples
#' mock <- mock_brapi_connection()
#'
#' all_germ <- getGermplasmFromStudies(c("study1", "study2"), mock)
#' all_germ
#'
#' @export
getGermplasmFromStudies <- function(study_id_vec, brapiConnection,
                                    verbose = TRUE){

  germMeta_list <- lapply(
    study_id_vec,
    getGermplasmSingleStudy,
    brapiConnection = brapiConnection,
    verbose = verbose
  )

  return(dplyr::bind_rows(germMeta_list))
}

#' Retry an Expression Multiple Times on Error
#'
#' `retryQuery()` repeatedly evaluates an expression that may fail (e.g.,
#' network I/O, timeouts, or API calls). If the expression throws an error, the
#' function waits a specified number of seconds and tries again, up to a maximum
#' number of attempts.
#'
#' This helper is intended for **internal package use only** and is especially
#' useful for wrapping fragile operations such as BrAPI queries, `httr` requests,
#' or file I/O when intermittent failures are likely.
#'
#' The function returns the value of the expression as soon as it succeeds
#' (i.e., does not throw an error). If all attempts fail, `NULL` is returned
#' invisibly after issuing a final message.
#'
#' @param query A quoted R expression (usually wrapped with `quote()`).
#' @param max_tries Integer. Maximum number of attempts before giving up.
#' @param wait Numeric. Number of seconds to pause between attempts.
#' @param silent Logical. Whether to suppress error messages from each failed
#'   attempt. Default `TRUE`.
#'
#' @return The value of `query` if successful; otherwise `NULL` after exhausting
#'   all attempts.
#'
#' @examples
#' # A failing expression that will succeed on the 3rd try
#' i <- 0
#' result <- retryQuery(
#'   quote({
#'     i <<- i + 1
#'     if (i < 3) stop("Temporary failure")
#'     "Success!"
#'   }),
#'   max_tries = 5,
#'   wait = 0.1
#' )
#' result
#'
#' @keywords internal
retryQuery <- function(query, max_tries = 10, wait = 3, silent = TRUE) {
  for (i in seq_len(max_tries)) {
    out <- try(eval(query), silent = silent)

    if (!inherits(out, "try-error")) {
      return(out)
    }

    message("Attempt ", i, " failed… waiting ", wait, " sec before retry.")
    Sys.sleep(wait)
  }

  message("All ", max_tries, " attempts failed.")
  invisible(NULL)
}

#' Get genotyping protocol metadata for a single germplasm
#'
#' Queries the T3 AJAX interface to determine which genotyping
#' protocols have been used for a specific germplasm within a study.
#'
#' @param germ_id The germplasmDbId for the accession of interest.
#' @param study_id The studyDbId providing the study context for the germplasm.
#' @param t3url Base URL for the T3 (or similar) instance, e.g.
#'   \code{"https://wheat.triticeaetoolbox.org"}.
#'
#' @return A tibble with a single row containing
#'   \code{studyDbId}, \code{germplasmDbId}, \code{genoProtocolDbId},
#'   and \code{genoProtocolName}. The genotyping protocol columns are list
#'   columns, potentially containing multiple protocol IDs/names.
#'
#' @importFrom httr POST content timeout
#' @importFrom tibble tibble
#'
#' @export
getGenoProtocolSingleGerm <- function(germ_id, study_id, t3url){

  # API call
  response <- retryQuery(
    quote(httr::POST(
      paste0(t3url, "/ajax/breeder/search"),
      body = list(
        "categories[]" = "accessions",
        "data[0][]" = germ_id,
        "categories[]" = "genotyping_protocols"
      ),
      encode = "multipart",
      httr::timeout(3000)
    )),
    max_tries = 10,
    wait = 3
  )

  # Extract the list of protocols
  protocols <- httr::content(response)$list

  # Get ALL protocols used to genotype the germplasm
  # The |> unlist() |> list() maneuver turns a list of several into a list
  # with one vector in it.
  if (length(protocols) > 0) {
    protocol_id <- lapply(protocols, function(pl) as.character(pl[[1]])) |>
      unlist() |> list()
    protocol_name <- lapply(protocols, function(pl) as.character(pl[[2]])) |>
      unlist() |> list()
  } else {
    protocol_id <- list(NA)
    protocol_name <- list(NA)
  }

  this_row <- tibble::tibble(
    studyDbId = study_id,
    germplasmDbId = germ_id,
    genoProtocolDbId = protocol_id,
    genoProtocolName = protocol_name
  )

  return(this_row)
}

#' Determine genotyping protocol metadata for a set of accessions
#'
#' For each germplasm in a data frame of germplasm metadata, query the T3
#' AJAX interface to determine which genotyping protocols were used, and
#' return a combined tibble.
#'
#' @param all_germ A data frame or tibble of germplasm metadata that must
#'   contain at least the columns \code{studyDbId}, \code{germplasmDbId},
#'   \code{germplasmName}, and \code{synonym}.
#' @param t3url Base URL for the T3 (or similar) instance, as in
#'   \code{getGenoProtocolSingleGerm()}.
#' @param verbose Logical; if \code{TRUE}, display purrr progress bar.
#'
#' @return A tibble with one row per germplasm, including genotyping protocol
#'   IDs and names as list columns.
#'
#' @importFrom purrr pmap
#' @importFrom dplyr bind_rows
#'
#' @export
getGermplasmGenotypeMetaData <- function(all_germ, t3url, verbose=F) {

  getForOneRow <- function(studyDbId, germplasmDbId, germplasmName, synonym){
    return(getGenoProtocolSingleGerm(germplasmDbId, studyDbId, t3url))
  }
  return(all_germ |> purrr::pmap(getForOneRow, .progress=verbose) |>
           dplyr::bind_rows())
}
