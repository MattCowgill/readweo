test_that("read_weo() works", {
  check_df <- function(df) {
    expect_s3_class(df, "tbl_df")
    expect_gt(ncol(df), 12)
    expect_gt(nrow(df), 100000)
  }

  for (month in c("Oct 2017", "april 2019", "october 2022")) {
    print(paste("Testing", month))
    df <- read_weo(month)
    check_df(df)
  }

  # Test default with no month specified
  check_df(read_weo())

  expect_error(read_weo("Sep 2022"))
})
