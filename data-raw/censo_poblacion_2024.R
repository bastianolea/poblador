# Población Censo 2024
# https://censo2024.ine.gob.cl/resultados/

library(arrow)
library(dplyr)
library(territorial)

# cargar censo parquet desde fuente externa
censo <- open_dataset("/Volumes/Kingston/Censo/2024/personas_censo2024.parquet")

censo

# cruzar personas y hogares, contar y traer a memoria
poblacion_1 <- censo |>
  select(codigo_comuna = comuna, sexo, edad, edad_quinquenal) |>
  # contar personas
  group_by(codigo_comuna) |>
  summarize(poblacion = n()) |>
  mutate(codigo_comuna = as.numeric(codigo_comuna)) |>
  # calcular desde base de datos
  collect()

poblacion_2 <- poblacion_1 |>
  mutate(año = 2024, .before = poblacion)

# agregar variables territoriales
censo_poblacion_2024 <- poblacion_2 |>
  territorial::contextualizar(codigo_comuna) |>
  arrange(codigo_region, nombre_region)

# validar datos
library(pointblank)

# revisar que no hay NA
censo_poblacion_2024 |>
  expect_col_vals_not_null(everything())

# revisar dimensiones
censo_poblacion_2024 |>
  expect_col_count_match(8) |>
  expect_row_count_match(346)

usethis::use_data(censo_poblacion_2024, overwrite = TRUE)
