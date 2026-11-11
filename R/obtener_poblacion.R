obtener_poblacion <- function(
  datos,
  nivel = NULL,
  codigo = NULL,
  años = NULL,
  base = "censo_poblacion_proyeccion"
) {
  # datos <- c(1101, 2102)
  # nivel <- NULL

  if (is.data.frame(datos)) {
    cli::cli_abort(
      "Esta función se aplica a vectores de datos. Usa {.fn poblador::agregar_poblacion} para tablas de datos."
    )
  }

  # niveles ----
  # si no es válido, corregir
  if (!is.null(nivel) && !nivel %in% c("regional", "comunal", "nacional")) {
    nivel <- dplyr::case_when(
      tolower(nivel) %in% c("región", "region", "codigo_region") ~ "regional",
      tolower(nivel) %in% c("comuna", "codigo_comuna") ~ "comunal",
      tolower(nivel) %in% c("pais", "país", "chile") ~ "nacional"
    )

    # error si no coincide
    if (!nivel %in% c("regional", "comunal", "nacional")) {
      cli::cli_abort(
        "El nivel especificado no es válido. Debe ser 'regional', 'comunal' o 'nacional'."
      )
    }
  }

  # averiguar cositas
  # según si es o no es texto

  ## asumir ----
  # # tests:
  # nivel <- NULL; datos <- 1101
  # nivel <- NULL; datos <- "1101"
  # nivel <- NULL; datos <- "Lampa"
  # nivel <- NULL; datos <- "Los Ríos"
  # nivel <- NULL; datos <- 13
  # nivel <- NULL; datos <- "Coquimbo"

  es_numerico <- is.numeric(datos)

  # si no se especifica el nivel, intentar asumir
  if (is.null(nivel)) {
    {
      es_codigo_comuna <- es_numerico &
        territorial::is_codigo_comuna(as.numeric(datos))
      es_codigo_region <- es_numerico &
        territorial::is_codigo_region(as.numeric(datos))
      es_nombre_comuna <- !es_numerico &
        territorial::is_nombre_comuna(as.character(datos))
      es_nombre_region <- !es_numerico &
        territorial::is_nombre_region(as.character(datos))
    } |>
      suppressWarnings()

    if (es_nombre_comuna & !es_nombre_region) {
      # es nombre comuna
      nivel <- "comunal"
      cli::cli_alert_warning(
        "Se detectó que los datos son nombres de comunas. Se asumirá el nivel {.val comunal}."
      )
    } else if (es_nombre_comuna & es_nombre_region) {
      # indefinido
      cli::cli_abort(
        "No se pudo detectar el nivel de los datos (ambigüedad en nombres de comuna/región). Especifica el argumento {.arg nivel} como 'regional', 'comunal' o 'nacional'."
      )
    } else if (es_nombre_region) {
      # es nombre region
      nivel <- "regional"
      cli::cli_alert_warning(
        "Se detectó que los datos son nombres de regiones. Se asumirá el nivel {.val regional}."
      )
    } else if (es_codigo_comuna) {
      # es codigo comuna
      nivel <- "comunal"
      cli::cli_alert_warning(
        "Se detectó que los datos son códigos comunales. Se asumirá el nivel {.val comunal}."
      )
    } else if (es_codigo_region) {
      # es codigo region
      nivel <- "regional"
      cli::cli_alert_warning(
        "Se detectó que los datos son códigos regionales. Se asumirá el nivel {.val regional}."
      )
    } else {
      cli::cli_abort(
        "No se pudo detectar el nivel de los datos. Especifica el argumento {.arg nivel} como 'regional', 'comunal' o 'nacional'."
      )
    }
  }

  nivel

  # códigos ----
  # si son textos, convertir a códigos
  if (!es_numerico) {
    if (nivel == "comunal") {
      codigo <- territorial::as_codigo_comuna(datos)
    } else if (nivel == "regional") {
      codigo <- territorial::as_codigo_region(datos)
    } else if (nivel == "nacional") {
      codigo <- 0
    }
  } else if (es_numerico) {
    # si es numérico, validar
    if (nivel == "comunal") {
      if (!territorial::is_codigo_comuna(datos)) {
        cli::cli_abort(
          "Los datos no son códigos comunales válidos. Revisa los datos: usa {.fn territorial::validar_comunas} o {.fn territorial::limpiar_comunas}."
        )
      }
    } else if (nivel == "regional") {
      if (!territorial::as_codigo_region(datos)) {
        cli::cli_abort(
          "Los datos no son códigos regionales válidos. Revisa los datos: usa {.fn territorial::validar_regiones} o {.fn territorial::limpiar_regiones}."
        )
      }
    }
    # los datos son códigos
    codigo <- datos
  }

  codigo

  # base ----
  # validar base de datos entregada
  if (!is.data.frame(base) & !is.character(base)) {
    cli::cli_abort(
      "El argumento {.arg base} debe ser un dataframe o un nombre de dataframe disponible en el entorno."
    )
  }

  # si el argumento base es un dataframe, usarlo, si es texto, coincidirlo con el del paquete,
  # si es texto y no coincide, error
  if (is.data.frame(base)) {
    pob <- base
    nombre_base <- deparse(substitute(base))
  } else if (is.character(base)) {
    pob <- get(base) # obtener desde el paquete
    nombre_base <- as.character(base)
    # si con get no se obtiene, error
    if (!is.data.frame(pob) | length(pob) == 0) {
      cli::cli_abort(
        "El argumento {.arg base} debe ser un dataframe o el nombre de un dataframe válido."
      )
    }
  }

  # confirmar columnas necesarias
  if (is.data.frame(base)) {
    if (!all(c("año", "poblacion") %in% colnames(base))) {
      cli::cli_abort(
        "El dataframe especificado en {.arg base} no tiene las columnas requeridas: {.val año} y {.val poblacion}."
      )
    }
  }

  # años ----
  # sólo se puede pedir un año
  if (length(años) > 1) {
    cli::cli_abort(
      "Si los datos son un vector, sólo se puede especificar un año en el argumento {.arg años}."
    )
  }

  # si no se especifica año, usar el año más reciente de la base
  # si se especifica y no está, error
  if (is.null(años)) {
    if (nombre_base == "censo_poblacion_proyeccion") {
      años <- as.integer(format(Sys.Date(), "%Y"))
      cli::cli_alert_warning(
        "Considerando datos para el año actual ({años}). Cambiar con el argumento {.arg años}."
      )
    } else {
      años <- max(pob$año)
      cli::cli_alert_warning(
        "Considerando el año más reciente ({años}) para la base {.val {nombre_base}}."
      )
    }
  } else {
    if (!all(años %in% pob$año)) {
      texto_años <- ifelse(
        dplyr::n_distinct(pob$año) > 1,
        glue::glue("entre {min(pob$año)} y {max(pob$año)}"),
        glue::glue("{unique(pob$año)}")
      )

      cli::cli_abort(
        "El año especificado no está disponible en la base de datos de población. Para la base {.val {nombre_base}}, los años disponibles son: {texto_años}."
      )
    }
  }

  # revisar si se puden más años que los disponibles en datos
  if (is.data.frame(datos) & "año" %in% colnames(datos)) {
    if (length(años) > 1 & !all(años %in% datos$año)) {
      cli::cli_abort(
        "Los años especificados en el argumento {.arg años} no están disponibles en los datos. Cambia el argumento o revisa tus datos."
      )
    }
  }

  # consulta ----
  # los datos vienen en el menor nivel: comuna, así que los niveles mayores se suman
  if (nivel == "comunal") {
    pob_filtrada <- pob |>
      dplyr::filter(codigo_comuna %in% codigo) |>
      dplyr::filter(año %in% años)
  } else if (nivel == "regional") {
    pob_filtrada <- pob |>
      dplyr::filter(codigo_region %in% codigo) |>
      dplyr::filter(año %in% años) |>
      dplyr::group_by(codigo_region, año) |>
      dplyr::summarize(poblacion = sum(poblacion), .groups = "drop")
  } else if (nivel == "nacional") {
    pob_filtrada <- pob |>
      dplyr::filter(año %in% años) |>
      dplyr::group_by(año) |>
      dplyr::summarize(poblacion = sum(poblacion), .groups = "drop")
  }

  # cruce ----
  # columnas para unir: código del nivel, y año si los datos lo tienen
  columna_codigo <- switch(
    nivel,
    "comunal" = "codigo_comuna",
    "regional" = "codigo_region",
    "nacional" = NULL
  )
  columnas_cruce <- c(columna_codigo, if ("año" %in% colnames(datos)) "año")

  # tabla con la población a cruzar con `datos`
  cruzar <- pob_filtrada |>
    dplyr::ungroup() |>
    dplyr::select(dplyr::all_of(columnas_cruce), poblacion)

  # realizar cruce
  if (nivel == "comunal") {
    cruce <- cruzar$poblacion[match(
      codigo,
      cruzar$codigo_comuna
    )]
  } else if (nivel == "regional") {
    cruce <- cruzar$poblacion[match(
      codigo,
      cruzar$codigo_region
    )]
  } else if (nivel == "nacional") {
    # la misma cifra nacional para cada elemento del vector
    cruce <- rep(cruzar$poblacion, length(datos))
  }

  ## revisar  ----
  # revisar NA
  if (all(is.na(cruce))) {
    cli::cli_abort(
      "No se encontraron cifras de población. Revisa los argumentos {.arg nivel}, {.arg codigo} y {.arg años}."
    )
  }

  # revisar mismo largo
  if (length(cruce) != length(datos)) {
    cli::cli_abort(
      "Se obtuvieron más cifras ({length(cruce)}) que las entregadas ({length(datos)})."
    )
  }

  # mensaje ----
  texto_años <- ifelse(
    length(años) > 1,
    glue::glue("para los años entre {min(años)} y {max(años)}"),
    glue::glue("del año {unique(años)}")
  )
  cli::cli_alert_info(
    "Agregando datos de población de nivel {nivel} {texto_años} desde la base {.fun poblador::{nombre_base}}."
  )

  # retornar tabla si venía dataframe, cifras si era vector
  if (is.data.frame(datos)) {
    return(cruce)
  } else if (is.vector(datos)) {
    return(cruce)
  }
}
