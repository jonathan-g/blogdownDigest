# blogdownDigest

[![lifecycle](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
[![CRAN status](https://www.r-pkg.org/badges/version/blogdownDigest)](https://cran.r-project.org/package=blogdownDigest)
[![Travis build status](https://travis-ci.org/jonathan-g/blogdownDigest.svg?branch=master)](https://travis-ci.org/jonathan-g/blogdownDigest)

An extension of the blogdown package that uses hash digests of
files instead of modification times to determine which RMarkdown source 
files have changed and need to be rebuilt.

## Installation

You can install blogdownDigest from [GitHub](https://github.com/jonathan-g/blogdownDigest) with:

``` r
library(remotes)
install_github("jonathan-g/blogdownDiges")
```

<!--You can install the released version of blogdownDigest from [CRAN](https://CRAN.R-project.org) with:


``` r
install.packages("blogdownDigest")
```
-->

## Example

This is a basic example which shows you how to solve a common problem:

``` r
update_site()
```

