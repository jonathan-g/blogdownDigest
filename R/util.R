#' Digests for detecting file modifications.
#'
#' When creating digests for detecting file modifications, there is
#' a choice of algorithms
#'
#' File digests are created by applying a hashing algorithm to the text contents
#' of a source file (\code{.Rmd} or  \code{.rmarkdown}).
#' By default, \code{blogdown} uses crc32 because it is fast and is good enough
#' for detecting changes in source files. This would not be good enough for
#' uniquely identifying a given file revision or source file (e.g., for revision
#' control), but that's not necessary for the purposes of updating sites in
#' `blogdown`.
#'
#' The user can override the hashing algorithm by setting
#' \code{options(blogdown.hash.algorithm = <algorithm>)},
#' where \code{<algorithm>} is one of the allowed digest algorithms
#' in \code{\link[digest]{digest}()}: "\code{crc32}", "\code{md5}",
#' "\code{sha1}", "\code{sha256}", "\code{sha512}",
#' "\code{xxhash32}", "\code{xxhash64}", or "\code{murmur32}".
#'
#' @examples
#' options(blogdown.hash.algorithm = "sha256")
#' @seealso \code{\link{update_site_digests}()}, \code{\link{update_site}()}.
#' @name digests
NULL

#' Get the "content" directory of the site
#'
#' \code{find_blog_content} gets the "content" directory of the site.
#'
#' @return A string containing the absolute path of the root directory for the
#' site.
#' @keywords internal
find_blog_content = function() {
  file.path(blogdown:::site_root(), "content")
}

#' Get the digest algorithm to use
#'
#' \code{get_digest_algorithm} gets the digest algorithm that will be used.
#'
#' Set the algorithm with `options(blogdown.hash.algorithm = <algorithm>)`.
#' If the option is not set, then use crc32.
#'
#' @return A string containing the name of the algorithm.
#' @seealso \code{\link{digests}}.
#' @keywords internal
get_digest_algorithm = function() {
  getOption("blogdownDigest.hash.algorithm", default = "crc32")
}
