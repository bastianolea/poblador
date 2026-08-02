# Población en situación de pobreza por ingresos a nivel comunal (2024)

Cifras de población en situación de pobreza, calculadas por el
Ministerio de Desarrollo Social y Familia a partir de datos de la
Encuesta de Caracterización Socioeconómica Nacional 2024 (Casen 2024),
por medio de la aplicación de la metodología de áreas pequeñas o SAE.

## Usage

``` r
mideso_pobreza_ingresos
```

## Format

Un data frame con 345 filas y 8 columnas:

- codigo_region:

  Código único territorial de las regiones de Chile (número entre 1 y
  16)

- nombre_region:

  Nombre de las regiones de Chile

- codigo_provincia:

  Código único territorial de las provincias de Chile

- nombre_provincia:

  Nombre de las provincias de Chile

- codigo_comuna:

  Código único territorial de las comunas de Chile

- nombre_comuna:

  Nombre de las comunas de Chile

- año:

  Año al que corresponde la población

- poblacion:

  Cantidad de habitantes para la comuna y el año correspondientes

## Source

<https://bidat.gob.cl/directorio/Indicadores%20comunales%20en%20base%20a%20CASEN/estimaciones-de-pobreza-comunal-2024>

## Details

Los datos fueron obtenidos [desde el sitio web de
Mideso](https://bidat.gob.cl/directorio/Indicadores%20comunales%20en%20base%20a%20CASEN/estimaciones-de-pobreza-comunal-2024).
Para más información, revisar el [reporte
metodológico](https://bidat.gob.cl/details/ficha/dato/informe-metodologico-sae-2024).
