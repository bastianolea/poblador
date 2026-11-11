# Paquete `{poblador}`

Datos de población para Chile y funciones para agregar datos
poblacionales fácilmente.

Este paquete ofrece tablas de datos de población desde fuentes oficiales
de Chile, así como funciones para simplificar el uso de estos datos como
complemento a otros conjuntos de datos, por ejemplo, para agregar
población oficial a una tabla de comunas o regiones, entre otros.

El funcionamiento interno de este paquete depende bastante de [mi
paquete `territorial`](https://bastianolea.github.io/territorial/), que
entrega herramientas para trabajar con datos qeu representan comunas y
regiones de Chile.

## Instalación

Instala el paquete a R desde
[R-Universe](https://bastianolea.r-universe.dev/poblador):

``` r

install.packages('poblador', repos = c('https://bastianolea.r-universe.dev'))
```

También puedes instalar desde GitHub:

``` r

# install.packages("pak")
pak::pak("bastianolea/poblador")
```

Para que [poblador](https://bastianolea.github.io/poblador/) funcione,
necesitas tener instalado
[territorial](https://bastianolea.github.io/territorial). Si no lo
tienes, instálalo con:

``` r

install.packages("territorial", repos = "https://bastianolea.r-universe.dev")
```

## Datos de población

La función
[`datos()`](https://bastianolea.github.io/poblador/reference/datos.md)
entrega una lista con todas las fuentes de datos disponibles en el
paquete:

``` r

library(poblador)

datos()
```

Puedes usar estas fuentes de datos para consularlas, cruzarlas con otras
tablas, o su uso principal, que es usarlas para alimentar a la función
[`agregar_poblacion()`](https://bastianolea.github.io/poblador/reference/agregar_poblacion.md),
como veremos a continuación.

## Agregar población a tus datos

La función
[`agregar_poblacion()`](https://bastianolea.github.io/poblador/reference/agregar_poblacion.md)
recibe una tabla de datos o *dataframe* y le agrega una columna
`poblacion` con los datos oficiales de población.

Primero creemos una tabla de datos de ejemplo:

``` r

library(dplyr)

comunas <- tibble::tribble(
  ~nombre_comuna, ~codigo_comuna,
  "Iquique",       1101,
  "Mejillones",    2102
)

comunas
```

``` R
# A tibble: 2 × 2
  nombre_comuna codigo_comuna
  <chr>                 <dbl>
1 Iquique                1101
2 Mejillones             2102
```

Ahora agreguémosle la población:

``` r

library(poblador)

comunas |> 
  agregar_poblacion()
```

``` R
! Se detectó la columna `codigo_comuna`. Se asumirá el nivel "comunal".

! Considerando datos para el año actual (2026). Cambiar con el argumento `años`.

ℹ Agregando datos de población de nivel comunal del año 2026 desde la base `poblador::censo_poblacion_proyeccion()`.

# A tibble: 2 × 3
  nombre_comuna codigo_comuna poblacion
  <chr>                 <dbl>     <dbl>
1 Iquique                1101    234407
2 Mejillones             2102     16291
```

Así de simple! La tabla recibe una columna de población.

Por defecto, la población se obtiene de las [proyecciones oficiales del
INE](https://www.ine.gob.cl/estadisticas-por-tema/demografia-y-poblacion/estimaciones-y-proyecciones-de-poblacion)
(ver
[`poblador::censo_poblacion_proyeccion`](https://bastianolea.github.io/poblador/reference/censo_poblacion_proyeccion.md)).

La función detectó automáticamente que se trataba de datos comunales, y
puso el año actual por defecto.

Puedes agregar datos de otro año, por ejemplo, de 2020:

``` r

comunas |> 
  agregar_poblacion(
    nivel = "comunal",
    años = 2020)
```

``` R
ℹ Agregando datos de población de nivel comunal del año 2020 desde la base `poblador::censo_poblacion_proyeccion()`.

# A tibble: 2 × 3
  nombre_comuna codigo_comuna poblacion
  <chr>                 <dbl>     <dbl>
1 Iquique                1101    223463
2 Mejillones             2102     14776
```

### Datos regionales

Ahora probemos con datos regionales. Creamos una tabla de muestra:

``` r

regiones <- tibble::tribble(
  ~nombre_region, ~codigo_region,
  "Maule",         7,
  "Ñuble",         16,
  "Biobío",        8
)

regiones
```

``` R
# A tibble: 3 × 2
  nombre_region codigo_region
  <chr>                 <dbl>
1 Maule                     7
2 Ñuble                    16
3 Biobío                    8
```

Y agregamos la población con
[`agregar_poblacion()`](https://bastianolea.github.io/poblador/reference/agregar_poblacion.md):

``` r

regiones |> 
  agregar_poblacion()
```

``` R
! Se detectó la columna `codigo_region`. Se asumirá el nivel "regional".

! Considerando datos para el año actual (2026). Cambiar con el argumento `años`.

ℹ Agregando datos de población de nivel regional del año 2026 desde la base `poblador::censo_poblacion_proyeccion()`.

# A tibble: 3 × 3
  nombre_region codigo_region poblacion
  <chr>                 <dbl>     <dbl>
1 Maule                     7   1189907
2 Ñuble                    16    525925
3 Biobío                    8   1694602
```

Nuevamente el nivel territorial se asume automático. Probemos agregando
a las ergiones datos de un Censo oficial específico:

``` r

regiones |> 
  agregar_poblacion(
    nivel = "regional",
    base = censo_poblacion_2017)
```

``` R
! Considerando el año más reciente (2017) para la base "censo_poblacion_2017".

ℹ Agregando datos de población de nivel regional del año 2017 desde la base `poblador::censo_poblacion_2017()`.

# A tibble: 3 × 3
  nombre_region codigo_region poblacion
  <chr>                 <dbl>     <dbl>
1 Maule                     7   1044950
2 Ñuble                    16    480609
3 Biobío                    8   1556805
```

Al agregar datos regionales, el paquete toma los datos comunales y los
suma para obtener los regionales.

### Datos nacionales

También se pueden obtener las poblaciones nacionales: ¿Cuál será la
población de Chile el año 2030?

``` r

dplyr::tibble(país = "Chile") |> 
  agregar_poblacion(
    nivel = "nacional",
    años = 2030)
```

``` R
ℹ Agregando datos de población de nivel nacional del año 2030 desde la base `poblador::censo_poblacion_proyeccion()`.

# A tibble: 1 × 2
  país  poblacion
  <chr>     <dbl>
1 Chile  20735289
```

## Obtener población de territorios

También se puede obtener la población de territorios específicos con
[`obtener_poblacion()`](https://bastianolea.github.io/poblador/reference/obtener_poblacion.md).
Funciona casi idéntico a
[`agregar_poblacion()`](https://bastianolea.github.io/poblador/reference/agregar_poblacion.md),
sólo qeu sobre vectores de datos como nombres o códigos territoriales.

De esta manera podemos obtener fácilmente la población de una comuna,
notando que la función infiere que se trata de una comuna:

``` r

obtener_poblacion("La Florida")
```

``` R
! Se detectó que los datos son nombres de comunas. Se asumirá el nivel "comunal".

! Considerando datos para el año actual (2026). Cambiar con el argumento `años`.

ℹ Agregando datos de población de nivel comunal del año 2026 desde la base `poblador::censo_poblacion_proyeccion()`.

[1] 408195
```

También podemos entregar algunos [códigos únicos
territoriales](https://bastianolea.github.io/territorial/articles/codigos_unicos_territoriales.html):

``` r

obtener_poblacion(c(13102, 13201))
```

``` R
! Se detectó que los datos son códigos comunales. Se asumirá el nivel "comunal".

! Considerando datos para el año actual (2026). Cambiar con el argumento `años`.

ℹ Agregando datos de población de nivel comunal del año 2026 desde la base `poblador::censo_poblacion_proyeccion()`.

[1]  90328 674064
```

Solicitar la proyección de población de un año específico:

``` r

obtener_poblacion("La Florida", años = 2002)
```

``` R
! Se detectó que los datos son nombres de comunas. Se asumirá el nivel "comunal".

ℹ Agregando datos de población de nivel comunal del año 2002 desde la base `poblador::censo_poblacion_proyeccion()`.

[1] 376943
```

Obtener la población de una comuna en el Censo 2017 y en el Censo 2024

``` r

obtener_poblacion(
  "La Florida", 
  base = censo_poblacion_2017)
```

``` R
! Se detectó que los datos son nombres de comunas. Se asumirá el nivel "comunal".

! Considerando el año más reciente (2017) para la base "censo_poblacion_2017".

ℹ Agregando datos de población de nivel comunal del año 2017 desde la base `poblador::censo_poblacion_2017()`.

[1] 366916
```

``` r

obtener_poblacion(
  "La Florida", 
  base = censo_poblacion_2024)
```

``` R
! Se detectó que los datos son nombres de comunas. Se asumirá el nivel "comunal".

! Considerando el año más reciente (2024) para la base "censo_poblacion_2024".

ℹ Agregando datos de población de nivel comunal del año 2024 desde la base `poblador::censo_poblacion_2024()`.

[1] 374836
```
