#' Población a nivel comunal de Chile (2017)
#'
#' Cifras de población según el Censo 2017.
#'
#' Los datos fueron obtenidos [desde el sitio web del INE](https://www.ine.gob.cl/estadisticas-por-tema/demografia-y-poblacion/censo-de-poblacion-y-vivienda).
#'
#'
#' @format Un data frame con 346 filas y 8 columnas:
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
#' @source <https://www.ine.gob.cl/estadisticas-por-tema/demografia-y-poblacion/censo-de-poblacion-y-vivienda>
"poblacion_2017"
