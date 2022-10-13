test_that("read_weo() words", {
  valid <- read_weo("Oct 2022")
  expect_s3_class(valid, "tbl_df")
  expect_gt(ncol(valid), 12)
  expect_gt(nrow(valid), 300000)
  expect_error(read_weo("Sep 2022"))
})
