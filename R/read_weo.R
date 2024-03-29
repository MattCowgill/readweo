#' Read data from the IMF World Economic Outlook
#'
#' The IMF releases World Economic Outlook reports typically twice a year,
#' in April and October. These reports contain a range of data and forecasts of
#' key economic variables. They provide this data (including the forecasts) in
#' downloadable tables. `read_weo()` downloads, imports, and tidies these
#' tables.
#'
#' @param month_year Date, or a month-year character string such as
#' "Oct 2022" or "October 2022" or "April 2021".
#' `NULL` (the default) means `read_weo()` will try to
#' fetch the latest available WEO.
#' @param path Path to directory where downloaded file should be stored
#' @examples
#' \dontrun{
#' read_weo("Oct 2022")
#'
#' read_weo("April 2019")
#' }
#' @export
read_weo <- function(month_year = NULL,
                     path = tempdir()) {

  if (is.null(month_year)) {
    weo_date <- guess_latest_weo()
  }

  if (is.character(month_year)) {
    weo_date <- lubridate::dmy(paste0("01-", month_year))
  }

  if (inherits(month_year, "Date")) {
    weo_date <- month_year
  }

  stopifnot(inherits(weo_date, "Date"))

  url <- form_weo_url(weo_date)

  weo_exists <- check_weo_exists(url)

  if (!weo_exists) {
    stop("WEO for the specified `month_year` cannot be found.")
  }

  # The WEO files present themselves as .xls, but they're actually .tsv :|
  file <- file.path(path,
                    paste0("IMF-WEO-",
                           weo_date,
                           ".tsv"))

  dl_file(url = url,
          destfile = file)

  raw_weo <- import_weo(file)

  weo <- tidy_weo(raw_weo)

  dplyr::mutate(weo, weo_date = weo_date)

}

dl_file <- function(url, destfile, quiet = TRUE) {
  suppressWarnings(
    utils::download.file(
      url = url,
      destfile = destfile,
      mode = "wb",
      quiet = quiet,
      headers = c("User-Agent" = "readweo R package - https://github.com/MattCowgill/readweo"),
      cacheOK = FALSE
    )
  )
}

guess_latest_weo <- function(today = Sys.Date()) {
  possible_weos <- utils::tail(seq(as.Date("2000-04-01"),
                       today,
                       "6 months"), 2)

  try_weo <- function(date) {
    url <- form_weo_url(date)
    check_weo_exists(url)
  }

  result_latest <- try_weo(max(possible_weos))

  if (result_latest) {
    return(max(possible_weos))
  } else {
    return(min(possible_weos))
  }
}

check_weo_exists <- function(url) {

  head_response <- httr::HEAD(url)

  !grepl("error", head_response$url)
}

form_weo_url <- function(date) {
  stopifnot(inherits(date, "Date"))
  year <- lubridate::year(date)
  url <- paste0(
    "https://www.imf.org/-/media/Files/Publications/WEO/WEO-Database/",
    year,
    "/WEO",
    format(date, "%b%Y"),
    "all.ashx"
  )
  url
}
