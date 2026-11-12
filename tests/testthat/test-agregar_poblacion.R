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
  it("falla si datos es un vector", {
    expect_error(
      agregar_poblacion(c(1101, 2102), nivel = "comunal"),
      "Esta función se aplica a tablas de datos"
    )
  })

  it("falla si datos no es dataframe ni vector", {
    expect_error(
      agregar_poblacion(quote(a), nivel = "comunal"),
      "No se puede agregar población"
    )
  })

  it("funciona con tibbles y conserva la clase", {
    datos <- tibble::tibble(codigo_comuna = c(1101, 2102))

    resultado <- suppressMessages(agregar_poblacion(datos, años = 2023))

    expect_s3_class(resultado, "tbl_df")
    expect_named(resultado, c("codigo_comuna", "poblacion"))
  })

  it("conserva filas repetidas y el orden original", {
    datos <- data.frame(codigo_comuna = c(2102, 1101, 2102))

    resultado <- suppressMessages(agregar_poblacion(datos, años = 2023))

    expect_equal(resultado$codigo_comuna, c(2102, 1101, 2102))
    expect_equal(resultado$poblacion[1], resultado$poblacion[3])
    expect_false(resultado$poblacion[1] == resultado$poblacion[2])
  })

  it("conserva el agrupamiento de datos agrupados", {
    datos <- dplyr::group_by(
      data.frame(codigo_comuna = c(1101, 2102)),
      codigo_comuna
    )

    resultado <- suppressMessages(agregar_poblacion(datos, años = 2023))

    expect_s3_class(resultado, "grouped_df")
    expect_equal(nrow(resultado), 2)
  })

  it("devuelve una tabla vacía con columna poblacion si los datos no tienen filas", {
    datos <- data.frame(codigo_comuna = numeric(0))

    resultado <- suppressMessages(agregar_poblacion(datos, años = 2023))

    expect_equal(nrow(resultado), 0)
    expect_named(resultado, c("codigo_comuna", "poblacion"))
  })

  it("falla si los códigos no son numéricos", {
    datos <- data.frame(codigo_comuna = "1101")

    suppressMessages(expect_error(
      agregar_poblacion(datos, años = 2023),
      "debe ser numérica"
    ))
  })

  it("entrega NA y una advertencia para códigos inexistentes mezclados con válidos", {
    datos <- data.frame(codigo_comuna = c(1101, 9999))

    expect_warning(
      resultado <- suppressMessages(agregar_poblacion(datos, años = 2023)),
      "no son válidos"
    )
    expect_false(is.na(resultado$poblacion[1]))
    expect_true(is.na(resultado$poblacion[2]))
  })

  it("repite la población regional en cada fila con el mismo código", {
    datos <- data.frame(codigo_region = c(1, 1, 2))

    resultado <- suppressMessages(agregar_poblacion(datos, años = 2023))

    expect_equal(resultado$poblacion[1], resultado$poblacion[2])
    expect_equal(nrow(resultado), 3)
  })

  it("usa la columna del nivel pedido aunque haya otras columnas de código", {
    datos <- data.frame(codigo_region = 1, codigo_comuna = 1101)

    regional <- suppressMessages(
      agregar_poblacion(datos, nivel = "regional", años = 2023)
    )
    comunal <- suppressMessages(
      agregar_poblacion(datos, nivel = "comunal", años = 2023)
    )

    expect_gt(regional$poblacion, comunal$poblacion)
  })

  it("detecta el nivel nacional desde las columnas pais o chile", {
    suppressMessages(
      expect_message(
        agregar_poblacion(data.frame(pais = "Chile"), años = 2023),
        "nacional"
      )
    )
    resultado <- suppressMessages(
      agregar_poblacion(data.frame(chile = "Chile"), años = 2023)
    )
    expect_false(is.na(resultado$poblacion))
  })

  it("repite la cifra nacional en todas las filas", {
    datos <- data.frame(pais = c("a", "b"))

    resultado <- suppressMessages(
      agregar_poblacion(datos, nivel = "nacional", años = 2023)
    )

    expect_equal(nrow(resultado), 2)
    expect_equal(resultado$poblacion[1], resultado$poblacion[2])
  })
})

