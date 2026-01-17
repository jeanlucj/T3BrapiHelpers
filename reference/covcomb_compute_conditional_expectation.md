# Compute conditional expectation for the E-step of the EM algorithm

Compute conditional expectation for the E-step of the EM algorithm

## Usage

``` r
covcomb_compute_conditional_expectation(ya, psi, obs_idx, missing_idx)
```

## Arguments

- ya:

  Observed partial covariance matrix

- psi:

  Current estimate of the combined covariance matrix

- obs_idx:

  Indices of observed variables (0-based)

- missing_idx:

  Indices of missing variables (0-based)

## Value

Conditional expectation of the complete covariance matrix
