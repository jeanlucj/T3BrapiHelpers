# Compute the observed data log-likelihood

Compute the observed data log-likelihood

## Usage

``` r
covcomb_compute_log_likelihood(psi, partial_covs, var_indices, degrees_freedom)
```

## Arguments

- psi:

  Current estimate of the combined covariance matrix

- partial_covs:

  List of partial covariance matrices

- var_indices:

  List of variable indices for each partial covariance matrix

- degrees_freedom:

  Degrees of freedom for each partial covariance matrix

## Value

The observed data log-likelihood
