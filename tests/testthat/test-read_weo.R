test_that("read_weo() words", {
  check_df <- function(month) {
    df <- read_weo(month)
    expect_s3_class(df, "tbl_df")
    expect_gt(ncol(df), 12)
    expect_gt(nrow(df), 100000)
  }

  for (month in c("Oct 2017", "april 2019", "october 2022")) {
    print(paste("Testing", month))
    check_df(month)
  }

  expect_error(read_weo("Sep 2022"))
})
