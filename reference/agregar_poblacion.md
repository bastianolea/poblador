# Agregar población a códigos comunales

Esta función sirve para agregar cifras de población oficiales a comunas
de Chile. Se debe entregar un código comunal válido, como los que
aparecen en
[territorial::territorios](https://bastianolea.github.io/territorial/reference/territorios.html).
Se debe especificar la base de datos de población a utilizar entre
varias: Proyecciones del Censo (base 2017), Censo 2024 (población
censada). Se puede consultar la población para más de una comuna a la
vez, para un mismo o distintos años.

## Usage

``` r
agregar_poblacion(codigo_comuna, año, base = "proyección")
```

## Arguments

- año:

  Opcional: si se va a elegir proyecciones de población, año de la
  estimación.

- base:

  Base de datos de población a utilizar. Por defecto es
  [censo_poblacion_proyeccion](https://bastianolea.github.io/poblador/reference/censo_poblacion_proyeccion.md).

- nivel:

  Nivel del dato a agregar. Puede ser "regional", "comunal" o
  "nacional".

- codigo:

  Códigos de las comunas o regiones para entregar su población. Ver
  [territorial::territorios](https://bastianolea.github.io/territorial/reference/territorios.html).
  Si es país, se omite.

## Value

Vector con cifras de población para la/s comuna/s consultadas.

## Examples

``` r
# varios años para una comuna
agregar_poblacion(codigo_comuna = 1101, año = 2020:2026)
#> Error in is_codigo_comuna(codigo_comuna): could not find function "is_codigo_comuna"

# varias comunas para un año
agregar_poblacion(codigo_comuna = c(1101, 1107, 1401, 1402, 1403), año = 2026)
#> Error in is_codigo_comuna(codigo_comuna): could not find function "is_codigo_comuna"

# crear variable población para una tabla de datos
territorial::territorios |>
  dplyr::mutate(poblacion = agregar_poblacion(codigo_comuna, 2026))
#> Error in dplyr::mutate(territorial::territorios, poblacion = agregar_poblacion(codigo_comuna,     2026)): ℹ In argument: `poblacion = agregar_poblacion(codigo_comuna, 2026)`.
#> Caused by error in `is_codigo_comuna()`:
#> ! could not find function "is_codigo_comuna"
```
