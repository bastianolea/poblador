# Ejemplo con datos del Registro Social de Hogares

Usando la plataforma [Analista Digital de Información Social
(ADIS)](https://adis.gob.cl/#/) del Ministerio de Desarrollo Social y
Familia, podemos acceder a datos del Registro Social de Hogares (RSH) a
nivel regional y comunal.

Para descargar una tabla de N° total de **personas con dependencia
moderada o severa** por comuna, accedemos a la sección [Estadísticas
socioeconómicas \> Consultas frecuentes de
ADIS](https://adis.gob.cl/#/estadisticas-socioeconomicas/frecuentes),
elegimos el indicador, seleccionamos en *Territorio y desagregación*
“Nacional por Comunas”, y presionamos *Descargar*. También puedes
[descargar aquí los
datos](https://github.com/bastianolea/poblador/raw/main/data-raw/ejemplo_rsh.xlsx)
para seguir el ejemplo.

``` r

library(dplyr)
library(readxl)
library(here)
```

``` r

registro <- read_xlsx(
  here("data-raw/ejemplo_rsh.xlsx"),
  skip = 2) |> 
  select(
    nombre_comuna = 1,
    discapacidad = 2
  )

registro
```

    # A tibble: 346 × 2
       nombre_comuna discapacidad
       <chr>                <dbl>
     1 Iquique               2437
     2 Alto Hospicio         1614
     3 Pozo Almonte           221
     4 Camiña                  NA
     5 Colchane                14
     6 Huara                   29
     7 Pica                   194
     8 Antofagasta           3980
     9 Mejillones             130
    10 Sierra Gorda            15
    # ℹ 336 more rows

Lo primero que vemos en los datos es que existe una fila de totales que
hay que filtrar, y opcionalmente podríamos omitir las filas sin valor en
el conteo de personas.

``` r

registro_1 <- registro |> 
  filter_out(nombre_comuna == "Total") #|> 
  #filter_out(is.na(discapacidad))
```

Como los datos son comunales, conviene [validarlos primero usando
`validar_comunas()`](https://bastianolea.github.io/territorial/reference/validar_comunas.html)
del paquete [territorial](https://bastianolea.github.io/territorial),
que realiza una revisión de los nombres de comunas.

``` r

library(territorial)

registro_1 |> 
  validar_comunas()
```

    ! Resumen: 5 casos de comunas que no conciden con comunas correctamente escritas (ver `territorial::comunas()`): La Calera, Llay Llay, Alto Bío Bío, Ránquil y Treguaco

    ℹ Problemas comunes: 1 caso de comunas popularmente mal escritas: Llay Llay

    ℹ Escrituras alternativas: 1 caso de comunas escritas de una forma no recomendada, aunque válida: Treguaco

    ✖ Validación de comunas: se encontraron 7 problemas con las comunas! Usa `territorial::limpiar_comunas()` para solucionarlos.

Vemos que existen algunos problemas, así que aplicamos una limpieza
automatizada de los nombres con la [función `limpiar_comunas()` de
`{territorial}`](https://bastianolea.github.io/territorial/reference/limpiar_comunas.html).

``` r

registro_2 <- registro_1 |> 
  limpiar_comunas()
```

    ℹ Limpiando 345 nombres de comunas (345 son distintas)

    → Paso 1: confirmar comunas correctas

    ℹ De las 345 comunas distintas, 340 ya eran correctas: Iquique, Alto Hospicio, Pozo Almonte, Camiña, Colchane, Huara, Pica, Antofagasta, Mejillones, Sierra Gorda y 330 comunas más

    → Paso 2: coincidencias por limpieza de texto

    ℹ A partir de la limpieza de texto, se limpiaron 341 de 345 comunas: Iquique, Alto Hospicio, Pozo Almonte, Camiña, Colchane, Huara, Pica, Antofagasta, Mejillones, Sierra Gorda y 331 comunas más

    → Paso 3: casos especiales

    ℹ Se encontraron 2 casos especiales: Calera y Cabo de Hornos

    → Paso 4: coincidencias aproximadas de texto

    ℹ Se limpiaron 3 de 3 comunas por medio de coincidencias aproximadas de texto: Llaillay, Alto Biobío y Trehuaco

    → Conclusión de limpieza de comunas

    ✔ De las 345 comunas distintas, se limpiaron 345 en total (100%)

Ahora que los nombres de comunas fueron validados y limpiados, podemos
[agregar variables territoriales faltantes con
`contextualizar()`](https://bastianolea.github.io/territorial/reference/contextualizar.html),
principalmente las columnas de región y los [códigos únicos
territoriales](https://bastianolea.github.io/territorial/articles/codigos_unicos_territoriales.html)
para un manejo más preciso de los datos.

``` r

registro_3 <- registro_2 |> 
  contextualizar() |> 
  select(-starts_with("provincia"))
```

    ℹ No se especificó la variable: asumiendo columna `nombre_comuna`

    ℹ Columnas agregadas: codigo_region, nombre_region, codigo_provincia, nombre_provincia y codigo_comuna

``` r

registro_3 |> 
  head() |> 
  glimpse()
```

    Rows: 6
    Columns: 7
    $ codigo_region    <dbl> 1, 1, 1, 1, 1, 1
    $ nombre_region    <chr> "Tarapacá", "Tarapacá", "Tarapacá", "Tarapacá", "Tara…
    $ codigo_provincia <dbl> 11, 11, 14, 14, 14, 14
    $ nombre_provincia <chr> "Iquique", "Iquique", "Tamarugal", "Tamarugal", "Tama…
    $ codigo_comuna    <dbl> 1101, 1107, 1401, 1402, 1403, 1404
    $ nombre_comuna    <chr> "Iquique", "Alto Hospicio", "Pozo Almonte", "Camiña",…
    $ discapacidad     <dbl> 2437, 1614, 221, NA, 14, 29

Ahora los datos están en buen estado para seguir trabajando con ellos, y
podemos usar
[`agregar_poblacion()`](https://bastianolea.github.io/poblador/reference/agregar_poblacion.md)
de [poblador](https://bastianolea.github.io/poblador/) para agregar
automáticamente una columna con la población del año 2026 que se
corresponde con los datos que estamos trabajando.

``` r

library(poblador)

registro_4 <- registro_3 |> 
  agregar_poblacion(años = 2026)
```

    ! Se detectó la columna `codigo_comuna`. Se asumirá el nivel "comunal".

    ℹ Agregando datos de población de nivel comunal del año 2026 desde la base `poblador::censo_poblacion_proyeccion()`.

``` r

registro_4 |> 
  select(ends_with("comuna"), discapacidad, poblacion)
```

    # A tibble: 345 × 4
       codigo_comuna nombre_comuna discapacidad poblacion
               <dbl> <chr>                <dbl>     <dbl>
     1          1101 Iquique               2437    234407
     2          1107 Alto Hospicio         1614    149416
     3          1401 Pozo Almonte           221     19198
     4          1402 Camiña                  NA      1365
     5          1403 Colchane                14      1534
     6          1404 Huara                   29      3125
     7          1405 Pica                   194      6402
     8          2101 Antofagasta           3980    450070
     9          2102 Mejillones             130     16291
    10          2103 Sierra Gorda            15      1813
    # ℹ 335 more rows

Teniendo la población de interés (personas con dependencia moderada o
severa en el RSH) y la población de cada comuna, podemos calcular un
simple porcentaje:

``` r

registro_5 <- registro_4 |> 
  mutate(porcentaje = discapacidad/poblacion) |> 
  mutate(porcentaje = scales::label_percent(accuracy = 0.1)(porcentaje))

registro_5 |> 
  select(ends_with("comuna"), discapacidad, poblacion, porcentaje)
```

    # A tibble: 345 × 5
       codigo_comuna nombre_comuna discapacidad poblacion porcentaje
               <dbl> <chr>                <dbl>     <dbl> <chr>
     1          1101 Iquique               2437    234407 1.0%
     2          1107 Alto Hospicio         1614    149416 1.1%
     3          1401 Pozo Almonte           221     19198 1.2%
     4          1402 Camiña                  NA      1365 <NA>
     5          1403 Colchane                14      1534 0.9%
     6          1404 Huara                   29      3125 0.9%
     7          1405 Pica                   194      6402 3.0%
     8          2101 Antofagasta           3980    450070 0.9%
     9          2102 Mejillones             130     16291 0.8%
    10          2103 Sierra Gorda            15      1813 0.8%
    # ℹ 335 more rows
