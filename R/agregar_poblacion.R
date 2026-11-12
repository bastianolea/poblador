#' Agregar población de Chile a datos existentes
#'
#' Agrega cifras de población oficiales a datos territoriales de Chile. Esta función opera sobre tablas de datos (_dataframes_) agregando una nueva columna llamada `poblacion`, y se espeta que estos datos tengan columnas `nombre_comuna`, `codigo_comuna`, `nombre_region` o `codigo_region`, como en la tabla [territorial::territorios] del [paquete de R {territorial}](https://bastianolea.github.io/territorial). Para obtener la población de vectores, usar [obtener_poblacion()].
#'
#' Se puede especificar la base de datos de a utilizar entre las que ofrece este paquete (revísalas con [poblador::datos()]), o una distinta que siga las mismas convenciones.
#'
#' @param datos Dataframe al que deseas agregar población
#' @param nivel Nivel del dato a agregar. Puede ser "regional", "comunal" o "nacional", pero si no se indica, se infiere a partir de los datos.
#' @param años Año de la población, para las bases de población que cubren múltiples años.
#' @param base Base de datos de población a utilizar. Por defecto es [poblador::censo_poblacion_proyeccion]. Ver [poblador::datos()] para una lista de fuentes de datos posibles.
#' @param nombre Nombre de la columna de población a agregar. Por defecto es `poblacion`.
#'
#' @seealso [poblador::obtener_poblacion()] para obtener poblaciones de vectores con códigos o nombres de unidades territoriales. Ver [poblador::datos()] para una lista de fuentes de datos posibles.
#' @export
#'
#' @examples
#' # tabla de datos con un par de comunas: el nivel comunal se detecta
#' # desde la columna `codigo_comuna`
#' comunas <- territorial::territorios |>
#'   dplyr::filter(codigo_comuna %in% c(1101, 2102)) |>
#'   dplyr::select(nombre_comuna, codigo_comuna)
#'
#' comunas |>
#'   agregar_poblacion(años = 2023)
#'
#' # especificar el nivel y usar otra base de datos
#' comunas |>
#'   agregar_poblacion(nivel = "comunal", base = censo_poblacion_2017)
#'
#' # tabla de datos con un par de regiones: el nivel regional se detecta
#' # desde la columna `codigo_region`
#' regiones <- territorial::territorios |>
#'   dplyr::filter(codigo_region %in% c(1, 2)) |>
#'   dplyr::distinct(nombre_region, codigo_region)
#'
#' regiones |>
#'   agregar_poblacion(años = 2023)
#'
agregar_poblacion <- function(
  datos,
  nivel = NULL,
  años = NULL,
  base = "censo_poblacion_proyeccion",
  nombre = "poblacion"
) {
  # nivel <- "comuna"
  # codigo <- c(1101, 2102)
  # años <- c(2023)
  # base = "censo_poblacion_proyeccion"
  # datos <- territorial::territorios |>
  #   dplyr::filter(codigo_comuna %in% codigo) |>
  #   dplyr::select(nombre_comuna, codigo_comuna)

  # nivel <- "comuna"
  # codigo <- c(1101, 2102)
  # años <- NULL
  # base = "censo_poblacion_proyeccion"
  # datos <- territorial::territorios |>
  #   dplyr::filter(codigo_comuna %in% codigo) |>
  #   dplyr::select(nombre_comuna, codigo_comuna)

  # datos <- c(1101, 2102)
  # nivel <- NULL
  # codigo <- NULL

  # browser()

  # datos ----
  # sólo dataframes
  if (is.vector(datos)) {
    cli::cli_abort(
      "Esta función se aplica a tablas de datos. Usa {.fn poblador::obtener_poblacion} para vectores de datos."
    )
  }

  # si ya tiene población
  if (nombre %in% colnames(datos)) {
    cli::cli_abort(
      "Los datos ya tienen una columna {.col {nombre}}. Renómbrala o elimínala antes de agregar población."
    )
  }

  # niveles ----
  if (
    !is.null(nivel) &&
      (!is.character(nivel) || length(nivel) != 1 || is.na(nivel))
  ) {
    cli::cli_abort(
      "El argumento {.arg nivel} debe ser un texto: 'regional', 'comunal' o 'nacional'."
    )
  }

  # si no es válido, corregir
  if (!is.null(nivel) && !nivel %in% c("regional", "comunal", "nacional")) {
    nivel <- dplyr::case_when(
      tolower(nivel) %in% c("regional", "comunal", "nacional") ~ tolower(nivel),
      tolower(nivel) %in% c("región", "region", "codigo_region") ~ "regional",
      tolower(nivel) %in% c("comuna", "codigo_comuna") ~ "comunal",
      tolower(nivel) %in% c("pais", "país", "chile") ~ "nacional"
    )

    # error si no coincide
    if (is.na(nivel)) {
      cli::cli_abort(
        "El nivel especificado no es válido. Debe ser 'regional', 'comunal' o 'nacional'."
      )
    }
  }

  # si no se especifica el nivel, intentar asumir
  if (is.null(nivel)) {
    if ("codigo_comuna" %in% colnames(datos)) {
      nivel <- "comunal"
      cli::cli_alert_warning(
        "Se detectó la columna {.col codigo_comuna}. Se asumirá el nivel {.val comunal}."
      )
    } else if ("codigo_region" %in% colnames(datos)) {
      nivel <- "regional"
      cli::cli_alert_warning(
        "Se detectó la columna {.col codigo_region}. Se asumirá el nivel {.val regional}."
      )
    } else if ("pais" %in% colnames(datos) | "chile" %in% colnames(datos)) {
      nivel <- "nacional"
      cli::cli_alert_warning(
        "Se asumirá el nivel {.val nacional}."
      )
    } else {
      cli::cli_abort(
        "No se pudo detectar el nivel de los datos. Especifica el argumento {.arg nivel} como 'regional', 'comunal' o 'nacional'."
      )
    }
  }

  # códigos ----

  # datos <- "Coyhaique"
  # si los datos son dataframe, usar la columna correspondiente al nivel
  if (nivel == "comunal") {
    if (!"codigo_comuna" %in% colnames(datos)) {
      cli::cli_abort(
        "Los datos no tienen la columna {.col codigo_comuna}. No se puede agregar población a nivel comunal."
      )
    }
    codigo <- datos$codigo_comuna
  } else if (nivel == "regional") {
    if (!"codigo_region" %in% colnames(datos)) {
      cli::cli_abort(
        "Los datos no tienen la columna {.col codigo_region}. No se puede agregar población a nivel regional."
      )
    }
    codigo <- datos$codigo_region
  } else if (nivel == "nacional") {
    codigo <- 0
  }

  # los códigos deben ser numéricos para poder cruzarse con la base
  if (nivel != "nacional" && !is.numeric(codigo)) {
    cli::cli_abort(
      "La columna de códigos del nivel {nivel} debe ser numérica, pero es de clase {.cls {class(codigo)[1]}}."
    )
  }

  # si es comunal o regional, revisar si son válidos
  if (nivel == "comunal") {
    if (!all(territorial::is_codigo_comuna(codigo))) {
      cli::cli_warn(
        "Algunos códigos comunales no son válidos. Se sugiere usar la función {.fn territorial::is_codigo_comuna} para verificar los códigos comunales, o {.fn territorial::validar_comunas} sobre el nombre de las comunas."
      )
    }
  } else if (nivel == "regional") {
    if (!all(territorial::is_codigo_region(codigo))) {
      cli::cli_warn(
        "Algunos códigos regionales no son válidos. Se sugiere usar la función {.fn territorial::is_codigo_region} para verificar los códigos regionales, o {.fn territorial::limpiar_regiones}."
      )
    }
  } else if (nivel == "nacional") {
    codigo <- 0
  }

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
    pob <- tryCatch(get(base), error = function(e) NULL) # obtener desde el paquete
    nombre_base <- as.character(base)
    # si con get no se obtiene, error
    if (!is.data.frame(pob) | length(pob) == 0) {
      cli::cli_abort(
        "El argumento {.arg base} debe ser un dataframe o el nombre de un dataframe válido. No se encontró la base {.val {base}}."
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
  # si no se especifica año, usar el año más reciente de la base
  # si se especifica y no está, error
  if (is.null(años)) {
    if ("año" %in% colnames(datos)) {
      años <- sort(unique(datos$año))
      cli::cli_alert_warning(
        "Considerando los años presentes en la columna {.col año} de los datos."
      )
    } else if (nombre_base == "censo_poblacion_proyeccion") {
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
  }

  {
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

  # revisar si se piden varios años, pero los datos no tienen años
  if (is.data.frame(datos) & length(años) > 1 & !"año" %in% colnames(datos)) {
    cli::cli_abort(
      "Se especificaron varios años en el argumento {.arg años}, pero los datos no tienen columna de año. Agrega la columna {.col año} a tus datos o especifica un solo año."
    )
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

  # pob_filtrada

  # datos |>
  #   agregar_poblacion(especificar o detectar)
  #
  # vector |>
  #   agregar_poblacion(especificar)

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
    dplyr::select(dplyr::all_of(columnas_cruce), poblacion) |>
    # aplicar nombre elegido
    dplyr::rename(!!nombre := poblacion)

  # realizar cruce
  if (length(columnas_cruce) > 0) {
    cruce <- dplyr::left_join(datos, cruzar, by = columnas_cruce)
  } else {
    # nivel nacional sin año en los datos: una sola cifra para todas las filas
    cruce <- dplyr::cross_join(datos, cruzar)
  }

  ## revisar  ----
  # revisar mismas columnas + población
  if (length(cruce) != length(datos) + 1) {
    cli::cli_abort(
      "Se obtuvieron más columnas en la base cruzada ({length(cruce)}) que en los datos originales ({length(datos)}). Revisa los años especificados."
    )
  }
  # revisar mismas filas
  if (nrow(cruce) != nrow(datos)) {
    cli::cli_abort(
      "Se obtuvieron más filas en la base cruzada ({nrow(cruce)}) que los datos originales ({nrow(datos)})."
    )
  }
  if (nrow(cruce) > 0 && all(is.na(cruce[[nombre]]))) {
    cli::cli_abort(
      "No se encontraron cifras de población para los códigos y años especificados. Revisa los argumentos {.arg nivel}, {.arg codigo} y {.arg años}."
    )
  }

  # cruce

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
