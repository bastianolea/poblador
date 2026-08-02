#' Población en situación de pobreza por ingresos a nivel comunal (2024)
#'
#' Cifras de población en situación de pobreza, calculadas por el Ministerio de Desarrollo Social y Familia a partir de datos de la Encuesta de Caracterización Socioeconómica Nacional 2024 (Casen 2024), por medio de la aplicación de la metodología de áreas pequeñas o SAE.
#'
#' Los datos fueron obtenidos [desde el sitio web de Mideso](https://bidat.gob.cl/directorio/Indicadores%20comunales%20en%20base%20a%20CASEN/estimaciones-de-pobreza-comunal-2024). Para más información, revisar el [reporte metodológico](https://bidat.gob.cl/details/ficha/dato/informe-metodologico-sae-2024).
#'
#' @format Un data frame con 345 filas y 8 columnas:
#' \describe{
#'   \item{codigo_region}{Código único territorial de las regiones de Chile (número entre 1 y 16)}
#'   \item{nombre_region}{Nombre de las regiones de Chile}
#'   \item{codigo_provincia}{Código único territorial de las provincias de Chile}
#'   \item{nombre_provincia}{Nombre de las provincias de Chile}
#'   \item{codigo_comuna}{Código único territorial de las comunas de Chile}
#'   \item{nombre_comuna}{Nombre de las comunas de Chile}
#'   \item{año}{Año al que corresponde la población}
#'   \item{poblacion}{Cantidad de habitantes para la comuna y el año correspondientes}
#' }
#' @source <https://bidat.gob.cl/directorio/Indicadores%20comunales%20en%20base%20a%20CASEN/estimaciones-de-pobreza-comunal-2024>
"mideso_pobreza_ingresos"
