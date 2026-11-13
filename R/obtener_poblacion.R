#' Obtener la población oficial de una o varias unidades territoriales (comuna, región o país)
#'
#' A partir del código único territorial de una unidad territorial (comuna, región o país) de Chile (ver [viñeta sobre códigos únicos territoriales](https://bastianolea.github.io/territorial/articles/codigos_unicos_territoriales.html)), esta función obtiene la población correspondiente en un año específico. Esta función opera sobre vectores, retornando un vector con las cifras de población correspondientes en el mismo orden que fueron entregadas. Para _dataframes_, usar [agregar_poblacion()].
#'
#' Se puede especificar la base de datos de a utilizar entre las que ofrece este paquete (revísalas con [poblador::catalogo()]), o una distinta que siga las mismas convenciones.
#'
#'@param datos Vector de datos para obtener su población
#' @param nivel Nivel del dato a obtener. Puede ser "regional", "comunal" o "nacional", pero si no se indica, se infiere a partir de los datos.
#' @param años Año de la población, para las bases de población que cubren múltiples años.
#' @param base Base de datos de población a utilizar. Por defecto es [poblador::censo_poblacion_proyeccion]. Ver [poblador::catalogo()] para una lista de fuentes de datos posibles.
#'
#' @seealso [agregar_poblacion()] para agregar una columna de población sobre dataframes. Ver [poblador::catalogo()] para una lista de fuentes de datos posibles.
#' @returns Vector de las cifras de población correspondientes.
#' @export
#'
#' @examples
#' obtener_poblacion(c(1101, 2102))
#'
#' obtener_poblacion("La Florida", años = 2023)
#'
#' obtener_poblacion("La Florida", base = censo_poblacion_2017)
#'
#' obtener_poblacion("Chile", nivel = "nacional", base = censo_poblacion_2024)
#'
#' # crear una variable de población dentro de una tabla
#' comunas <- territorial::territorios |>
#'   dplyr::filter(codigo_comuna %in% c(1101, 2102)) |>
#'   dplyr::select(nombre_comuna, codigo_comuna)
#'
#' comunas |>
#'   dplyr::mutate(poblacion = obtener_poblacion(codigo_comuna, años = 2023))

obtener_poblacion <- function(
  datos,
  nivel = NULL,
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
  nivel <- tolower(nivel)

  # si no es válido, corregir
  if (!is.null(nivel) && !nivel %in% c("regional", "comunal", "nacional")) {
    nivel <- dplyr::case_when(
      nivel %in% c("región", "region", "codigo_region") ~ "regional",
      nivel %in% c("comuna", "codigo_comuna") ~ "comunal",
      nivel %in% c("pais", "país", "chile") ~ "nacional"
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

    if (all(es_nombre_comuna & !es_nombre_region)) {
      # es nombre comuna
      nivel <- "comunal"
      cli::cli_alert_warning(
        "Se detectó que los datos son nombres de comunas. Se asumirá el nivel {.val comunal}."
      )
    } else if (all(es_nombre_comuna & es_nombre_region)) {
      # indefinido
      cli::cli_abort(
        "No se pudo detectar el nivel de los datos (ambigüedad en nombres de comuna/región). Especifica el argumento {.arg nivel} como 'regional', 'comunal' o 'nacional'."
      )
    } else if (all(es_nombre_region)) {
      # es nombre region
      nivel <- "regional"
      cli::cli_alert_warning(
        "Se detectó que los datos son nombres de regiones. Se asumirá el nivel {.val regional}."
      )
    } else if (all(es_codigo_comuna)) {
      # es codigo comuna
      nivel <- "comunal"
      cli::cli_alert_warning(
        "Se detectó que los datos son códigos comunales. Se asumirá el nivel {.val comunal}."
      )
    } else if (all(es_codigo_region)) {
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
      # los códigos inválidos no abortan: retornan NA y se advierte
      if (!all(territorial::is_codigo_comuna(datos))) {
        cli::cli_warn(
          "Algunos códigos comunales no son válidos y retornarán {.val NA}. Revisa los datos: usa {.fn territorial::validar_comunas} o {.fn territorial::limpiar_comunas}."
        )
      }
    } else if (nivel == "regional") {
      if (!all(territorial::is_codigo_region(datos))) {
        cli::cli_warn(
          "Algunos códigos regionales no son válidos y retornarán {.val NA}. Revisa los datos: usa {.fn territorial::validar_regiones} o {.fn territorial::limpiar_regiones}."
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
    # obtener desde el paquete, o si no, desde el entorno del usuario
    entorno_usuario <- parent.frame()
    pob <- tryCatch(
      getExportedValue("poblador", base),
      error = function(e) {
        tryCatch(get(base, envir = entorno_usuario), error = function(e) NULL)
      }
    )
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
