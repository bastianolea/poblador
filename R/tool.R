# library(ellmer)
# load_all()
#
# chat <- chat_anthropic(model = "claude-haiku-5-5")
# vignette("tool-calling")
# chat$chat("hola")
#
# catalogo()
#
# tool_obtener_poblacion <- tool(
#   obtener_poblacion,
#   name = "obtener_poblacion",
#   description = "Obtiene la población de una comuna o región de Chile.
#                  La base por defecto es `censo_poblacion_proyeccion`,
#                  que contiene las proyecciones de población del INE,
#                  con base en el Censo 2017, para los años 2002 a 2035.
#                  Las bases `censo_poblacion_2017` y `censo_poblacion_2024`
#                  contienen la población censada comunal de 2017 y 2024,
#                  respectivamente. Las bases `mideso_pobreza_ingresos` y
#                  `mideso_pobreza_multi` contienen, para 2024, las personas
#                  en situación de pobreza por ingresos y multidimensional,
#                  según estimaciones SAE a partir de la Casen 2024. En estas
#                  dos últimas, la columna se llama `poblacion`, pero su
#                  valor corresponde a personas en situación de pobreza.",
#   arguments = list(
#     datos = type_string("Nombre o código de comuna o región"),
#     nivel = type_string(
#       "Nivel del dato a obtener. Puede ser 'regional', 'comunal' o 'nacional', pero si no se indica, se infiere a partir de los datos. Si no sabes si el dato solicitado es región o comuna, es mejor dejarlo como NULL para que el paquete infiera de manera informada en vez de adivinar."
#     ),
#     "años" = type_string(
#       "Año de la población, para las bases de población que cubren múltiples años (proyecciones del Censo). Puede dejarse como NULL si se necesita el dato propio de la base especificada, por ejemplo, si se pide población del Censo 2024, no es necesario especificar el año."
#     ),
#     base = type_string(
#       "Nombre de la base de datos a utilizar. Las bases disponibles son: 'censo_poblacion_2017', 'censo_poblacion_2024', 'censo_poblacion_proyeccion', 'mideso_pobreza_ingresos', 'mideso_pobreza_multi'. Por defecto de usa 'censo_poblacion_proyeccion'"
#     )
#   )
# )
#
#
# chat$register_tool(tool_obtener_poblacion)
#
# chat$chat("Cuál es la población de Chimbarongo?")
# # no funciona porque el argumento tiene eñe
