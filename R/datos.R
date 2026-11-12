#' Fuentes de datos disponibles
#'
#' Imprime en la consola una lista de todas las fuentes de datos incluídas en el paquete, con su información. Útil para saber qué está disponible en el paquete.
#'
#' @export
#' @seealso [agregar_poblacion()] y [obtener_poblacion()] para hacer uso de estas fuentes de datos sobre dataframes y vectores, respectivamente.
#' @examples
#' datos()
#'
datos <- function() {
  cli::cli_h1("Datos disponibles en {.pkg poblador}")

  purrr::walk(catalogo, \(info) {
    # info <- catalogo[[1]]
    base <- get(info$objeto)

    texto_años <- ifelse(
      dplyr::n_distinct(base$año) > 1,
      glue::glue("entre {min(base$año)} y {max(base$año)}"),
      glue::glue("{unique(base$año)}")
    )

    n_comunas <- territorial::contar_comunas(base) |> suppressMessages()

    cli::cli_h2(info$titulo)
    cli::cli_ul()
    cli::cli_li("Objeto: {.code {info$objeto}}")
    cli::cli_li("Tabla de {nrow(base)} y {length(base)} columnas")
    if (!is.null(info$descr)) {
      cli::cli_li(info$descr)
    }
    cli::cli_li("Años: {texto_años}")
    cli::cli_li("Cantidad de comunas únicas: {n_comunas}")
    cli::cli_li("Fuente: {info$fuente}, {.url {info$url}}")
    cli::cli_end()
    cli::cat_line()
  })

  return(invisible(names(catalogo)))
}
