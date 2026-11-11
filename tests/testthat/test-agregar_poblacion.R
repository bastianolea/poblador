describe("agregar_poblacion() con dataframes", {
  it("agrega población comunal y conserva las columnas originales", {
    datos <- censo_poblacion_proyeccion |>
      dplyr::distinct(codigo_comuna, nombre_comuna) |>
      dplyr::filter(codigo_comuna %in% c(1101, 2102))

    resultado <- suppressMessages(
      agregar_poblacion(datos, nivel = "comunal", años = 2023)
    )

    esperado <- censo_poblacion_proyeccion |>
      dplyr::filter(codigo_comuna %in% c(1101, 2102), año == 2023)

    expect_named(resultado, c("codigo_comuna", "nombre_comuna", "poblacion"))
    expect_equal(resultado$codigo_comuna, datos$codigo_comuna)
    expect_equal(resultado$poblacion, esperado$poblacion)
  })

  it("detecta el nivel comunal desde la columna codigo_comuna y avisa", {
    datos <- data.frame(codigo_comuna = c(1101, 2102))

    suppressMessages(
      expect_message(
        resultado <- agregar_poblacion(datos, años = 2023),
        "comunal"
      )
    )
    expect_equal(nrow(resultado), 2)
    expect_false(anyNA(resultado$poblacion))
  })

  it("suma las comunas al agregar a nivel regional", {
    datos <- data.frame(codigo_region = c(1, 2))

    resultado <- suppressMessages(agregar_poblacion(datos, años = 2023))

    esperado <- censo_poblacion_proyeccion |>
      dplyr::filter(codigo_region %in% c(1, 2), año == 2023) |>
      dplyr::summarize(poblacion = sum(poblacion), .by = codigo_region)

    expect_equal(resultado$poblacion, esperado$poblacion)
  })

  it("conserva columnas adicionales que no están en la base", {
    datos <- data.frame(codigo_region = c(1, 2), valor = c("a", "b"))

    resultado <- suppressMessages(agregar_poblacion(datos, años = 2023))

    expect_named(resultado, c("codigo_region", "valor", "poblacion"))
    expect_equal(resultado$valor, c("a", "b"))
    expect_false(anyNA(resultado$poblacion))
  })

  it("falla si los datos ya tienen una columna poblacion", {
    datos <- data.frame(codigo_comuna = 1101, poblacion = 1)

    expect_error(
      suppressMessages(
        agregar_poblacion(datos, nivel = "comunal", años = 2023)
      ),
      "ya tienen una columna"
    )
  })

  it("agrega varios años cuando los datos tienen columna año", {
    datos <- data.frame(
      codigo_comuna = c(1101, 1101),
      año = c(2023, 2024)
    )

    resultado <- suppressMessages(
      agregar_poblacion(datos, nivel = "comunal", años = 2023:2024)
    )

    expect_equal(nrow(resultado), 2)
    expect_equal(resultado$año, c(2023, 2024))
    expect_false(anyNA(resultado$poblacion))
  })

  it("devuelve NA en los años de los datos que no se pidieron", {
    datos <- data.frame(
      codigo_comuna = c(1101, 1101),
      año = c(2023, 2024)
    )

    resultado <- suppressMessages(
      agregar_poblacion(datos, nivel = "comunal", años = 2023)
    )

    expect_false(is.na(resultado$poblacion[1]))
    expect_true(is.na(resultado$poblacion[2]))
  })

  it("falla si se piden varios años y los datos no tienen columna año", {
    datos <- data.frame(codigo_comuna = 1101)

    expect_error(
      agregar_poblacion(datos, nivel = "comunal", años = 2023:2024),
      "no tienen columna de año"
    )
  })

  it("falla si se piden años que no están en los datos", {
    datos <- data.frame(codigo_comuna = 1101, año = c(2023, 2024))

    expect_error(
      agregar_poblacion(datos, nivel = "comunal", años = c(2023, 2030)),
      "no están disponibles en los datos"
    )
  })

  it("falla si el nivel no se puede detectar", {
    expect_error(
      agregar_poblacion(data.frame(x = 1), años = 2023),
      "No se pudo detectar el nivel"
    )
  })

  it("falla si falta la columna de código del nivel pedido", {
    datos <- data.frame(codigo_comuna = 1101)

    expect_error(
      agregar_poblacion(datos, nivel = "regional", años = 2023),
      "codigo_region"
    )
  })

  it("falla si ningún código tiene población", {
    datos <- data.frame(codigo_comuna = 9999)

    expect_error(
      suppressMessages(suppressWarnings(
        agregar_poblacion(datos, nivel = "comunal", años = 2023)
      )),
      "No se encontraron cifras"
    )
  })
})

describe("agregar_poblacion() argumento nivel", {
  it("agrega población nacional a dataframes", {
    total_2023 <- sum(
      dplyr::filter(censo_poblacion_proyeccion, año == 2023)$poblacion
    )

    resultado <- suppressMessages(
      agregar_poblacion(
        data.frame(pais = "chile"),
        nivel = "nacional",
        años = 2023
      )
    )

    expect_equal(resultado$poblacion, total_2023)
  })

  it("agrega población nacional por año si los datos tienen columna año", {
    datos <- data.frame(pais = "chile", año = c(2023, 2024))

    resultado <- suppressMessages(
      agregar_poblacion(datos, nivel = "nacional", años = 2023:2024)
    )

    esperado <- censo_poblacion_proyeccion |>
      dplyr::filter(año %in% 2023:2024) |>
      dplyr::summarize(poblacion = sum(poblacion), .by = año) |>
      dplyr::arrange(año)

    expect_equal(resultado$poblacion, esperado$poblacion)
  })
})

describe("agregar_poblacion() argumento datos", {
  it("falla si datos no es dataframe ni vector", {
    expect_error(
      agregar_poblacion(quote(a), nivel = "comunal"),
      "No se puede agregar población"
    )
  })
})
