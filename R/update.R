#' Update all files that are out of date
#'
#' \code{update_site} rebuilds all source files that are new or have changed since
#' the last time the site was built.
#'
#' Given a source directory (by default the "content" directory in the
#' root directory of the project), find all source files (\code{.Rmd} and
#' \code{.rmarkdown}) in the directory tree under the source directory,
#' calculate hashed digests of the files, and compare them to a
#' stored list of digests from the last time the site was built.
#'
#' If the digests of either the source or output files don't match,
#' if a source file is new since the last time the site was built,
#' or if the output file does not exist,
#' then render the source file.
#'
#' After rendering any out-of-date files, regenerate the digest list
#' and saves it to a file.
#'
#' @param dir A string containing the root directory for checking.
#' By default, the "content" directory of the project.
#' @param quiet Suppress output. By default this is \code{FALSE} and the
#' function emits an informational message about how many files will
#' be rebuilt.
#' @param force Force rebuilding source files that are not out of date.
#'
#' @inheritParams blogdown::build_site
#'
#' @return This function does not return anything
#'
#' @seealso \code{\link[blogdown]{build_site}()}, \code{\link[blogdown]{build_dir}()},
#' \code{\link{digests}}.
#'
#' @export
update_site <- function(dir = NULL, quiet = FALSE, force = FALSE,
                       local = FALSE, run_hugo = TRUE) {
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

  method <- getOption("blogdown.method")
  if (is.na(method)) {
    method <- "html"
  }
  on.exit(blogdown:::run_script("R/build.R", as.character(local)), add = TRUE,
          after = FALSE)
  if (method == "custom")
    return()
  files <- blogdown:::list_rmds(dir, TRUE)
  if (force) {
    to_build <- files
  } else {
    to_build <- files_to_rebuild(files)
  }
  to_build <- str_replace(normalizePath(to_build, winslash = "/"), fixed(cd), "")
  # message("To build: ", str_c(to_build, collapse = ", "))

  if (! quiet) {
    message("Building ", length(to_build), " out of date ",
            ifelse(length(to_build) == 1, "file", "files"),
            "; site has ", length(files), " ",
            ifelse(length(files) == 1, "file", "files"),
            " in total.")
  }
  blogdown:::build_rmds(to_build)
  if (run_hugo)
    on.exit(setwd(cd), add = TRUE, after = TRUE)
    on.exit(hugo_build(local), add = TRUE, after = TRUE)
    on.exit(setwd(old_wd), add = TRUE, after = TRUE)
  # message("On exit stack: ", deparse(sys.on.exit()))
  update_rmd_digests(files)
}

#' Rebuild changed files in a subdirectory of "content"
#'
#' \code{update_dir} updates changed files in a subdirectory of "content"
#'
#' @rdname update_site
#' @inheritParams update_site
#' @param ignore A regular expression pattern for files to ignore.
update_dir <- function(dir = '.', quiet = FALSE, force = FALSE,
                       ignore = NA_character_) {
  if (! dir.exists(dir)) {
    new_dir <- file.path(find_blog_content(), dir)
    if (! dir.exists(new_dir)) {
      stop("Directory does not exist: ", dir)
    } else {
      dir <- new_dir
    }
  }

  files <- blogdown:::list_rmds(dir, TRUE)
  if (! is.na(ignore))
    files <- files %>% discard(~str_detect(.x, ignore))

  if (force) {
    to_build <- files
  } else {
    to_build <- files_to_rebuild(files)
  }

  if (! quiet) {
    message("Building ", length(to_build), " out of date ",
            ifelse(length(to_build) == 1, "file", "files"),
            "; site has ", length(files), " ",
            ifelse(length(files) == 1, "file", "files"),
            " in total.")
  }
  blogdown:::build_rmds(to_build)
  update_rmd_digests(files, partial = TRUE)
  invisible(files)
}
