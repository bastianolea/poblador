catalogo_lista <- list(
  "censo_poblacion_2017" = list(
    objeto = "censo_poblacion_2017",
    titulo = "Población a nivel comunal de Chile (2017)",
    fuente = "Instituto Nacional de Estadísticas de Chile (INE)",
    url = "https://www.ine.gob.cl/estadisticas-por-tema/demografia-y-poblacion/censo-de-poblacion-y-vivienda"
  ),
  "censo_poblacion_2024" = list(
    objeto = "censo_poblacion_2024",
    titulo = "Población censada a nivel comunal de Chile (2024)",
    fuente = "Instituto Nacional de Estadísticas de Chile (INE)",
    url = "https://censo2024.ine.gob.cl/resultados/"
  ),
  "censo_poblacion_proyeccion" = list(
    objeto = "censo_poblacion_proyeccion",
    titulo = "Proyecciones de población a nivel comunal de Chile (2002-2035), base Censo 2017",
    descr = "Las proyecciones de población proporcionan una referencia del futuro tamaño y estructura por edades de una población, basados en un conjunto de supuestos sobre el comportamiento de los componentes demográficos fecundidad, mortalidad y migración. Son un insumo fundamental para la planificación y la toma de decisiones tanto para el sector público como el privado, dado que permiten anticipar demandas futuras e identificar desafíos que surgen como consecuencia de los cambios demográficos.",
    fuente = "Instituto Nacional de Estadísticas de Chile (INE)",
    url = "https://www.ine.gob.cl/estadisticas-por-tema/demografia-y-poblacion/estimaciones-y-proyecciones-de-poblacion"
  ),
  "mideso_pobreza_ingresos" = list(
    objeto = "mideso_pobreza_ingresos",
    titulo = "Población en situación de pobreza por ingresos a nivel comunal (2024)",
    descr = "Cifras de población en situación de pobreza, calculadas por el Ministerio de Desarrollo Social y Familia a partir de datos de la Encuesta de Caracterización Socioeconómica Nacional 2024 (Casen 2024), por medio de la aplicación de la metodología de áreas pequeñas o SAE.",
    fuente = "Ministerio de Desarrollo Social y Familia (Mideso)",
    url = "https://bidat.gob.cl/details/ficha/dataset/base-de-datos-pobreza-comunal-2024"
  ),
  "mideso_pobreza_multi" = list(
    objeto = "mideso_pobreza_multi",
    titulo = "Población en situación de pobreza multidimensional a nivel comunal (2024)",
    descr = "Cifras de población en situación de pobreza, calculadas por el Ministerio de Desarrollo Social y Familia a partir de datos de la Encuesta de Caracterización Socioeconómica Nacional 2024 (Casen 2024), por medio de la aplicación de la metodología de áreas pequeñas o SAE. La medición de pobreza multidimensional se calcula a partir de 5 dimensiones, cada una con 4 indicadores: Educación, Salud, Trabajo y Seguridad Social, Vivienda y Entorno, y Redes y Cohesión Social.",
    fuente = "Ministerio de Desarrollo Social y Familia (Mideso)",
    url = "https://bidat.gob.cl/details/ficha/dataset/base-de-datos-pobreza-comunal-2024"
  )
)

usethis::use_data(catalogo_lista, overwrite = TRUE, internal = TRUE)
