## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = identical(tolower(Sys.getenv("NOT_CRAN")), "true"),
  out.width = "100%"
)

# CRAN OMP THREAD LIMIT to avoid CRAN NOTE
Sys.setenv(OMP_THREAD_LIMIT = 2)

## ----eval = FALSE-------------------------------------------------------------
# install.packages("geocodebr")

## ----eval = FALSE-------------------------------------------------------------
# # install.packages("remotes")
# remotes::install_github("ipeaGIT/geocodebr")

## -----------------------------------------------------------------------------
# library(geocodebr)
# library(sf)
# 
# # carregando uma amostra de dados
# input_df <- read.csv(system.file("extdata/small_sample.csv", package = "geocodebr"))
# 
# # Primeiro passo: inidicar o nome das colunas com cada campo dos enderecos
# campos <- geocodebr::definir_campos(
#   logradouro = "nm_logradouro",
#   numero = "Numero",
#   cep = "Cep",
#   localidade = "Bairro",
#   municipio = "nm_municipio",
#   estado = "nm_uf"
# )
# 
# # Segundo passo: geolocalizar
# df <- geocodebr::geocode(
#   enderecos = input_df,
#   campos_endereco = campos,
#   resultado_completo = FALSE,
#   resolver_empates = FALSE,
#   resultado_sf = FALSE,
#   verboso = FALSE,
#   cache = TRUE,
#   n_cores = 1
# )
# 

## -----------------------------------------------------------------------------
# # amostra de pontos espaciais
# pontos <- readRDS(
#   system.file("extdata/pontos.rds", package = "geocodebr")
# )
# 
# # seleciona somente os primeiros 20 pontos
# pontos <- pontos[1:20,]
# 
# # geocode reverso
# df_enderecos <- geocodebr::geocode_reverso(
#   pontos = pontos,
#   dist_max = 1000,
#   verboso = FALSE,
#   n_cores = 1
# )
# 

## -----------------------------------------------------------------------------
# # amostra de CEPs
# ceps <- c("70390-025", "20071-001")
# 
# df_ceps <- geocodebr::busca_por_cep(
#   cep = ceps,
#   resultado_sf = FALSE,
#   verboso = FALSE
# )
# 

## -----------------------------------------------------------------------------
# geocodebr::listar_pasta_cache()
# 
# geocodebr::listar_dados_cache()