describe("agregar_poblacion() argumento nivel (validación)", {
  datos <- data.frame(codigo_comuna = c(1101, 2102))

  it("acepta sinónimos y mayúsculas", {
    for (nivel in c("Comunal", "comuna", "COMUNAL", "codigo_comuna")) {
      resultado <- suppressMessages(
        agregar_poblacion(datos, nivel = nivel, años = 2023)
      )
      expect_equal(nrow(resultado), 2, info = nivel)
    }
  })

  it("acepta sinónimos de nivel regional y nacional", {
    regiones <- data.frame(codigo_region = 1)
    for (nivel in c("región", "region", "Regional")) {
      expect_no_error(suppressMessages(
        agregar_poblacion(regiones, nivel = nivel, años = 2023)
      ))
    }
    for (nivel in c("país", "pais", "chile")) {
      expect_no_error(suppressMessages(
        agregar_poblacion(data.frame(x = 1), nivel = nivel, años = 2023)
      ))
    }
  })

  it("falla con niveles inválidos", {
    expect_error(
      agregar_poblacion(datos, nivel = "xyz", años = 2023),
      "no es válido"
    )
  })

  it("falla si nivel no es un texto único", {
    expect_error(
      agregar_poblacion(datos, nivel = 1, años = 2023),
      "debe ser un texto"
    )
    expect_error(
      agregar_poblacion(datos, nivel = c("comunal", "regional"), años = 2023),
      "debe ser un texto"
    )
    expect_error(
      agregar_poblacion(datos, nivel = NA_character_, años = 2023),
      "debe ser un texto"
    )
  })

  it("falla si falta la columna de código para el nivel comunal", {
    expect_error(
      agregar_poblacion(
        data.frame(codigo_region = 1),
        nivel = "comunal",
        años = 2023
      ),
      "codigo_comuna"
    )
  })
})

describe("agregar_poblacion() argumento años", {
  it("usa el año actual con la base de proyecciones si no se especifica", {
    datos <- data.frame(codigo_comuna = 1101)
    año_actual <- as.integer(format(Sys.Date(), "%Y"))
    esperado <- censo_poblacion_proyeccion |>
      dplyr::filter(codigo_comuna == 1101, año == año_actual)

    if (nrow(esperado) == 0) {
      skip("el año actual no está en las proyecciones")
    }

    suppressMessages(
      expect_message(
        resultado <- agregar_poblacion(datos),
        as.character(año_actual)
      )
    )
    expect_equal(resultado$poblacion, esperado$poblacion)
  })

  it("usa el año más reciente de otras bases si no se especifica", {
    datos <- data.frame(codigo_comuna = 1101)

    resultado <- suppressMessages(
      agregar_poblacion(datos, base = "censo_poblacion_2017")
    )
    esperado <- censo_poblacion_2017 |>
      dplyr::filter(codigo_comuna == 1101)

    expect_equal(resultado$poblacion, esperado$poblacion)
  })

  it("usa los años de los datos si tienen columna año y no se especifica años", {
    datos <- data.frame(codigo_comuna = 1101, año = c(2023, 2024))

    resultado <- suppressMessages(agregar_poblacion(datos))

    expect_false(anyNA(resultado$poblacion))
    expect_equal(resultado$año, c(2023, 2024))
  })

  it("falla si los años de los datos no existen en la base", {
    datos <- data.frame(codigo_comuna = 1101, año = 1900)

    suppressMessages(expect_error(
      agregar_poblacion(datos),
      "no está disponible"
    ))
  })

  it("falla si el año pedido no existe en la base", {
    datos <- data.frame(codigo_comuna = 1101)

    suppressMessages(expect_error(
      agregar_poblacion(datos, años = 1900),
      "años disponibles son: entre 2002 y 2035"
    ))
    suppressMessages(expect_error(
      agregar_poblacion(datos, años = 2023, base = "censo_poblacion_2017"),
      "años disponibles son: 2017"
    ))
  })

  it("funciona con años enteros en datos y en el argumento", {
    datos <- data.frame(codigo_comuna = 1101, año = 2023L)

    resultado <- suppressMessages(agregar_poblacion(datos, años = 2023L))

    expect_false(is.na(resultado$poblacion))
  })

  it("agrega varios años a nivel regional y nacional", {
    regional <- suppressMessages(agregar_poblacion(
      data.frame(codigo_region = 1, año = c(2023, 2024)),
      nivel = "regional",
      años = 2023:2024
    ))
    nacional <- suppressMessages(agregar_poblacion(
      data.frame(pais = "Chile", año = c(2023, 2024)),
      nivel = "nacional",
      años = 2023:2024
    ))

    expect_false(anyNA(regional$poblacion))
    expect_false(anyNA(nacional$poblacion))
    expect_gt(nacional$poblacion[1], regional$poblacion[1])
  })

  it("falla si no hay población para los años de los datos y el año pedido", {
    datos <- data.frame(codigo_comuna = 1101, año = 2023)

    expect_error(
      suppressMessages(agregar_poblacion(datos, años = 2024)),
      "No se encontraron cifras"
    )
  })
})

