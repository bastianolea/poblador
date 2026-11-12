# Gráfico de población regional de Chile

``` r

library(poblador)
library(dplyr)
```

El paquete incluye tablas de datos de los últimos censos de Chile:

``` r

library(poblador)

censo_poblacion_2024
```

    # A tibble: 346 × 8
       codigo_region nombre_region codigo_provincia nombre_provincia codigo_comuna
               <dbl> <chr>                    <dbl> <chr>                    <dbl>
     1             1 Tarapacá                    11 Iquique                   1101
     2             1 Tarapacá                    11 Iquique                   1107
     3             1 Tarapacá                    14 Tamarugal                 1401
     4             1 Tarapacá                    14 Tamarugal                 1405
     5             1 Tarapacá                    14 Tamarugal                 1404
     6             1 Tarapacá                    14 Tamarugal                 1402
     7             1 Tarapacá                    14 Tamarugal                 1403
     8             2 Antofagasta                 22 El Loa                    2201
     9             2 Antofagasta                 21 Antofagasta               2102
    10             2 Antofagasta                 22 El Loa                    2203
    # ℹ 336 more rows
    # ℹ 3 more variables: nombre_comuna <chr>, año <dbl>, poblacion <int>

``` r

censo_poblacion_2017
```

    # A tibble: 346 × 8
       codigo_region nombre_region codigo_provincia nombre_provincia codigo_comuna
               <dbl> <chr>                    <dbl> <chr>                    <dbl>
     1             1 Tarapacá                    11 Iquique                   1101
     2             1 Tarapacá                    11 Iquique                   1107
     3             1 Tarapacá                    14 Tamarugal                 1401
     4             1 Tarapacá                    14 Tamarugal                 1402
     5             1 Tarapacá                    14 Tamarugal                 1403
     6             1 Tarapacá                    14 Tamarugal                 1404
     7             1 Tarapacá                    14 Tamarugal                 1405
     8             2 Antofagasta                 21 Antofagasta               2101
     9             2 Antofagasta                 21 Antofagasta               2102
    10             2 Antofagasta                 21 Antofagasta               2103
    # ℹ 336 more rows
    # ℹ 3 more variables: nombre_comuna <chr>, año <dbl>, poblacion <dbl>

También incluye las últimas proyecciones de población disponibles a
nivel de comuna, que son en base al Censo 2017, y que pueden filtrarse
por año:

``` r

library(dplyr)

censo_poblacion_proyeccion |> 
  filter(año == 2030)
```

    # A tibble: 346 × 8
       codigo_region nombre_region codigo_provincia nombre_provincia codigo_comuna
               <dbl> <chr>                    <dbl> <chr>                    <dbl>
     1             1 Tarapacá                    11 Iquique                   1101
     2             1 Tarapacá                    11 Iquique                   1107
     3             1 Tarapacá                    14 Tamarugal                 1401
     4             1 Tarapacá                    14 Tamarugal                 1402
     5             1 Tarapacá                    14 Tamarugal                 1403
     6             1 Tarapacá                    14 Tamarugal                 1404
     7             1 Tarapacá                    14 Tamarugal                 1405
     8             2 Antofagasta                 21 Antofagasta               2101
     9             2 Antofagasta                 21 Antofagasta               2102
    10             2 Antofagasta                 21 Antofagasta               2103
    # ℹ 336 more rows
    # ℹ 3 more variables: nombre_comuna <chr>, año <dbl>, poblacion <dbl>

Finalmente, el paquete incluye datos sociales relacionados a población,
como son las estimaciones de pobreza por ingreso y pobreza
multidimensional en base a Casen 2024:

``` r

mideso_pobreza_ingresos
```

    # A tibble: 345 × 8
       codigo_region nombre_region codigo_provincia nombre_provincia codigo_comuna
               <dbl> <chr>                    <dbl> <chr>                    <dbl>
     1             1 Tarapacá                    11 Iquique                   1101
     2             1 Tarapacá                    11 Iquique                   1107
     3             1 Tarapacá                    14 Tamarugal                 1401
     4             1 Tarapacá                    14 Tamarugal                 1402
     5             1 Tarapacá                    14 Tamarugal                 1403
     6             1 Tarapacá                    14 Tamarugal                 1404
     7             1 Tarapacá                    14 Tamarugal                 1405
     8             2 Antofagasta                 21 Antofagasta               2101
     9             2 Antofagasta                 21 Antofagasta               2102
    10             2 Antofagasta                 21 Antofagasta               2103
    # ℹ 335 more rows
    # ℹ 3 more variables: nombre_comuna <chr>, año <dbl>, poblacion <dbl>

``` r

mideso_pobreza_multi
```

    # A tibble: 345 × 8
       codigo_region nombre_region codigo_provincia nombre_provincia codigo_comuna
               <dbl> <chr>                    <dbl> <chr>                    <dbl>
     1             1 Tarapacá                    11 Iquique                   1101
     2             1 Tarapacá                    11 Iquique                   1107
     3             1 Tarapacá                    14 Tamarugal                 1401
     4             1 Tarapacá                    14 Tamarugal                 1402
     5             1 Tarapacá                    14 Tamarugal                 1403
     6             1 Tarapacá                    14 Tamarugal                 1404
     7             1 Tarapacá                    14 Tamarugal                 1405
     8             2 Antofagasta                 21 Antofagasta               2101
     9             2 Antofagasta                 21 Antofagasta               2102
    10             2 Antofagasta                 21 Antofagasta               2103
    # ℹ 335 more rows
    # ℹ 3 more variables: nombre_comuna <chr>, año <dbl>, poblacion <dbl>

Para calcular la población regional de Chile, realizamos una suma
agrupada:

``` r

pob_regional <- poblador::censo_poblacion_2024 |> 
  group_by(nombre_region, codigo_region) |> 
  summarize(poblacion = sum(poblacion)) |> 
  ungroup() |> 
  territorial::ordenar_regiones(invertir = TRUE)
```

    `summarise()` has regrouped the output.
    ℹ Summaries were computed grouped by nombre_region and codigo_region.
    ℹ Output is grouped by nombre_region.
    ℹ Use `summarise(.groups = "drop_last")` to silence this message.
    ℹ Use `summarise(.by = c(nombre_region, codigo_region))` for per-operation
      grouping (`?dplyr::dplyr_by`) instead.

Luego generamos un gráfico de barras:

``` r

library(ggplot2)
library(scales)

pob_regional |> 
  ggplot() +
  aes(x = poblacion, y = nombre_region) +
  geom_col(width = .6) +
  geom_text(
    aes(label = label_comma(big.mark = ".")(poblacion)),
    hjust = -0.1, size = 3
  ) +
  scale_x_continuous(
    labels = label_comma(big.mark = "."),
    expand = expansion(c(0, 0.2))
  ) +
  labs(title = "Población regional de Chile",
       subtitle = "Censo de Población y Vivienda 2024",
       caption = "Fuente: INE, datos del paquete de R {poblador}",
       x = "Población total nacional", y = NULL) +
  theme_classic(base_family = "Arial")
```

![](poblacion_regional_files/figure-html/unnamed-chunk-5-1.png)
