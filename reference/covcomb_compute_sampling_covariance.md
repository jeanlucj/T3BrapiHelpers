# Compute the sampling covariance matrix for the combined covariance matrix

Compute the sampling covariance matrix for the combined covariance
matrix

## Usage

``` r
covcomb_compute_sampling_covariance(
  psi,
  partial_covs,
  var_indices,
  degrees_freedom
)
```

## Arguments

- psi:

  Combined covariance matrix

- partial_covs:

  List of partial covariance matrices

- var_indices:

  List of variable indices for each partial covariance matrix

- degrees_freedom:

  Degrees of freedom for each partial covariance matrix

## Value

Sampling covariance matrix for the combined covariance matrix
