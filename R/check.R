#' Check which files need to be rebuilt
#'
#' \code{needs_rebuild} returns a vector of logicals indicating which files
#' need to be rebuilt, based on whether the file has changed.
#'
#' This function compares digests of current files to stored digests in order
#' to tell whether the source file needs to be rebuilt.
#' If the digests are not equal, then the file has changed. If a digest is
#' missing, then the source file is new or the output file has been deleted
#' and in either case, the source file needs to be rebuilt.
#'
#' @param current_digest A character vector containing digests of the
#' current source files (\code{.Rmd} or \code{.rmarkdown}`).
#' @param current_dest_digest A character vector containing digests of the
#' current destination (output) files (\code{.html}`).
#' \code{NA} for destination files that do not exist.
#' @param old_digest The stored digest for the source file from the last time
#' the site was built. \code{NA} if the source file did not exist at the time of the
#' last build.
#' @param old_dest_digest A character vector containing stored digests for the
#' destination files from the last time the site was built.
#' \code{NA} for destination files that did not exist after the last build.
#' @return A vector of logicals indicating whether the destination (output)
#' files are out of date relative to the source files.
#'
#' If a destination file is missing or if any of the digests don't match,
#' then the file needs to be rebuilt.
#' @seealso \code{\link{digests}}.
#' @keywords internal
needs_rebuild <- function(current_digest, current_dest_digest,
                          old_digest, old_dest_digest) {
  out_of_date <- current_digest != old_digest |
    current_dest_digest !=  old_dest_digest
  out_of_date <- replace_na(out_of_date, TRUE)
  out_of_date
}

#' Figure out which files need to be rebuilt
#'
#' \code{filter_needs_rebuild} returns a vector of files that need to be rebuilt.
#'
#' This function accepts a vector of source files and
#' returns a vector of files that need to be rebuilt because the source file is
#' new or has changed since the last time the site was built.
#'
#' @param files A character vector of paths to source files (e.g., \code{.Rmd}).
#' @return A character vector of files that need to be rebuilt.
#' @seealso \code{\link{get_current_digests}()}, \code{\link{digests}}.
#' @keywords internal
filter_needs_rebuild <- function(files) {
  base <- blogdown:::site_root()
  files <- files %>% normalizePath(winslash = "/") %>%  unique() %>% keep(file.exists)

  df <- get_current_digests(files)

  df$rebuild <- needs_rebuild(df$cur_digest, df$cur_dest_digest,
                              df$digest, df$dest_digest)
  df %>% filter(.data$rebuild) %$% file
}

#' Find Rmd Files that Need Rebuilding.
#'
#' @param dir A directory to start in.
#'
#' @return A list of out-of-date RMarkdown files.
#'
#' @export
files_to_rebuild <- function(dir = NULL) {
  old_wd <- getwd()
  setwd(blogdown:::site_root())
  on.exit(setwd(old_wd))
  if (is.null(dir)) {
    dir <- find_blog_content()
  }

  cd <- paste0(normalizePath(getwd(), winslash = "/"), "/")
  dir <- normalizePath(dir, winslash = "/")
  dir <- str_replace(dir, fixed(cd), "")
  # message("Dir = ", dir, ", cd = ", cd, ", d = ", d)

  files <- blogdown:::list_rmds(dir, TRUE) %>%
    filter_needs_rebuild() %>%
    normalizePath(winslash = "/") %>%
    str_replace(fixed(cd), "")
  files
}
