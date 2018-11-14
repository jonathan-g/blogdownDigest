#' blogdownDiges: A package that extends blogdown to use hash digests to track
#' changed source files.
#'
#' The blogdownDigest pacakge extends blogdown to use hash digests to track
#' changed source files. This works more reliably than using file modification
#' timestamps to figure out which files need to be rebuilt.
#'
#' @docType package
#' @name blogdownDigest-package
#'
#' @section License:
#'
#'  The \pkg{kayadata} package is open source licensed under the
#'  MIT License.
#'
#' @section Bug reports:
#' \itemize{
#'  \item kayadata issue tracker (\url{https://github.com/jonathan-g/kayadata/issues})
#' }
#'
#'
#' @import blogdown
#' @importFrom magrittr %>% %$%
#' @importFrom dplyr filter mutate select left_join bind_rows
#' @importFrom tidyr replace_na
#' @importFrom purrr map map2 map2_chr keep discard
#' @importFrom stringr str_detect str_replace fixed
#' @importFrom readr read_rds write_rds
#' @importFrom tibble tibble
#'
NULL

utils::globalVariables(c("rebuild", "dest", "alg", "cur_dgst_lst",
                         "digest", "dest_digest", "cur_digest",
                         "cur_dest_digest", "quiet", "dgst", "alg"))