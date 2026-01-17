# Written by ChatGPT

suppressPackageStartupMessages({
  if (!requireNamespace("SNPRelate", quietly = TRUE)) {
    stop("Package 'SNPRelate' is required. Install with: install.packages('SNPRelate')")
  }
  if (!requireNamespace("gdsfmt", quietly = TRUE)) {
    stop("Package 'gdsfmt' is required. Install with: install.packages('gdsfmt')")
  }
})

#' Compute an additive genomic relationship matrix from a VCF using VanRaden I
#'
#' This function reads a diploid, biallelic SNP VCF (optionally gzipped),
#' converts it to GDS using \code{SNPRelate}, applies basic SNP filtering, and
#' computes the additive genomic relationship matrix (GRM) using the VanRaden I
#' estimator:
#'
#' \deqn{G = \frac{ZZ^\top}{2 \sum_j p_j (1-p_j)}}
#'
#' where \eqn{Z_{ij} = x_{ij} - 2p_j}, \eqn{x_{ij}} is the ALT allele dosage
#' (0,1,2), and \eqn{p_j} is the ALT allele frequency at marker \eqn{j}. Missing
#' genotypes are implicitly imputed to \eqn{2p_j} so their centered contribution
#' is zero (i.e., missing \eqn{Z_{ij}} is set to 0).
#'
#' The result is saved to \code{out_rds} via \code{saveRDS()} as a list with
#' fields including \code{ids} and \code{GRM}.
#'
#' @param vcf_file Character scalar. Path to an input VCF file (\code{.vcf} or
#'   \code{.vcf.gz}) containing diploid, biallelic SNP genotypes in \code{GT}.
#' @param out_rds Character scalar. Output \code{.rds} filename to write using
#'   \code{saveRDS()}.
#' @param gds_file Optional character scalar. Path to a temporary/permanent
#'   \code{.gds} file to create. If \code{NULL}, a filename is derived from
#'   \code{out_rds}.
#' @param callrate_threshold Numeric in (0,1]. SNP call rate threshold. SNPs
#'   with call rate below this are removed. Default 0.90.
#' @param maf_threshold Numeric in [0,0.5]. Minor allele frequency threshold.
#'   SNPs with MAF below this are removed. Default 0.01.
#' @param block_size Integer. Number of SNPs processed per block to reduce
#'   memory usage. Default 2000.
#' @param overwrite Logical. If \code{TRUE}, overwrite any existing
#'   \code{gds_file}. Default \code{TRUE}.
#' @param verbose Logical. Print progress messages. Default \code{TRUE}.
#'
#' @return Invisibly returns a list saved to \code{out_rds} containing:
#' \itemize{
#'   \item \code{ids}: sample IDs (row/col order of \code{GRM})
#'   \item \code{GRM}: additive genomic relationship matrix (VanRaden I)
#'   \item \code{denom}: denominator \eqn{2\sum p(1-p)} used for scaling
#'   \item \code{snps_used}: SNP IDs used after QC
#'   \item \code{qc}: list of QC thresholds used
#'   \item \code{gds_file}: path to the created GDS
#' }
#'
#' @keywords internal
vcf_to_grm_vanraden1 <- function(vcf_file,
                                 out_rds,
                                 gds_file = NULL,
                                 callrate_threshold = 0.90,
                                 maf_threshold = 0.01,
                                 block_size = 2000L,
                                 overwrite = TRUE,
                                 verbose = TRUE) {

  stopifnot(is.character(vcf_file), length(vcf_file) == 1)
  stopifnot(is.character(out_rds), length(out_rds) == 1)
  if (is.null(gds_file)) {
    gds_file <- sub("\\.rds$", "", out_rds, ignore.case = TRUE)
    if (identical(gds_file, out_rds)) out_rds <- paste0(out_rds, ".rds")
    gds_file <- paste0(gds_file, ".gds")
  }

  msg <- function(...) if (isTRUE(verbose)) message(...)

  # Convert VCF -> GDS
  msg("Converting VCF to GDS: ", vcf_file)
  if (overwrite && file.exists(gds_file)) unlink(gds_file)

  SNPRelate::snpgdsVCF2GDS(
    vcf.fn = vcf_file,
    out.fn = gds_file,
    method = "biallelic.only",
    ignore.chr.prefix = "chr",
    verbose = verbose
  )

  genofile <- SNPRelate::snpgdsOpen(gds_file, readonly = FALSE)
  on.exit(try(SNPRelate::snpgdsClose(genofile), silent = TRUE), add = TRUE)

  # SNP QC stats
  msg("Computing SNP call rate / allele frequency stats ...")
  snp_stats <- SNPRelate::snpgdsSNPRateFreq(genofile)

  # Determine ALT allele frequency.
  # NOTE: In SNPRelate, AlleleFreq is commonly the frequency of the first allele
  # (often REF).
  # We treat ALT freq as 1 - AlleleFreq.
  p_ref <- snp_stats$AlleleFreq
  p_alt <- 1 - p_ref

  callrate <- 1 - snp_stats$MissingRate
  maf <- pmin(p_alt, 1 - p_alt)

  keep <- (callrate >= callrate_threshold) &
    (maf >= maf_threshold) & (maf <= 0.5)

  snp_ids <- snp_stats$snp.id[keep]
  if (length(snp_ids) < 10) {
    stop(
      "Too few SNPs after filtering (n=", length(snp_ids), "). ",
      "Try lowering callrate_threshold / maf_threshold or check the VCF."
    )
  }

  msg(sprintf("Keeping %d SNPs after QC (callrate >= %.2f, MAF >= %.3f).",
              length(snp_ids), callrate_threshold, maf_threshold))

  # Samples
  sample_ids <- SNPRelate::read.gdsn(SNPRelate::index.gdsn(genofile, "sample.id"))
  n <- length(sample_ids)

  # Preallocate GRM accumulator
  G_sum <- matrix(0, nrow = n, ncol = n)
  denom <- 0

  # Work in blocks of SNPs
  snp_ids_split <- split(snp_ids, ceiling(seq_along(snp_ids) / as.integer(block_size)))

  msg("Computing VanRaden I GRM in ", length(snp_ids_split), " blocks ...")

  for (b in seq_along(snp_ids_split)) {
    block_snps <- snp_ids_split[[b]]

    # Get genotypes for block:
    # snpgdsGetGeno returns 0/1/2 dosage for the *first allele* stored in GDS
    # (often REF).
    # Convert to ALT dosage via: x_alt = 2 - x_ref
    geno_ref <- SNPRelate::snpgdsGetGeno(
      genofile,
      snp.id = block_snps,
      with.id = FALSE,
      snpfirstdim = TRUE,
      verbose = FALSE
    )

    # Pull matching p_alt for this block in the same order as block_snps
    idx <- match(block_snps, snp_stats$snp.id)
    p_alt_block <- p_alt[idx]

    # Convert to ALT dosage
    x_alt <- 2 - geno_ref

    # Center: Z = x_alt - 2 p_alt
    # Missing genotypes (NA) are imputed to 2 p_alt => centered value 0
    # We do that by setting Z[is.na] <- 0 after centering.
    Z <- sweep(x_alt, 1, 2 * p_alt_block, FUN = "-")
    Z[is.na(Z)] <- 0

    # Accumulate numerator: crossprod(Z) = t(Z) %*% Z  => (n x n)
    G_sum <- G_sum + crossprod(Z)

    # Accumulate denominator contribution for this block
    denom <- denom + 2 * sum(p_alt_block * (1 - p_alt_block))

    msg(sprintf("  Block %d/%d processed (%d SNPs).", b, length(snp_ids_split), length(block_snps)))
  }

  if (!is.finite(denom) || denom <= 0) {
    stop("Denominator 2*sum(p*(1-p)) is non-positive; check allele frequencies / filtering.")
  }

  GRM <- G_sum / denom
  dimnames(GRM) <- list(sample_ids, sample_ids)

  out <- list(
    ids = sample_ids,
    GRM = GRM,
    denom = denom,
    snps_used = snp_ids,
    qc = list(callrate_threshold = callrate_threshold, maf_threshold = maf_threshold, block_size = block_size),
    gds_file = gds_file,
    method = "VanRadenI (ALT dosage; missing -> mean-impute)"
  )

  msg("Saving GRM to: ", out_rds)
  saveRDS(out, file = out_rds)

  invisible(out)
}

# ---------------------------
# CLI wrapper (optional)
# ---------------------------
args <- commandArgs(trailingOnly = TRUE)
if (length(args) >= 2 && identical(sys.nframe(), 0L)) {
  vcf_file <- args[1]
  out_rds  <- args[2]

  # Optional args: callrate maf block_size
  callrate <- if (length(args) >= 3) as.numeric(args[3]) else 0.90
  maf      <- if (length(args) >= 4) as.numeric(args[4]) else 0.01
  block_sz <- if (length(args) >= 5) as.integer(args[5]) else 2000L

  vcf_to_grm_vanraden1(
    vcf_file = vcf_file,
    out_rds = out_rds,
    callrate_threshold = callrate,
    maf_threshold = maf,
    block_size = block_sz,
    overwrite = TRUE,
    verbose = TRUE
  )
}
