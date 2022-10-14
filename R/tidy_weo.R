import_weo <- function(file) {

  guessed_encoding <- readr::guess_encoding(file)$encoding[1]

  suppressMessages(
    readr::read_tsv(file,
                    col_types = readr::cols(readr::col_character()),
                    locale = readr::locale(encoding = guessed_encoding))
  )

}

#' @importFrom rlang .data .env
tidy_weo <- function(df) {

  parse_number_nowarning <- function(...) {
    suppressWarnings(
      readr::parse_number(...)
    )
  }

  df %>%
    dplyr::as_tibble() %>%
    janitor::remove_empty(c("rows", "cols")) %>%
    janitor::clean_names() %>%
    dplyr::filter(!grepl("International Monetary Fund", .data$weo_country_code, fixed = TRUE)) %>%
    dplyr::mutate(dplyr::across(dplyr::starts_with("x"),
                                as.character)) %>%
    tidyr::pivot_longer(cols = dplyr::starts_with("x"),
                        names_to = "year") %>%
    dplyr::mutate(year = gsub("x", "", .data$year, fixed = TRUE),
                  dplyr::across(c(.data$year, .data$value),
                         parse_number_nowarning)) %>%
    dplyr::filter(!is.na(.data$value))
}
