#' Build the Site and Update Digests
#'
#' `build_site_digest` builds the entire site and then updates the digests.
#'
#' @inheritParams blogdown::build_site
#'
#' @export
build_site_digest <- function(local = FALSE, run_hugo = TRUE) {
  blogdown::build_site(local = local, run_hugo = run_hugo, build_rmd = TRUE)
  update_site_digests()
}
