describe("agregar_poblacion() con dataframes", {
  it("agrega población comunal y conserva las columnas originales", {
    datos <- censo_poblacion_proyeccion |>
      dplyr::distinct(codigo_comuna, nombre_comuna) |>
      dplyr::filter(codigo_comuna %in% c(1101, 2102))

    resultado <- agregar_poblacion(datos, nivel = "comunal", años = 2023)

    esperado <- censo_poblacion_proyeccion |>
      dplyr::filter(codigo_comuna %in% c(1101, 2102), año == 2023)

    expect_named(resultado, c("codigo_comuna", "nombre_comuna", "poblacion"))
    expect_equal(resultado$codigo_comuna, datos$codigo_comuna)
    expect_equal(resultado$poblacion, esperado$poblacion)
  })

  it("detecta el nivel comunal desde la columna codigo_comuna y avisa", {
    datos <- data.frame(codigo_comuna = c(1101, 2102))

    expect_message(
      resultado <- agregar_poblacion(datos, años = 2023),
      "comunal"
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

  it("agrega varios años cuando los datos tienen columna año", {
    datos <- data.frame(
      codigo_comuna = c(1101, 1101),
      año = c(2023, 2024)
    )

    resultado <- agregar_poblacion(datos, nivel = "comunal", años = 2023:2024)

    expect_equal(nrow(resultado), 2)
    expect_equal(resultado$año, c(2023, 2024))
    expect_false(anyNA(resultado$poblacion))
  })

  it("devuelve NA en los años de los datos que no se pidieron", {
    datos <- data.frame(
      codigo_comuna = c(1101, 1101),
      año = c(2023, 2024)
    )

    resultado <- agregar_poblacion(datos, nivel = "comunal", años = 2023)

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
      suppressWarnings(agregar_poblacion(datos, nivel = "comunal", años = 2023)),
      "No se encontraron cifras"
    )
  })
})

describe("agregar_poblacion() con vectores", {
  it("devuelve un vector de población en el orden de los códigos", {
    codigos <- c(2102, 1101)

    resultado <- agregar_poblacion(codigos, nivel = "comunal", años = 2023)

    esperado <- censo_poblacion_proyeccion |>
      dplyr::filter(año == 2023) |>
      dplyr::slice(match(codigos, codigo_comuna)) |>
      dplyr::pull(poblacion)

    expect_type(resultado, "double")
    expect_equal(resultado, esperado)
  })

  it("detecta el nivel comunal o regional desde los códigos y avisa", {
    expect_message(
      comunal <- agregar_poblacion(c(1101, 2102), años = 2023),
      "comunal"
    )
    expect_message(
      regional <- agregar_poblacion(c(1, 2), años = 2023),
      "regional"
    )
    expect_equal(
      regional,
      agregar_poblacion(c(1, 2), nivel = "regional", años = 2023)
    )
  })

  it("advierte y devuelve NA para códigos inválidos", {
    expect_warning(
      resultado <- agregar_poblacion(c(1101, 9999), nivel = "comunal", años = 2023),
      "no son válidos"
    )
    expect_false(is.na(resultado[1]))
    expect_true(is.na(resultado[2]))
  })

  it("falla si se piden varios años", {
    expect_error(
      agregar_poblacion(c(1101, 2102), nivel = "comunal", años = 2023:2024),
      "sólo se puede especificar un año"
    )
  })

  it("falla si no puede detectar el nivel", {
    expect_error(
      agregar_poblacion(c(99999, 88888)),
      "No se pudo detectar el nivel"
    )
  })
})

describe("agregar_poblacion() argumento nivel", {
  it("normaliza sinónimos del nivel", {
    codigos <- c(1101, 2102)
    referencia <- agregar_poblacion(codigos, nivel = "comunal", años = 2023)

    expect_equal(agregar_poblacion(codigos, nivel = "comuna", años = 2023), referencia)
    expect_equal(agregar_poblacion(codigos, nivel = "COMUNA", años = 2023), referencia)
    expect_equal(
      agregar_poblacion(c(1, 2), nivel = "región", años = 2023),
      agregar_poblacion(c(1, 2), nivel = "regional", años = 2023)
    )
  })

  it("falla con un nivel desconocido", {
    expect_error(
      agregar_poblacion(c(1101, 2102), nivel = "provincial", años = 2023),
      "nivel especificado no es válido"
    )
  })

  it("agrega población nacional a dataframes y vectores", {
    total_2023 <- sum(
      dplyr::filter(censo_poblacion_proyeccion, año == 2023)$poblacion
    )

    resultado_tabla <- agregar_poblacion(
      data.frame(pais = "chile"),
      nivel = "nacional",
      años = 2023
    )
    resultado_vector <- agregar_poblacion(
      c("a", "b"),
      nivel = "nacional",
      años = 2023
    )

    expect_equal(resultado_tabla$poblacion, total_2023)
    expect_equal(resultado_vector, c(total_2023, total_2023))
  })

  it("agrega población nacional por año si los datos tienen columna año", {
    datos <- data.frame(pais = "chile", año = c(2023, 2024))

    resultado <- agregar_poblacion(datos, nivel = "nacional", años = 2023:2024)

    esperado <- censo_poblacion_proyeccion |>
      dplyr::filter(año %in% 2023:2024) |>
      dplyr::summarize(poblacion = sum(poblacion), .by = año) |>
      dplyr::arrange(año)

    expect_equal(resultado$poblacion, esperado$poblacion)
  })
})

describe("agregar_poblacion() argumento años", {
  it("usa el año actual con la base de proyecciones", {
    resultado <- agregar_poblacion(c(1101, 2102), nivel = "comunal")

    esperado <- agregar_poblacion(
      c(1101, 2102),
      nivel = "comunal",
      años = as.integer(format(Sys.Date(), "%Y"))
    )

    expect_equal(resultado, esperado)
  })

  it("usa el año más reciente en otras bases", {
    resultado <- agregar_poblacion(
      c(1101, 2102),
      nivel = "comunal",
      base = "censo_poblacion_2017"
    )

    esperado <- censo_poblacion_2017 |>
      dplyr::filter(codigo_comuna %in% c(1101, 2102)) |>
      dplyr::pull(poblacion)

    expect_equal(resultado, esperado)
  })

  it("falla con un año fuera de la base e informa el rango", {
    expect_error(
      agregar_poblacion(c(1101, 2102), nivel = "comunal", años = 1900),
      "entre 2002 y 2035"
    )
  })
})

describe("agregar_poblacion() argumento base", {
  it("acepta el nombre de una base como texto o la base como dataframe", {
    codigos <- c(1101, 2102)

    como_texto <- agregar_poblacion(codigos, nivel = "comunal", base = "censo_poblacion_2017")
    como_tabla <- agregar_poblacion(codigos, nivel = "comunal", base = censo_poblacion_2017)

    expect_equal(como_texto, como_tabla)
  })

  it("acepta un dataframe propio con columnas año y poblacion", {
    base_propia <- data.frame(
      codigo_region = 1,
      codigo_comuna = c(1101, 1107),
      año = 2030,
      poblacion = c(100, 50)
    )

    expect_equal(
      agregar_poblacion(c(1107, 1101), nivel = "comunal", base = base_propia),
      c(50, 100)
    )
  })

  it("falla si base no es texto ni dataframe", {
    expect_error(
      agregar_poblacion(1101, nivel = "comunal", base = 3),
      "debe ser un dataframe"
    )
  })

  it("falla si el dataframe de base no tiene las columnas requeridas", {
    expect_error(
      agregar_poblacion(1101, nivel = "comunal", base = data.frame(a = 1)),
      "no tiene las columnas requeridas"
    )
  })

  it("falla si el nombre de base no existe", {
    expect_error(
      agregar_poblacion(1101, nivel = "comunal", base = "base_inexistente")
    )
  })
})

describe("agregar_poblacion() argumento datos", {
  it("falla si datos no es dataframe ni vector", {
    expect_error(
      agregar_poblacion(quote(a), nivel = "comunal"),
      "debe ser un dataframe o un vector"
    )
  })
})
