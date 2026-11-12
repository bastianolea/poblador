# Agregar población de Chile a datos existentes

Agrega cifras de población oficiales a datos territoriales de Chile.
Esta función opera sobre tablas de datos (*dataframes*) agregando una
nueva columna llamada `poblacion`, y se espeta que estos datos tengan
columnas `nombre_comuna`, `codigo_comuna`, `nombre_region` o
`codigo_region`, como en la tabla
[territorial::territorios](https://bastianolea.github.io/territorial/reference/territorios.html)
del [paquete de R
territorial](https://bastianolea.github.io/territorial). Para obtener la
población de vectores, usar
[`obtener_poblacion()`](https://bastianolea.github.io/poblador/reference/obtener_poblacion.md).

## Uso

``` r
agregar_poblacion(
  datos,
  nivel = NULL,
  años = NULL,
  base = "censo_poblacion_proyeccion",
  nombre = "poblacion"
)
```

## Argumentos

- datos:

  Dataframe al que deseas agregar población

- nivel:

  Nivel del dato a agregar. Puede ser "regional", "comunal" o
  "nacional", pero si no se indica, se infiere a partir de los datos.

- años:

  Año de la población, para las bases de población que cubren múltiples
  años.

- base:

  Base de datos de población a utilizar. Por defecto es
  [censo_poblacion_proyeccion](https://bastianolea.github.io/poblador/reference/censo_poblacion_proyeccion.md).
  Ver
  [`datos()`](https://bastianolea.github.io/poblador/reference/datos.md)
  para una lista de fuentes de datos posibles.

- nombre:

  Nombre de la columna de población a agregar. Por defecto es
  `poblacion`.

## Detalles

Se puede especificar la base de datos de a utilizar entre las que ofrece
este paquete (revísalas con
[`datos()`](https://bastianolea.github.io/poblador/reference/datos.md)),
o una distinta que siga las mismas convenciones.

## Ver también

[`obtener_poblacion()`](https://bastianolea.github.io/poblador/reference/obtener_poblacion.md)
para obtener poblaciones de vectores con códigos o nombres de unidades
territoriales. Ver
[`datos()`](https://bastianolea.github.io/poblador/reference/datos.md)
para una lista de fuentes de datos posibles.

## Ejemplos

``` r
# tabla de datos con un par de comunas: el nivel comunal se detecta
# desde la columna `codigo_comuna`
comunas <- territorial::territorios |>
  dplyr::filter(codigo_comuna %in% c(1101, 2102)) |>
  dplyr::select(nombre_comuna, codigo_comuna)

comunas |>
  agregar_poblacion(años = 2023)
#> ! Se detectó la columna `codigo_comuna`. Se asumirá el nivel "comunal".
#> ℹ Agregando datos de población de nivel comunal del año 2023 desde la base `poblador::censo_poblacion_proyeccion()`.
#> # A tibble: 2 × 3
#>   nombre_comuna codigo_comuna poblacion
#>   <chr>                 <dbl>     <dbl>
#> 1 Iquique                1101    230595
#> 2 Mejillones             2102     15659

# especificar el nivel y usar otra base de datos
comunas |>
  agregar_poblacion(nivel = "comunal", base = censo_poblacion_2017)
#> ! Considerando el año más reciente (2017) para la base "censo_poblacion_2017".
#> ℹ Agregando datos de población de nivel comunal del año 2017 desde la base `poblador::censo_poblacion_2017()`.
#> # A tibble: 2 × 3
#>   nombre_comuna codigo_comuna poblacion
#>   <chr>                 <dbl>     <dbl>
#> 1 Iquique                1101    191468
#> 2 Mejillones             2102     13467

# tabla de datos con un par de regiones: el nivel regional se detecta
# desde la columna `codigo_region`
regiones <- territorial::territorios |>
  dplyr::filter(codigo_region %in% c(1, 2)) |>
  dplyr::distinct(nombre_region, codigo_region)

regiones |>
  agregar_poblacion(años = 2023)
#> ! Se detectó la columna `codigo_region`. Se asumirá el nivel "regional".
#> ℹ Agregando datos de población de nivel regional del año 2023 desde la base `poblador::censo_poblacion_proyeccion()`.
#> # A tibble: 2 × 3
#>   nombre_region codigo_region poblacion
#>   <chr>                 <dbl>     <dbl>
#> 1 Tarapacá                  1    401588
#> 2 Antofagasta               2    714142
```
