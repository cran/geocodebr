## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = identical(tolower(Sys.getenv("NOT_CRAN")), "true"),
  out.width = "100%"
)

# CRAN OMP THREAD LIMIT to avoid CRAN NOTE
Sys.setenv(OMP_THREAD_LIMIT = 2)

## -----------------------------------------------------------------------------
# library(geocodebr)
# 
# # leitura de amostra de dados
# ends <- read.csv(system.file("extdata/small_sample.csv", package = "geocodebr"))
# 
# # definição dos campos de endereço
# campos <- definir_campos(
#   estado = "nm_uf",
#   municipio = "nm_municipio",
#   logradouro = "nm_logradouro",
#   numero = "Numero",
#   cep = "Cep",
#   localidade = "Bairro"
# )

## -----------------------------------------------------------------------------
# # geolicalização
# ends_geo <- geocode(
#   enderecos = ends,
#   campos_endereco = campos,
#   resultado_completo = FALSE,
#   resolver_empates = TRUE,
#   resultado_sf = FALSE,
#   verboso = FALSE
#   )
# 
# head(ends_geo)

