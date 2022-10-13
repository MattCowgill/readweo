import_weo <- function(file) {
  # old_vroom_opt <- Sys.getenv("VROOM_CONNECTION_SIZE")
  # Sys.setenv(VROOM_CONNECTION_SIZE = as.integer(10000000))
  # on.exit(Sys.setenv(VROOM_CONNECTION_SIZE = old_vroom_opt))

  raw_df <- suppressMessages(
    suppressWarnings(
      readr::with_edition(1,
                          readr::read_tsv(file,
                                          col_types = readr::cols("c", .default = readr::col_double())))
    )
  )

  # raw_df <- data.table::fread(cmd = paste0("sed 's/\\0//g' ", file))

  # suppressWarnings(
  #   raw_df <-   read.delim(file,
  #                          fileEncoding = "UTF-16LE")
  # )

  raw_df
}

#' @importFrom rlang .data .env
tidy_weo <- function(df) {

  parse_number_nowarning <- function(...) {
    suppressWarnings(
      readr::parse_number(...)
    )
  }

  df |>
    dplyr::as_tibble() |>
    janitor::remove_empty(c("rows", "cols")) |>
    janitor::clean_names() |>
    dplyr::mutate(dplyr::across(dplyr::starts_with("x"),
                                as.character)) |>
    tidyr::pivot_longer(cols = dplyr::starts_with("x"),
                        names_to = "year") |>
    dplyr::mutate(year = gsub("x", "", .data$year),
                  dplyr::across(c(.data$year, .data$value),
                         parse_number_nowarning)) |>
    dplyr::filter(!is.na(.data$value))
}
