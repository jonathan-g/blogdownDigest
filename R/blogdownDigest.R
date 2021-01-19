#' blogdownDigest: A package that extends blogdown to use hash digests to track
#' changed source files.
#'
#' The blogdownDigest package extends blogdown to use hash digests to track
#' changed source files. This works more reliably than using file modification
#' timestamps to figure out which files need to be rebuilt.
#'
#' @docType package
#' @name blogdownDigest-package
#'
#' @section License:
#'
#'  The \pkg{blogdownDigest} package is open source licensed under the
#'  MIT License.
#'
#' @section Bug reports:
#' \itemize{
#'  \item blogdownDigest issue tracker (\url{https://github.com/jonathan-g/blogdownDigest/issues})
#' }
#'
#'
#' @import blogdown
#' @importFrom magrittr %>% %$%
#' @importFrom dplyr filter mutate select left_join bind_rows .data
#' @importFrom tidyr replace_na
#' @importFrom purrr map map2 map_chr map2_chr keep discard
#' @importFrom stringr str_detect str_replace fixed str_to_lower
#' @importFrom readr read_rds write_rds
#' @importFrom tibble tibble
#' @importFrom digest digest
#'
NULL
