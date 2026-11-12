test_that("datos() menciona todas las tablas de datos del paquete", {
  # las líneas vacías de cat_line() salen por stdout, no como mensajes
  mensajes <- NULL
  utils::capture.output(
    mensajes <- testthat::capture_messages(datos())
  )
  mensajes <- paste(mensajes, collapse = "")

  # tablas de datos del paquete, excluyendo el catálogo
  tablas_paquete <- utils::data(package = "poblador")$results[, "Item"] |>
    setdiff("catalogo")

  expect_gt(length(tablas_paquete), 0)

  for (tabla in tablas_paquete) {
    expect_match(mensajes, tabla, fixed = TRUE)
  }
})

test_that("datos() retorna invisible los nombres del catálogo", {
  resultado <- NULL
  utils::capture.output(
    resultado <- suppressMessages(withVisible(datos()))
  )

  expect_false(resultado$visible)
})
