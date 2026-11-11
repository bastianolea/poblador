#' Lista de fuentes de datos disponibles
#'
#' Imprime en la consola una lista de todas las fuentes de datos incluídas en el paquete.
#'
#' @export
#' @seealso [agregar_poblacion()] y [obtener_poblacion()] para hacer uso de estas fuentes de datos sobre dataframes y vectores, respectivamente.
#' @examples
#' datos()
#'
datos <- function() {
  cli::cli_alert_info("Función en construcción 😢")
  # # no funciona esta mierda
  #
  # resultados <- utils::data(package = "poblador")$results
  # tabla <- resultados[, "Item"]
  #
  # tools::Rd2txt(tabla[1])
  #
  # # títulos desde la documentación (.Rd) del paquete instalado
  # titulos_rd <- tryCatch(
  #   {
  #     rd <- tools::Rd_db("poblador")
  #     names(rd) <- sub("\\.Rd$", "", names(rd))
  #     vapply(
  #       rd,
  #       \(x) {
  #         tags <- vapply(x, \(y) attr(y, "Rd_tag") %||% "", character(1))
  #         trimws(paste(unlist(x[[which(tags == "\\title")]]), collapse = ""))
  #       },
  #       character(1)
  #     )
  #   },
  #   error = \(e) character()
  # )
  # # si no hay documentación disponible, se usa el nombre de la tabla
  # titulo <- unname(titulos_rd[tabla])
  # titulo <- ifelse(is.na(titulo), tabla, titulo)
  #
  # datos <- lapply(tabla, get)
  # filas <- lapply(datos, nrow) |> unlist()
  # nombres <- lapply(datos, names)
  # columnas <- lapply(nombres, length) |> unlist()
  #
  # años <- purrr::map(datos, \(tabla) {
  #   años <- unique(tabla$año)
  #   ifelse(
  #     length(años) == 1,
  #     as.character(años),
  #     paste(range(años), collapse = "-")
  #   )
  # }) |>
  #   purrr::list_c()
  #
  # datos <- dplyr::tibble(
  #   tabla,
  #   titulo,
  #   datos,
  #   filas,
  #   columnas,
  #   nombres,
  #   años
  # )
  #
  # cli::cli_h1("Datos disponibles en {.pkg poblador}")
  #
  # datos |>
  #   split(tabla) |>
  #   purrr::walk(
  #     \(d) {
  #       # d <- datos[1, ]
  #       cli::cli_h2(d$titulo)
  #       cli::cli_ul()
  #       cli::cli_li("Tabla de {d$filas} y {d$columnas} columnas")
  #       cli::cli_li("Año: {d$años}")
  #       cli::cli_end()
  #       cli::cat_line()
  #     }
  #   )
}
