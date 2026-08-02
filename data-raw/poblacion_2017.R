# Población Censo 2017
# https://www.ine.gob.cl/estadisticas-por-tema/demografia-y-poblacion/censo-de-poblacion-y-vivienda

library(readxl)
library(dplyr)
library(tidyr)
library(territorial)

poblacion_0 <- read_xls("data-raw/1_1_poblacion.xls", sheet = 4, skip = 2) |>
  janitor::clean_names()

# excluir datos
poblacion_1 <- poblacion_0 |>
  filter_out(nombre_region == "PAÍS") |>
  filter_out(edad == "Total Comuna")


glimpse(poblacion_1)

# seleccionar variables
poblacion_2 <- poblacion_1 |>
  select(codigo_comuna, edad, hombres, mujeres) |>
  mutate(codigo_comuna = as.numeric(codigo_comuna))

# pivotar a largo
poblacion_3 <- poblacion_2 |>
  pivot_longer(
    cols = c(hombres, mujeres),
    names_to = "sexo",
    values_to = "poblacion"
  )

# población por edad y sexo
poblacion_3

# sumar grupos de edad y sexo por comuna
poblacion_4 <- poblacion_3 |>
  group_by(codigo_comuna) |>
  summarize(poblacion = sum(poblacion)) |>
  mutate(año = 2017, .before = poblacion)

# agregar variables territoriales
poblacion_2017 <- poblacion_4 |>
  territorial::contextualizar(codigo_comuna)

# validar datos
library(pointblank)

# revisar que no hay NA
poblacion_2017 |>
  expect_col_vals_not_null(everything())

# revisar dimensiones
poblacion_2017 |>
  expect_col_count_match(8) |>
  expect_row_count_match(346)

usethis::use_data(poblacion_2017, overwrite = TRUE)
