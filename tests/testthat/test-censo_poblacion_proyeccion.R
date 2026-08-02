library(pointblank)

test_that("conteo de columnas", {
  expect_col_count_match(censo_poblacion_proyeccion, 8)
})

test_that("conteo de filas", {
  años <- length(unique(censo_poblacion_proyeccion$año))
  expect_row_count_match(censo_poblacion_proyeccion, 346 * años)
})

test_that("sin datos perdidos", {
  expect_col_vals_not_null(censo_poblacion_proyeccion, everything())
})
