# Obtener la población una unidad territorial

A partir del código único territorial de una unidad territorial (comuna,
región o país) de Chile (ver [viñeta sobre códigos únicos
territoriales](https://bastianolea.github.io/territorial/articles/codigos_unicos_territoriales.html)),
esta función obtiene la población correspondiente en un año específico.
Esta función opera sobre vectores, retornando un vector con las cifras
de población correspondientes en el mismo orden que fueron entregadas.
Para *dataframes*, usar
[`agregar_poblacion()`](https://bastianolea.github.io/poblador/reference/agregar_poblacion.md).

## Usage

``` r
obtener_poblacion(
  datos,
  nivel = NULL,
  años = NULL,
  base = "censo_poblacion_proyeccion"
)
```

## Arguments

- datos:

  Vector de datos para obtener su población

- nivel:

  Nivel del dato a obtener. Puede ser "regional", "comunal" o
  "nacional", pero si no se indica, se infiere a partir de los datos.

- años:

  Año de la población, para las bases de población que cubren múltiples
  años.

- base:

  Base de datos de población a utilizar. Por defecto es
  [censo_poblacion_proyeccion](https://bastianolea.github.io/poblador/reference/censo_poblacion_proyeccion.md).

## Value

Vector de las cifras de población correspondientes.

## Details

Se puede especificar la base de datos de a utilizar entre las que ofrece
este paquete (revísalas con
[`datos()`](https://bastianolea.github.io/poblador/reference/datos.md)),
o una distinta que siga las mismas convenciones.

## See also

[`agregar_poblacion()`](https://bastianolea.github.io/poblador/reference/agregar_poblacion.md)
para agregar una columna de población sobre dataframes.

## Examples

``` r
obtener_poblacion(c(1101, 2102))
#> ! Se detectó que los datos son códigos comunales. Se asumirá el nivel "comunal".
#> ! Considerando datos para el año actual (2026). Cambiar con el argumento `años`.
#> ℹ Agregando datos de población de nivel comunal del año 2026 desde la base `poblador::censo_poblacion_proyeccion()`.
#> [1] 234407  16291

obtener_poblacion("La Florida", años = 2023)
#> ! Se detectó que los datos son nombres de comunas. Se asumirá el nivel "comunal".
#> Error in territorial::as_codigo_comuna(datos): object 'territorios' not found

obtener_poblacion("La Florida", base = censo_poblacion_2017)
#> ! Se detectó que los datos son nombres de comunas. Se asumirá el nivel "comunal".
#> Error in territorial::as_codigo_comuna(datos): object 'territorios' not found
```
