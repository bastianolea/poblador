describe("obtener_poblacion() con vectores", {
  it("devuelve un vector de población en el orden de los códigos", {
    codigos <- c(2102, 1101)

    resultado <- suppressMessages(
      obtener_poblacion(codigos, nivel = "comunal", años = 2023)
    )

    esperado <- censo_poblacion_proyeccion |>
      dplyr::filter(año == 2023) |>
      dplyr::slice(match(codigos, codigo_comuna)) |>
      dplyr::pull(poblacion)

    expect_type(resultado, "double")
    expect_equal(resultado, esperado)
  })

  it("detecta el nivel comunal o regional desde los códigos y avisa", {
    suppressMessages({
      expect_message(
        comunal <- obtener_poblacion(c(1101, 2102), años = 2023),
        "comunal"
      )
      expect_message(
        regional <- obtener_poblacion(c(1, 2), años = 2023),
        "regional"
      )
      expect_equal(
        regional,
        obtener_poblacion(c(1, 2), nivel = "regional", años = 2023)
      )
    })
  })

  it("advierte y devuelve NA para códigos inválidos", {
    suppressMessages(
      expect_warning(
        resultado <- obtener_poblacion(
          c(1101, 9999),
          nivel = "comunal",
          años = 2023
        ),
        "no son válidos"
      )
    )
    expect_false(is.na(resultado[1]))
    expect_true(is.na(resultado[2]))
  })

  it("falla si se piden varios años", {
    expect_error(
      suppressMessages(
        obtener_poblacion(c(1101, 2102), nivel = "comunal", años = 2023:2024)
      ),
      "sólo se puede especificar un año"
    )
  })

  it("falla si no puede detectar el nivel", {
    expect_error(
      obtener_poblacion(c(99999, 88888)),
      "No se pudo detectar el nivel"
    )
  })
})

describe("obtener_poblacion() argumento nivel", {
  it("normaliza sinónimos del nivel", {
    codigos <- c(1101, 2102)

    suppressMessages({
      referencia <- obtener_poblacion(codigos, nivel = "comunal", años = 2023)

      expect_equal(
        obtener_poblacion(codigos, nivel = "comuna", años = 2023),
        referencia
      )
      expect_equal(
        obtener_poblacion(codigos, nivel = "COMUNA", años = 2023),
        referencia
      )
      expect_equal(
        obtener_poblacion(c(1, 2), nivel = "región", años = 2023),
        obtener_poblacion(c(1, 2), nivel = "regional", años = 2023)
      )
    })
  })

  it("falla con un nivel desconocido", {
    expect_error(
      obtener_poblacion(c(1101, 2102), nivel = "provincial", años = 2023),
      "nivel especificado no es válido"
    )
  })

  it("agrega población nacional a vectores", {
    total_2023 <- sum(
      dplyr::filter(censo_poblacion_proyeccion, año == 2023)$poblacion
    )

    resultado_vector <- suppressMessages(
      obtener_poblacion(c("a", "b"), nivel = "nacional", años = 2023)
    )

    expect_equal(resultado_vector, c(total_2023, total_2023))
  })
})

describe("obtener_poblacion() argumento años", {
  it("usa el año actual con la base de proyecciones", {
    suppressMessages({
      resultado <- obtener_poblacion(c(1101, 2102), nivel = "comunal")

      esperado <- obtener_poblacion(
        c(1101, 2102),
        nivel = "comunal",
        años = as.integer(format(Sys.Date(), "%Y"))
      )
    })

    expect_equal(resultado, esperado)
  })

  it("usa el año más reciente en otras bases", {
    resultado <- suppressMessages(
      obtener_poblacion(
        c(1101, 2102),
        nivel = "comunal",
        base = "censo_poblacion_2017"
      )
    )

    esperado <- censo_poblacion_2017 |>
      dplyr::filter(codigo_comuna %in% c(1101, 2102)) |>
      dplyr::pull(poblacion)

    expect_equal(resultado, esperado)
  })

  it("falla con un año fuera de la base e informa el rango", {
    expect_error(
      obtener_poblacion(c(1101, 2102), nivel = "comunal", años = 1900),
      "entre 2002 y 2035"
    )
  })
})

describe("obtener_poblacion() argumento base", {
  it("acepta el nombre de una base como texto o la base como dataframe", {
    codigos <- c(1101, 2102)

    suppressMessages({
      como_texto <- obtener_poblacion(
        codigos,
        nivel = "comunal",
        base = "censo_poblacion_2017"
      )
      como_tabla <- obtener_poblacion(
        codigos,
        nivel = "comunal",
        base = censo_poblacion_2017
      )
    })

    expect_equal(como_texto, como_tabla)
  })

  it("acepta un dataframe propio con columnas año y poblacion", {
    base_propia <- data.frame(
      codigo_region = 1,
      codigo_comuna = c(1101, 1107),
      año = 2030,
      poblacion = c(100, 50)
    )

    resultado <- suppressMessages(
      obtener_poblacion(c(1107, 1101), nivel = "comunal", base = base_propia)
    )

    expect_equal(resultado, c(50, 100))
  })

  it("falla si base no es texto ni dataframe", {
    expect_error(
      obtener_poblacion(1101, nivel = "comunal", base = 3),
      "debe ser un dataframe"
    )
  })

  it("falla si el dataframe de base no tiene las columnas requeridas", {
    expect_error(
      obtener_poblacion(1101, nivel = "comunal", base = data.frame(a = 1)),
      "no tiene las columnas requeridas"
    )
  })

  it("falla si el nombre de base no existe", {
    expect_error(
      obtener_poblacion(1101, nivel = "comunal", base = "base_inexistente")
    )
  })
})

describe("obtener_poblacion() con nombres de territorios", {
  it("detecta nombres de comunas, los convierte a código y avisa", {
    suppressMessages(
      expect_message(
        resultado <- suppressWarnings(
          obtener_poblacion("La Florida", años = 2023)
        ),
        "nombres de comunas"
      )
    )

    expect_equal(
      resultado,
      suppressMessages(
        obtener_poblacion(13110, nivel = "comunal", años = 2023)
      )
    )
  })

  it("detecta nombres de regiones, los convierte a código y avisa", {
    suppressMessages(
      expect_message(
        resultado <- suppressWarnings(
          obtener_poblacion("Arica y Parinacota", años = 2023)
        ),
        "nombres de regiones"
      )
    )

    expect_equal(
      resultado,
      suppressMessages(
        obtener_poblacion(15, nivel = "regional", años = 2023)
      )
    )
  })
})
