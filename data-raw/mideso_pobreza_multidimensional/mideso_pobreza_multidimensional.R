## code to prepare `mideso_pobreza_ingresos` dataset goes here
# https://bidat.gob.cl/details/ficha/dataset/base-de-datos-pobreza-comunal-2024

library(readxl)
library(dplyr)
library(janitor)
library(territorial)

pobreza_0 <- read_xlsx("data-raw/sae_multidimensional_2024.xlsx", skip = 2) |>
  clean_names()

pobreza_1 <- pobreza_0 |>
  select(
    codigo_comuna = codigo,
    poblacion = numero_de_personas_en_situacion_de_pobreza_multidimensional
  )

pobreza_2 <- pobreza_1 |>
  filter_out(is.na(poblacion)) |>
  mutate(codigo_comuna = as.numeric(codigo_comuna)) |>
  mutate(año = 2024, .before = poblacion)

mideso_pobreza_multi <- pobreza_2 |>
  territorial::contextualizar(codigo_comuna)

# validar
library(pointblank)

mideso_pobreza_multi |>
  expect_col_count_match(8) |>
  expect_row_count_match(345) |>
  expect_col_vals_not_null(everything())

usethis::use_data(mideso_pobreza_multi, overwrite = TRUE)
