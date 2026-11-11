obtener_poblacion <- function() {
  if (is.data.frame(datos)) {
    cli::cli_abort(
      "Esta función se aplica a vectores de datos. Usa {.fn poblador::agregar_poblacion} para tablas de datos."
    )
  }
}
