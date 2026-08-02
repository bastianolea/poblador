library(pointblank)

test_that("conteo de columnas", {
  expect_col_count_match(mideso_pobreza_ingresos, 8)
})

test_that("conteo de filas", {
  expect_row_count_match(mideso_pobreza_ingresos, 345)
})

test_that("sin datos perdidos", {
  expect_col_vals_not_null(mideso_pobreza_ingresos, everything())
})
