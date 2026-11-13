# Registro de cambios

## poblador 0.3.2 (2026/11/13)

- Mejora en artículos y viñetas
- Función `datos()` ahora se llama
  [`catalogo()`](https://bastianolea.github.io/poblador/reference/catalogo.md).

## poblador 0.3.1 (2026/11/12)

- Funciones
  [`catalogo()`](https://bastianolea.github.io/poblador/reference/catalogo.md),
  [`agregar_poblacion()`](https://bastianolea.github.io/poblador/reference/agregar_poblacion.md)
  y
  [`obtener_poblacion()`](https://bastianolea.github.io/poblador/reference/obtener_poblacion.md)
  ahora funcionan sin cargar el paquete (por ejemplo
  [`poblador::catalogo()`](https://bastianolea.github.io/poblador/reference/catalogo.md),
  `poblador::obtener_poblacion(1101)`).

## poblador 0.3.0 (2026/11/12)

- Catálogo de datos
  [`catalogo()`](https://bastianolea.github.io/poblador/reference/catalogo.md)
  entrega información sobre los datos disponibles, y retorna los nombres
  de objetos de manera invisible.
- Mejora en
  [`agregar_poblacion()`](https://bastianolea.github.io/poblador/reference/agregar_poblacion.md)
  para especificar el nombre de la columna de población, y así se puede
  usar dos veces consecutivas (por ejemplo para agregar la población y
  luego la población en situación de pobreza).

## poblador 0.2.0 (2026/11/11)

- Función
  [`obtener_poblacion()`](https://bastianolea.github.io/poblador/reference/obtener_poblacion.md)
  para obtener la población de vectores con nombres o códigos
  territoriales.

## poblador 0.1.1 (2026/11/11)

- Función
  [`agregar_poblacion()`](https://bastianolea.github.io/poblador/reference/agregar_poblacion.md)
  ahora funciona incluso con nombres de comunas o regiones.

## poblador 0.1.0 (2026/11/11)

- Función
  [`agregar_poblacion()`](https://bastianolea.github.io/poblador/reference/agregar_poblacion.md)
  ahora funciona con vectores y *dataframes*, y permite agregar datos de
  nivel comunal, regional y nacional, usando distintas tablas de datos.

## poblador 0.0.1 (2026/11/10)

- Documentación
