

# Paquete `{poblador}`

Datos de población para Chile y utilidades relacionadas.

Este paquete ofrece tablas de datos de población desde fuentes oficiales
de Chile, así como funciones para simplificar el uso de estos datos como
complemento a otros conjuntos de datos, por ejemplo, para agregar
población oficial a otras fuentes de datos, calcular tasas de población,
entre otros.

Visita [la página de documentación del paquete para más
información.](https://bastianolea.github.io/poblador/)

``` r
library(poblador)
library(dplyr)
```


    Attaching package: 'dplyr'

    The following objects are masked from 'package:stats':

        filter, lag

    The following objects are masked from 'package:base':

        intersect, setdiff, setequal, union

``` r
# tabla de datos con un par de comunas: el nivel comunal se detecta
# desde la columna `codigo_comuna`
comunas <- territorial::territorios |>
  dplyr::filter(codigo_comuna %in% c(1101, 2102)) |>
  dplyr::select(nombre_comuna, codigo_comuna)

comunas |>
  agregar_poblacion(años = 2023)
```

    ! Se detectó la columna `codigo_comuna`. Se asumirá el nivel "comunal".

    # A tibble: 2 × 3
      nombre_comuna codigo_comuna poblacion
      <chr>                 <dbl>     <dbl>
    1 Iquique                1101    230595
    2 Mejillones             2102     15659

``` r
# especificar el nivel y usar otra base de datos
comunas |>
  agregar_poblacion(nivel = "comunal", base = censo_poblacion_2017)
```

    # A tibble: 2 × 3
      nombre_comuna codigo_comuna poblacion
      <chr>                 <dbl>     <dbl>
    1 Iquique                1101    191468
    2 Mejillones             2102     13467

``` r
# tabla de datos con un par de regiones: el nivel regional se detecta
# desde la columna `codigo_region`
regiones <- territorial::territorios |>
  dplyr::filter(codigo_region %in% c(1, 2)) |>
  dplyr::distinct(nombre_region, codigo_region)

regiones |>
  agregar_poblacion(años = 2023)
```

    ! Se detectó la columna `codigo_region`. Se asumirá el nivel "regional".

    # A tibble: 2 × 3
      nombre_region codigo_region poblacion
      <chr>                 <dbl>     <dbl>
    1 Tarapacá                  1    401588
    2 Antofagasta               2    714142

``` r
# vector de códigos: devuelve un vector con las cifras de población
c(1101, 2102) |>
  agregar_poblacion(nivel = "comunal", años = 2023)
```

    [1] 230595  15659

``` r
# crear una variable de población dentro de una tabla
comunas |>
  dplyr::mutate(poblacion = agregar_poblacion(codigo_comuna, años = 2023))
```

    ! Se detectó que los datos son códigos comunales. Se asumirá el nivel "comunal".

    # A tibble: 2 × 3
      nombre_comuna codigo_comuna poblacion
      <chr>                 <dbl>     <dbl>
    1 Iquique                1101    230595
    2 Mejillones             2102     15659
