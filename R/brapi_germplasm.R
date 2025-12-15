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
#'   germplasmDbId = "123456",
#'   germplasmName = "Accession1",
#'   synonyms = list(list(synonym = "G1-alt"))
#' )
#'
#' makeRowFromGermResult(gr, study_id = "12345")
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

#' Get germplasm metadata for a single trial via BrAPI
#'
#' Queries the BrAPI \code{/search/germplasm} endpoint for a given trial and
#' returns a data frame of germplasm accessions associated with that trial
#'
#' @param study_id A single studyDbId to query germplasm for.
#' @param brapiConnection A BrAPI connection object, typically from
#'   \code{BrAPI::createBrAPIConnection()}, with a \code{$search()} method.
#' @param verbose Logical; if \code{TRUE}, print messages about the retrieval
#'   process.
#'
#' @return A data frame of germplasm metadata for the given trial, with one
#'   row per germplasm. Columns include \code{studyDbId}, \code{germplasmDbId},
#'   \code{germplasmName}, and \code{synonym}. If no result is found, not sure
#'   what happens.
#'
#' @importFrom dplyr bind_rows
#'
#' @examples
#' brapiConn <- BrAPI::createBrAPIConnection("wheat-sandbox.triticeaetoolbox.org", is_breedbase = TRUE)
#'
#' germ_df <- getGermplasmFromSingleTrial("8128", brapiConn)
#' germ_df
#'
#' @export
getGermplasmFromSingleTrial <- function(study_id, brapiConnection, verbose=F){

  get_fields_from_data <- function(data_list){
    if (verbose) cat("Retrieved metadata on", data_list$germplasmName, "\n")
    return(tibble(germplasmDbId=data_list$germplasmDbId,
                  germplasmName=data_list$germplasmName,
                  synonyms=data_list$synonyms |> unlist() |> list(),
                  pedigree=data_list$pedigree))
  }

  search_result <- brapiConnection$search("germplasm",
                                          body = list(studyDbIds = study_id))

  # Make a data.frame from the combined data
  return(lapply(search_result$combined_data, get_fields_from_data) |>
           dplyr::bind_rows())
}

#' Get germplasm metadata for multiple trials
#'
#' Wrapper around \code{\link{getGermplasmFromSingleTrial}} to retrieve and combine
#' germplasm metadata for a vector of trial IDs.
#'
#' @param study_id_vec A character vector of studyDbIds to query.
#' @param brapiConnection A BrAPI connection object as used in
#'   \code{getGermplasmFromSingleTrial()}.
#' @param verbose Logical; passed on to \code{getGermplasmFromSingleTrial()} to
#'   control logging. If FALSE display purrr progress bar
#'
#' @return A data frame obtained by row-binding the results of each trial, with
#'   one row per germplasm per trial
#'
#' @importFrom dplyr bind_rows
#'
#' @examples
#' brapiConn <- BrAPI::createBrAPIConnection("wheat-sandbox.triticeaetoolbox.org", is_breedbase = TRUE)
#'
#' all_germ <- getGermplasmFromTrialVec(c("8128", "9421"), brapiConn)
#' all_germ
#'
#' @export
getGermplasmFromTrialVec <- function(study_id_vec, brapiConnection, verbose=F){

  germMeta_list <- purrr::map(
    study_id_vec,
    getGermplasmFromSingleTrial,
    brapiConnection = brapiConnection,
    verbose = verbose,
    .progress = !verbose
  )

  return(dplyr::bind_rows(germMeta_list))
}

