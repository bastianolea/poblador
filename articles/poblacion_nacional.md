# Gráfico de población nacional de Chile

``` r

library(poblador)
library(dplyr)
```

El paquete incluye tablas de datos de los últimos censos de Chile, que
puedes revisar ejecutando
[`poblador::catalogo()`](https://bastianolea.github.io/poblador/reference/catalogo.md).
Por ejemplo:

``` r

censo_poblacion_2024 |> 
  select(nombre_comuna, año, poblacion) |> 
  head()
```

    # A tibble: 6 × 3
      nombre_comuna   año poblacion
      <chr>         <dbl>     <int>
    1 Iquique        2024    199587
    2 Alto Hospicio  2024    142086
    3 Pozo Almonte   2024     16878
    4 Pica           2024      6272
    5 Huara          2024      2858
    6 Camiña         2024      1335

``` r

censo_poblacion_2017 |> 
  select(nombre_comuna, año, poblacion) |> 
  head()
```

    # A tibble: 6 × 3
      nombre_comuna   año poblacion
      <chr>         <dbl>     <dbl>
    1 Iquique        2017    191468
    2 Alto Hospicio  2017    108375
    3 Pozo Almonte   2017     15711
    4 Camiña         2017      1250
    5 Colchane       2017      1728
    6 Huara          2017      2730

También incluye las últimas proyecciones de población disponibles a
nivel de comuna, que son en base al Censo 2017, y que pueden filtrarse
por año:

``` r

censo_poblacion_proyeccion |> 
  filter(año == 2030) |> 
  select(nombre_comuna, año, poblacion) |> 
  head()
```

    # A tibble: 6 × 3
      nombre_comuna   año poblacion
      <chr>         <dbl>     <dbl>
    1 Iquique        2030    238173
    2 Alto Hospicio  2030    162080
    3 Pozo Almonte   2030     20016
    4 Camiña         2030      1344
    5 Colchane       2030      1485
    6 Huara          2030      3185

A partir de las tablas de datos de población, procesamos para obtener
tres tablas con poblaciones de distintos años y mediciones:

``` r

pob_2017 <- poblador::censo_poblacion_2017 |> 
  mutate(tipo = "Censo")

pob_2024 <- poblador::censo_poblacion_2024 |> 
  mutate(tipo = "Censo")

año_actual <- as.integer(format(Sys.Date(), "%Y"))

pob_2026 <- poblador::censo_poblacion_proyeccion |> 
  filter(año %in% c(2015, 2017, 2024, año_actual)) |> 
  mutate(tipo = "Proyección")
```

Luego las unimos:

``` r

datos <- bind_rows(
  pob_2017,
  pob_2024,
  pob_2026
)
```

Ahora obtenemos una suma de las poblaciones para llegar a la población
nacional:

``` r

datos_anual <- datos |> 
  group_by(año, tipo) |> 
  summarize(poblacion = sum(poblacion))

datos_anual
```

    # A tibble: 6 × 3
    # Groups:   año [4]
        año tipo       poblacion
      <dbl> <chr>          <dbl>
    1  2015 Proyección  17971423
    2  2017 Censo       17574003
    3  2017 Proyección  18419192
    4  2024 Censo       18480432
    5  2024 Proyección  20086377
    6  2026 Proyección  20322807

Finalmente generamos un gráfico de los cambios de población en Chile
según las últimas mediciones censales y la proyección del año en curso:

``` r

library(ggplot2)
library(scales)

datos_anual |> 
  ggplot() +
  aes(año, poblacion,
      linetype = tipo) +
  geom_segment(
    aes(xend = año, yend = 0),
    linetype = "solid", linewidth = 0.5,
    color = "#999999") +
  geom_line(linewidth = .8) +
  geom_point(size = 2) +
  geom_text(
    data = ~filter(.x, año %in% c(2024, 2026)),
    aes(label = label_comma(big.mark = ".")(poblacion)),
    hjust = -0.1, vjust = 1.5, size = 3
  ) +
  scale_y_continuous(
    labels = label_comma(scale = 1e-6, big.mark = "."),
    expand = expansion(c(0, 0.1))
  ) +
  scale_x_continuous(
    breaks = seq(min(datos_anual$año), max(datos_anual$año)),
    expand = expansion(c(.05, .2))
  ) +
  labs(title = "Población de Chile",
       subtitle = "Comparación entre Censo y proyecciones censales",
       caption = "Fuente: INE, datos del paquete de R {poblador}",
       linetype = "Datos",
       y = "Población total nacional (millones)", x = NULL) +
  theme_classic(base_family = "Arial") +
  theme(legend.key.width = unit(1, "cm"),
        legend.margin = margin(l = -70))
```

![](poblacion_nacional_files/figure-html/unnamed-chunk-6-1.png)
