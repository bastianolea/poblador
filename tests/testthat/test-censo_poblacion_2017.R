library(pointblank)

test_that("conteo de columnas", {
  expect_col_count_match(censo_poblacion_2017, 8)
})

test_that("conteo de filas", {
  expect_row_count_match(censo_poblacion_2017, 346)
})

test_that("sin datos perdidos", {
  expect_col_vals_not_null(censo_poblacion_2017, everything())
})
