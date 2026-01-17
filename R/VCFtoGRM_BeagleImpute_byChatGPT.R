#' Compute a VanRaden I GRM from a VCF, with optional Beagle imputation
#'
#' Computes the additive genomic relationship matrix (GRM) using VanRaden I:
#' \deqn{G = ZZ' / (2 * \sum p_j (1-p_j))}
#' where Z is the centered allele dosage matrix (alt allele dosage minus 2p).
#'
#' Missing genotypes can be handled in two ways:
#' \itemize{
#'   \item \code{impute = "beagle"}: run Beagle to phase and impute sporadically missing
#'         genotypes (LD-aware). Beagle is run externally via Java.  [oai_citation:2_UW Faculty](https://faculty.washington.edu/browning/beagle/beagle.html)
#'   \item \code{impute = "mean"}: impute missing genotypes to 2p (so centered value is 0).
#' }
#'
#' @param vcf_file Path to input VCF (.vcf or .vcf.gz).
#' @param out_rds Path to write the GRM as an .rds file (matrix with dimnames).
#' @param impute One of \code{"beagle"} or \code{"mean"}.
#' @param beagle_jar Path to Beagle jar file (required if \code{impute="beagle"}).
#'   Beagle 5.5 is distributed as a jar and requires Java 8.  [oai_citation:3_UW Faculty](https://faculty.washington.edu/browning/beagle/beagle.html)
#' @param java Path to Java executable (default \code{"java"}).
#' @param beagle_mem_gb Memory cap passed to Java as \code{-Xmx<GB>g}.
#' @param beagle_out_prefix Output prefix for Beagle output files. If NULL, uses a temp prefix.
#' @param beagle_ref Optional reference panel file for Beagle (\code{ref=} argument).
#' @param beagle_map Optional genetic map file for Beagle (\code{map=} argument).
#' @param beagle_ne Optional effective population size (\code{ne=} argument).
#' @param beagle_extra_args Named list of extra Beagle args, e.g. \code{list(window=40, iterations=10)}.
#' @param method_vcf2gds Passed to \code{SNPRelate::snpgdsVCF2GDS}. Default uses
#'   \code{"biallelic.only"} for biallelic SNPs.
#' @param block_size Number of SNPs per block when streaming genotypes from GDS.
#' @param verbose Logical; print progress messages.
#'
#' @return Invisibly returns the GRM matrix (also saved to \code{out_rds}).
#'
vcf_to_grm_impute_vanraden1 <- function(
    vcf_file,
    out_rds,
    impute = c("beagle", "mean"),
    beagle_jar = NULL,
    java = "java",
    beagle_mem_gb = 8,
    beagle_out_prefix = NULL,
    beagle_ref = NULL,
    beagle_map = NULL,
    beagle_ne = NULL,
    beagle_extra_args = list(),
    method_vcf2gds = "biallelic.only",
    block_size = 5000,
    verbose = TRUE
) {
  impute <- match.arg(impute)

  # ---- Optionally run Beagle ----
  vcf_used <- vcf_file

  if (impute == "beagle") {
    if (is.null(beagle_jar) || !file.exists(beagle_jar)) {
      stop("impute='beagle' requires beagle_jar to be an existing file.")
    }

    if (is.null(beagle_out_prefix)) {
      beagle_out_prefix <- file.path(tempdir(), paste0("beagle_imputed_", as.integer(Sys.time())))
    }
    if (isTRUE(verbose)) message("Running Beagle imputation...")

    # Build beagle args: gt=, out=, plus optional ref/map/ne and extras
    beagle_args <- c(
      paste0("gt=", normalizePath(vcf_file)),
      paste0("out=", normalizePath(beagle_out_prefix, winslash = "/"))
    )
    if (!is.null(beagle_ref)) beagle_args <- c(beagle_args, paste0("ref=", normalizePath(beagle_ref)))
    if (!is.null(beagle_map)) beagle_args <- c(beagle_args, paste0("map=", normalizePath(beagle_map)))
    if (!is.null(beagle_ne))  beagle_args <- c(beagle_args, paste0("ne=",  as.integer(beagle_ne)))

    if (length(beagle_extra_args) > 0) {
      extra <- mapply(function(k, v) paste0(k, "=", v),
                      names(beagle_extra_args), beagle_extra_args,
                      SIMPLIFY = TRUE, USE.NAMES = FALSE)
      beagle_args <- c(beagle_args, extra)
    }

    # java -Xmx<GB>g -jar beagle.jar <args>
    cmd_args <- c(paste0("-Xmx", as.integer(beagle_mem_gb), "g"),
                  "-jar", normalizePath(beagle_jar),
                  beagle_args)

    res <- suppressWarnings(system2(java, args = cmd_args, stdout = TRUE, stderr = TRUE))
    # Beagle produces: <out>.vcf.gz (and <out>.log)
    vcf_beagle <- paste0(beagle_out_prefix, ".vcf.gz")

    if (!file.exists(vcf_beagle)) {
      msg <- paste(res, collapse = "\n")
      stop("Beagle did not produce expected output VCF: ", vcf_beagle, "\n--- Beagle output ---\n", msg)
    }
    vcf_used <- vcf_beagle
    if (isTRUE(verbose)) message("Beagle output VCF: ", vcf_used)
  }

  # ---- Convert VCF to GDS ----
  if (isTRUE(verbose)) message("Converting VCF to GDS...")
  gds_file <- file.path(tempdir(), paste0("tmp_", basename(vcf_used), ".gds"))

  if (file.exists(gds_file)) unlink(gds_file)

  SNPRelate::snpgdsVCF2GDS(
    vcf.fn = vcf_used,
    out.fn = gds_file,
    method = method_vcf2gds,
    ignore.chr.prefix = "chr",
    verbose = FALSE
  )

  gds <- SNPRelate::snpgdsOpen(gds_file, readonly = TRUE)
  on.exit({
    try(SNPRelate::snpgdsClose(gds), silent = TRUE)
    try(unlink(gds_file), silent = TRUE)
  }, add = TRUE)

  samp_ids <- gdsfmt::read.gdsn(gdsfmt::index.gdsn(gds, "sample.id"))
  snp_ids  <- gdsfmt::read.gdsn(gdsfmt::index.gdsn(gds, "snp.id"))

  n <- length(samp_ids)
  m <- length(snp_ids)

  if (isTRUE(verbose)) message("Samples: ", n, "  SNPs: ", m)

  # ---- Stream genotypes and build GRM ----
  # SNPRelate stores genotype as dosage of reference allele under some methods; we
  # compute alt allele dosage as 2 - ref_dosage for biallelic SNPs.
  # We'll use snpgdsGetGeno (returns samples x snps).
  G_num <- matrix(0, nrow = n, ncol = n, dimnames = list(samp_ids, samp_ids))
  denom_sum <- 0

  blocks <- split(seq_len(m), ceiling(seq_len(m) / block_size))

  for (b in seq_along(blocks)) {
    idx <- blocks[[b]]
    if (isTRUE(verbose)) message("Processing SNP block ", b, "/", length(blocks), " (", length(idx), " SNPs)")

    geno_ref <- SNPRelate::snpgdsGetGeno(gds, snp.id = snp_ids[idx], with.id = FALSE) # matrix n x |idx|
    # Convert to ALT dosage (0/1/2), assuming diploid biallelic calls:
    x_alt <- 2 - geno_ref

    # allele freq p_alt (mean alt dosage / 2), ignoring missing
    p_alt <- colMeans(x_alt, na.rm = TRUE) / 2

    # denominator contribution: 2 * sum p(1-p)
    denom_sum <- denom_sum + sum(2 * p_alt * (1 - p_alt), na.rm = TRUE)

    # Centered matrix Z = x_alt - 2p
    Z <- sweep(x_alt, 2, 2 * p_alt, FUN = "-")

    if (impute == "mean") {
      # mean-impute -> centered missing becomes 0
      Z[is.na(Z)] <- 0
    } else {
      # after Beagle, missing should be rare; still protect GRM:
      if (anyNA(Z)) {
        Z[is.na(Z)] <- 0
      }
    }

    G_num <- G_num + (Z %*% t(Z))
  }

  if (denom_sum <= 0) stop("Denominator is non-positive; check SNP filtering / allele frequencies.")

  GRM <- G_num / denom_sum

  if (isTRUE(verbose)) message("Saving GRM to: ", out_rds)
  saveRDS(GRM, out_rds)

  invisible(GRM)
}
