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
# library(sf)
# 
# # amostra de pontos espaciais
# pontos <- readRDS(
#   system.file("extdata/pontos.rds", package = "geocodebr")
# )
# 
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
# head(df_enderecos)

