# CHANGES IN blogdownDigest VERSION 0.1.3

Bug fix for the `partial` argument to `update_rmd_digests`.

# CHANGES IN blogdownDigest VERSION 0.1.1

## BUG FIXES

* Fixed handling of paths in `update_site()` to `setwd()` to the project root 
  and use relative paths to content directory.
  
    Previously, `update_site()` used absolute paths, which created errors since
    `blogdown:::build_rmds()` expects paths relative to the root when setting
    up references (e.g., to images).
* Edited all calls to `normalizePath()` to use `winslash = "/"` for consistent
  handling of path separators.

# CHANGES IN blogdownDigest VERSION 0.1.0

First release.
