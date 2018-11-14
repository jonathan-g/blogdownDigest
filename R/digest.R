#' Calculate the file digest if the file exists
#'
#' \code{digest_if_file_exists} returns a character vector with the hashed digest
#' of the file, or \code{NA} if the file does not exist.
#'
#' @param file A string containing the path to a file.
#' @param alg A string containing the name of the digest algorithm to use.
#' Set the algorithm with `options(blogdown.digest = <algorithm>)`.
#' If no option was set, use crc32.
#' @return A string: if the file exists return the digest. Otherwise, return
#' \code{NA}.
#' @seealso \code{\link{digest}} for details about available algorithms.
#' @keywords internal
digest_if_exists = function(file, alg = NA) {
  if (file.exists(file)) {
    if (is.na(alg)) {
      alg = get_digest_algorithm()
    }
    dgst = digest::digest(file, file = TRUE, algo = alg)
  } else {
    dgst = as.character(NA)
    alg = as.character(NA)
  }
  c(digest = dgst, alg = alg)
}

#' Create a data frame with stored digests and digests of current files
#'
#' \code{get_current_digests} returns a data frame with a row for every file
#' and columns for stored and current digests of source and output files.
#'
#' This function accepts a vector of source files and
#' returns a data frame with a row for each file and columns for the
#' stored digests and the digests of current source and output files.
#'
#' @param files A character vector of paths to source files (e.g., \code{.Rmd}).
#' @return A a data frame with a row for every file and columns:
#' \describe{
#' \item{\code{file}}{The source file name.}
#' \item{\code{dest}}{The output file name.}
#' \item{\code{alg}}{The digest algorithm.}
#' \item{\code{digest}}{The stored digest for the source file.}
#' \item{\code{dest_digest}}{The stored digest for the output file.}
#' \item{\code{cur_digest}}{The digest for the current source file.}
#' \item{\code{cur_dest_digest}}{The digest for the current output file.}
#' }
#'
#' Digests for missing files are set to \code{NA}.
#' @seealso \code{\link{files_to_rebuild}()},
#' \code{\link{digest_if_exists}()}, \code{\link{digests}}.
#' @keywords internal
get_current_digests = function(files) {
  base = blogdown:::site_root()
  files = files %>% normalizePath() %>% unique() %>% keep(file.exists)
  df = tibble(file = files, dest = blogdown:::output_file(files))

  digest_file = file.path(base, "digests.Rds")

  if (file.exists(digest_file)) {
    digests = read_rds(digest_file) %>%
      mutate(file = str_replace(file, "^~", base)) %>%
      # Don't store the name of the output file because we're going to
      # merge digest with df by source file path, and df already has a dest
      # column.
      select(-dest)

    # left join: we only want to check digests for the specified files.
    df = left_join(df, digests, by = "file")
  } else {
    # If there isn't a digest file, then the site has not been updated
    # previously, so we store NA's and build the whole site.
    df <- df %>% mutate(
      digest = as.character(NA),
      dest_digest = as.character(NA),
      alg = as.character(NA))
  }

  df = df %>%
    mutate(cur_dgst_lst = map2(file, alg, ~digest_if_exists(.x, .y)),
           alg = map_chr(cur_dgst_lst, ~.x['alg']),
           cur_digest = map_chr(cur_dgst_lst, ~.x['digest']),
           cur_dest_digest = map2_chr(dest, alg,
                                      ~digest_if_exists(.x, .y)['digest'])) %>%
    select(-cur_dgst_lst)

  # Organize columns in an aesthetically pleasing order.
  df = df %>% select(file, dest, alg, digest, dest_digest,
                     cur_digest, cur_dest_digest)
  invisible(df)
}

#' Generates and stores digests for all source and output files.
#'
#' \code{update_rmd_digests} calculates hashed digests for a list of source files
#' and their corresponding output files and stores them in a file.
#'
#' Generates new hashed digests for both source and destination (output) files
#' and save the digests to a file "\code{digests.Rds}" in the root directory of the
#' site.
#'
#' @param files A character vector of paths to the source files.
#' @param partial Logical. If \code{TRUE}, keep rows from digest file for source
#' files that aren't in \code{files}. Otherwise, get rid of the old file and only
#' keep digests for source files in \code{files}.
#' @return The path to the digest file.
#' @seealso \code{\link{update_site_digests}()}, \code{\link{digests}}.
#' @keywords internal
#'
update_rmd_digests = function(files, partial = FALSE) {
  base = blogdown:::site_root()
  files = files %>% normalizePath() %>% unique() %>% keep(file.exists)

  digest_file = file.path(base, "digests.Rds")

  digests = tibble(file = files, dest = blogdown:::output_file(files)) %>%
    mutate(dgst = map(file, digest_if_exists),
           alg = map_chr(dgst, ~.x['alg']),
           digest = map_chr(dgst, ~.x['digest']),
           dest_digest = map2_chr(dest, alg, ~digest_if_exists(.x, .y)['digest']),
           file = str_replace(file, fixed(base), "~"),
           dest = str_replace(dest, fixed(base), "~"))

  if (partial && file.exists(digest_file)) {
    old_digests = read_rds(digest_file) %>%
      filter(file %in% setdiff(file, file))
    digests = bind_rows(digests, old_digests)
  }

  write_rds(digests, digest_file)
  invisible(digest_file)
}

#' Generates and stores digests for all source and output files.
#'
#' \code{update_site_digests} calculates hashed digests for a site.
#'
#' Generates new hashed digests for both source and destination (output) files
#' and save the digests to a file "\code{digests.Rds}" in the root directory of the
#' site.
#'
#' @param dir A string with the name of the directory to search
#' (by default the "content" directory at the top-level directory of the site)
#' @param partial Logical. If \code{TRUE}, keep digests for source
#' files that aren't in the specified directory and its children and
#' descendants.
#' Otherwise, get rid of the old digest file and only keep digests for
#' source files in the source directory and its descendants.
#' @return The path to the digest file.
#' @seealso \code{\link{prune_site_digests}()}, \code{\link{update_site}()},
#' \code{\link{digests}}.
#' @export
#'
update_site_digests = function(dir = find_blog_content(), partial = FALSE) {
  blogdown:::list_rmds(dir) %>% update_rmd_digests(partial) %>%
    invisible()
}

#' Delete stored digests for specified source files
#'
#' \code{prune_site_digests} removes the lines from the digest file
#' corresponding to a vector of source files.
#'
#' Modifies the stored digest file to remove lines corresponding to selected
#' source files.
#'
#' @param files A character vector of paths to the source files to be removed.
#' @return The path to the digest file.
#' @seealso \code{\link{update_site_digests}()}, \code{\link{digests}}.
#' @export
#'
prune_site_digests = function(files) {
  base = blogdown:::site_root()
  files = files %>% normalizePath() %>% unique() %>%
    str_replace(fixed(base), "~")

  digest_file = file.path(base, "digests.Rds")

  if (length(files) && file.exists(digest_file)) {
    digests = read_rds(digest_file) %>%
      filter(! file %in% files)
    write_rds(digests, digest_file)
  }

  invisible(digest_file)
}
