# Tablas de datos de población disponibles

Imprime en la consola una lista de todas las fuentes de datos incluídas
en el paquete, con su información. Útil para saber qué está disponible
en el paquete.

## Uso

``` r
catalogo()
```

## Valor

Emite mensajes, y si se asigna a un objeto, retorna los nombres de las
tablas de manera invisible.

## Ver también

[`agregar_poblacion()`](https://bastianolea.github.io/poblador/reference/agregar_poblacion.md)
y
[`obtener_poblacion()`](https://bastianolea.github.io/poblador/reference/obtener_poblacion.md)
para hacer uso de estas fuentes de datos sobre dataframes y vectores,
respectivamente.

## Ejemplos

``` r
catalogo()
#> 
#> ── Datos disponibles en poblador ───────────────────────────────────────────────
#> 
#> ── Población a nivel comunal de Chile (2017) ──
#> 
#> • Objeto: `censo_poblacion_2017`
#> • Tabla de 346 y 8 columnas
#> • Años: 2017
#> • Cantidad de comunas únicas: 346
#> • Fuente: Instituto Nacional de Estadísticas de Chile (INE),
#> <https://www.ine.gob.cl/estadisticas-por-tema/demografia-y-poblacion/censo-de-poblacion-y-vivienda>
#> 
#> 
#> ── Población censada a nivel comunal de Chile (2024) ──
#> 
#> • Objeto: `censo_poblacion_2024`
#> • Tabla de 346 y 8 columnas
#> • Años: 2024
#> • Cantidad de comunas únicas: 346
#> • Fuente: Instituto Nacional de Estadísticas de Chile (INE),
#> <https://censo2024.ine.gob.cl/resultados/>
#> 
#> 
#> ── Proyecciones de población a nivel comunal de Chile (2002-2035), base Censo 2017 ──
#> 
#> • Objeto: `censo_poblacion_proyeccion`
#> • Tabla de 11764 y 8 columnas
#> • Las proyecciones de población proporcionan una referencia del futuro tamaño y
#> estructura por edades de una población, basados en un conjunto de supuestos
#> sobre el comportamiento de los componentes demográficos fecundidad, mortalidad
#> y migración. Son un insumo fundamental para la planificación y la toma de
#> decisiones tanto para el sector público como el privado, dado que permiten
#> anticipar demandas futuras e identificar desafíos que surgen como consecuencia
#> de los cambios demográficos.
#> • Años: entre 2002 y 2035
#> • Cantidad de comunas únicas: 346
#> • Fuente: Instituto Nacional de Estadísticas de Chile (INE),
#> <https://www.ine.gob.cl/estadisticas-por-tema/demografia-y-poblacion/estimaciones-y-proyecciones-de-poblacion>
#> 
#> 
#> ── Población en situación de pobreza por ingresos a nivel comunal (2024) ──
#> 
#> • Objeto: `mideso_pobreza_ingresos`
#> • Tabla de 345 y 8 columnas
#> • Cifras de población en situación de pobreza, calculadas por el Ministerio de
#> Desarrollo Social y Familia a partir de datos de la Encuesta de Caracterización
#> Socioeconómica Nacional 2024 (Casen 2024), por medio de la aplicación de la
#> metodología de áreas pequeñas o SAE.
#> • Años: 2024
#> • Cantidad de comunas únicas: 345
#> • Fuente: Ministerio de Desarrollo Social y Familia (Mideso),
#> <https://bidat.gob.cl/details/ficha/dataset/base-de-datos-pobreza-comunal-2024>
#> 
#> 
#> ── Población en situación de pobreza multidimensional a nivel comunal (2024) ──
#> 
#> • Objeto: `mideso_pobreza_multi`
#> • Tabla de 345 y 8 columnas
#> • Cifras de población en situación de pobreza, calculadas por el Ministerio de
#> Desarrollo Social y Familia a partir de datos de la Encuesta de Caracterización
#> Socioeconómica Nacional 2024 (Casen 2024), por medio de la aplicación de la
#> metodología de áreas pequeñas o SAE. La medición de pobreza multidimensional se
#> calcula a partir de 5 dimensiones, cada una con 4 indicadores: Educación,
#> Salud, Trabajo y Seguridad Social, Vivienda y Entorno, y Redes y Cohesión
#> Social.
#> • Años: 2024
#> • Cantidad de comunas únicas: 345
#> • Fuente: Ministerio de Desarrollo Social y Familia (Mideso),
#> <https://bidat.gob.cl/details/ficha/dataset/base-de-datos-pobreza-comunal-2024>
#> 
```
