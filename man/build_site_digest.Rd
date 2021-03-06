% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/build_site.R
\name{build_site_digest}
\alias{build_site_digest}
\title{Build the Site and Update Digests}
\usage{
build_site_digest(local = FALSE, run_hugo = TRUE)
}
\arguments{
\item{local}{Whether to build the website locally. This argument is passed to
\code{\link[blogdown]{hugo_build}()}, and \code{local = TRUE} is mainly for serving
the site locally via \code{\link[blogdown]{serve_site}()}.}

\item{run_hugo}{Whether to run \code{hugo_build()} after R Markdown files are
compiled.}
}
\description{
`build_site_digest` builds the entire site and then updates the digests.
}