describe("agregar_poblacion() argumento base", {
  datos <- data.frame(codigo_comuna = c(1101, 2102))

  it("acepta el nombre de cualquier base del paquete", {
    resultado <- suppressMessages(
      agregar_poblacion(datos, años = 2017, base = "censo_poblacion_2017")
    )
    expect_equal(
      resultado$poblacion,
      censo_poblacion_2017$poblacion[match(
        c(1101, 2102),
        censo_poblacion_2017$codigo_comuna
      )]
    )
  })

  it("acepta un dataframe como base", {
    resultado <- suppressMessages(
      agregar_poblacion(datos, base = censo_poblacion_2024)
    )
    esperado <- censo_poblacion_2024$poblacion[
      match(c(1101, 2102), censo_poblacion_2024$codigo_comuna)
    ]
    expect_equal(resultado$poblacion, esperado)
  })

  it("acepta una base propia con las columnas necesarias", {
    base_propia <- data.frame(
      codigo_comuna = c(1101, 2102),
      codigo_region = c(1, 2),
      año = 2030,
      poblacion = c(10, 20)
    )

    resultado <- suppressMessages(agregar_poblacion(datos, base = base_propia))

    expect_equal(resultado$poblacion, c(10, 20))
  })

  it("suma una base propia a nivel regional y nacional", {
    base_propia <- data.frame(
      codigo_comuna = c(1101, 1107, 2102),
      codigo_region = c(1, 1, 2),
      año = 2030,
      poblacion = c(10, 5, 20)
    )

    regional <- suppressMessages(agregar_poblacion(
      data.frame(codigo_region = c(1, 2)),
      base = base_propia
    ))
    nacional <- suppressMessages(agregar_poblacion(
      data.frame(pais = "Chile"),
      nivel = "nacional",
      base = base_propia
    ))

    expect_equal(regional$poblacion, c(15, 20))
    expect_equal(nacional$poblacion, 35)
  })

  it("permite bases propias sin columnas de código a nivel nacional", {
    base_propia <- data.frame(año = 2030, poblacion = c(10, 5))

    resultado <- suppressMessages(agregar_poblacion(
      data.frame(pais = "Chile"),
      nivel = "nacional",
      base = base_propia
    ))

    expect_equal(resultado$poblacion, 15)
  })

  it("falla si la base propia no tiene las columnas requeridas", {
    suppressMessages(expect_error(
      agregar_poblacion(datos, años = 2023, base = data.frame(a = 1)),
      "no tiene las columnas requeridas"
    ))
  })

  it("falla si la base propia tiene filas duplicadas por comuna y año", {
    base_duplicada <- data.frame(
      codigo_comuna = c(1101, 1101),
      codigo_region = 1,
      año = 2030,
      poblacion = c(10, 20)
    )

    expect_error(
      suppressMessages(agregar_poblacion(
        datos[1, , drop = FALSE],
        base = base_duplicada
      )),
      "más filas"
    )
  })

  it("falla si el nombre de la base no existe o el tipo es inválido", {
    suppressMessages(expect_error(
      agregar_poblacion(datos, años = 2023, base = "noexiste"),
      "No se encontró la base"
    ))
    suppressMessages(expect_error(
      agregar_poblacion(datos, años = 2023, base = 5),
      "debe ser un dataframe"
    ))
    suppressMessages(expect_error(
      agregar_poblacion(datos, años = 2023, base = c("a", "b")),
      "debe ser un dataframe"
    ))
  })
})