#' Retry a Function Multiple Times on Error
#'
#' `retryQuery()` repeatedly calls a user-supplied function that may throw an
#' error (e.g., due to network timeouts, temporary API failures, or file I/O
#' issues). If an error occurs, the function waits a specified number of seconds
#' and tries again, up to a user-defined maximum number of attempts.
#'
#' This wrapper is especially useful for BrAPI queries or `httr` requests that
#' intermittently fail but typically succeed on a subsequent attempt.
#'
#' The function supplied to `retry()` is evaluated in the environment where
#' `retry()` is called, so all local variables referenced inside the function are
#' automatically available. This is safer and more flexible than evaluating
#' quoted expressions.
#'
#' ## Behavior
#' * On the **first successful call**, the returned value is returned
#' * If all attempts fail, `NULL` is returned invisibly after a final message.
#' * Errors generated by failed attempts are suppressed when `silent = TRUE`.
#'
#' @param fun A function of zero arguments (typically an anonymous function)
#'   that encapsulates the operation to attempt.
#' @param max_tries Integer. Maximum number of attempts before giving up.
#'   Default is 10.
#' @param wait Numeric. Number of seconds to pause between attempts.
#'   Default is 3.
#' @param silent Logical. Whether to suppress error messages from failed
#'   attempts. Default is `TRUE`.
#'
#' @return The value returned by `fun()` if an attempt succeeds; otherwise
#'   `NULL` invisibly.
#'
#' @examples
#' # A function that fails twice, then succeeds
#' i <- 0
#' result <- retry(
#'   function() {
#'     i <<- i + 1
#'     if (i < 3) stop("Temporary failure")
#'     "Success!"
#'   },
#'   max_tries = 5,
#'   wait = 0.1
#' )
#' result
#'
#' # Example with an httr call (fake for illustration)
#' t3url <- "https://example.org"
#' path <- "/endpoint"
#'
#' fake_call <- function() {
#'   if (runif(1) < 0.7) stop("Simulated flaky network")
#'   paste("Called:", paste0(t3url, path))
#' }
#'
#' retryQuery(fake_call, max_tries = 5, wait = 0.2)
#'
#' @keywords internal
retryQuery <- function(fun, max_tries = 10, wait = 3, silent = TRUE) {
  for (i in seq_len(max_tries)) {
    out <- try(fun(), silent = silent)

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
#' Queries the T3 AJAX interface using the \code{$wizard()} method of a
#' brapiConnection to determine which genotyping protocols have been used for a
#' specific germplasm
#'
#' @param germ_id The germplasmDbId for the accession of interest.
#' @param brapiConnection A BrAPI connection object, typically from
#'   \code{BrAPI::createBrAPIConnection()}, with a \code{$wizard()} method.
#'
#' @return A tibble with a single row containing
#'   \code{germplasmDbId}, \code{genoProtocolDbId}, and \code{genoProtocolName}.
#'   The genotyping protocol columns are list columns, potentially containing
#'   multiple protocol IDs/names.
#'
#' @importFrom httr POST content timeout
#' @importFrom tibble tibble
#'
#' @examples
#' brapiConn <- BrAPI::createBrAPIConnection("wheat-sandbox.triticeaetoolbox.org", is_breedbase = TRUE)
#'
#' winner_geno_protocols <- getGenoProtocolFromGermVec("1284387", brapiConn)
#' winner_geno_protocols
#'
#' @export
getGenoProtocolFromSingleGerm <- function(germ_id, brapiConnection, verbose=F){

  if (verbose){
    cat("Getting genotyping protocols for germplasmDbId", germ_id, "\n")
  }

  protocols <- brapiConnection$wizard("genotyping_protocols",
                                      list(accessions=germ_id))
  protocols <- protocols$content$list

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
    germplasmDbId = germ_id,
    genoProtocolDbId = protocol_id,
    genoProtocolName = protocol_name
  )

  return(this_row)
}

#' Determine genotyping protocol metadata for a set of accessions
#'
#' Wrapper for getGenoProtocolFromSingleGerm.
#'
#' @param germ_id_vec A vector of germplasm DbIds.
#' @param brapiConnection A BrAPI connection object, typically from
#'   \code{BrAPI::createBrAPIConnection()}, with a \code{$wizard()} method.
#' @param verbose Logical; if \code{FALSE} (default), display purrr progress bar
#'   else print for each \code{germplasmDbId}
#'
#' @return A tibble with one row per germplasm, including genotyping protocol
#'   IDs and names as list columns.
#'
#' @importFrom purrr map
#' @importFrom dplyr bind_rows
#'
#' @examples
#' brapiConn <- BrAPI::createBrAPIConnection("wheat-sandbox.triticeaetoolbox.org", is_breedbase = TRUE)
#'
#' germ_geno_protocols <- getGenoProtocolFromGermVec(
#'   c("1284387", "1382716", "1415479"), brapiConn)
#' germ_geno_protocols
#'
#' @export
getGenoProtocolFromGermVec <- function(germ_id_vec, brapiConnection, verbose=F) {

  return(purrr::map(germ_id_vec,
                    getGenoProtocolFromSingleGerm,
                    brapiConnection=brapiConnection,
                    verbose=verbose,
                    .progress=!verbose) |>
           dplyr::bind_rows())
}
