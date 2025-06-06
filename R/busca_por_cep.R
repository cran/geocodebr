#' Busca por CEP
#'
#' Busca endereços e suas coordenadas geográficas a partir de um CEP. As
#' coordenadas de output utilizam o sistema de coordenadas geográficas SIRGAS
#' 2000, EPSG 4674.
#'
#' @param cep Vetor. Um CEP ou um vetor de CEPs com 8 dígitos.
#' @param resultado_sf Lógico. Indica se o resultado deve ser um objeto espacial
#'    da classe `sf`. Por padrão, é `FALSE`, e o resultado é um `data.frame`.
#' @template verboso
#' @template cache
#'
#' @return Retorna um `data.frame` com os CEPs de input e os endereços presentes
#'   naquele CEP com suas coordenadas geográficas de latitude (`lat`) e
#'   longitude (`lon`). Alternativamente, o resultado pode ser um objeto `sf`.
#'
#' @examplesIf identical(tolower(Sys.getenv("NOT_CRAN")), "true")
#' library(geocodebr)
#'
#' # amostra de CEPs
#' ceps <- c("70390-025", "20071-001", "99999-999")
#'
#' df <- geocodebr::busca_por_cep(
#'   cep = ceps,
#'   verboso = FALSE
#'   )
#'
#' df
#'
#' @export
busca_por_cep <- function(cep,
                          resultado_sf = FALSE,
                          verboso = TRUE,
                          cache = TRUE){

  # check input
  checkmate::assert_vector(cep)
  checkmate::assert_logical(resultado_sf, any.missing = FALSE, len = 1)
  checkmate::assert_logical(verboso, any.missing = FALSE, len = 1)
  checkmate::assert_logical(cache, any.missing = FALSE, len = 1)


  # normalize input data -------------------------------------------------------

  cep_padrao <- enderecobr::padronizar_ceps(cep)



  # download cnefe  -------------------------------------------------------

  # downloading cnefe
  cnefe_dir <- download_cnefe(
    tabela = 'municipio_logradouro_cep_localidade',
    verboso = verboso,
    cache = cache
  )


  # Load CNEFE data and filter it to include only states
  # present in the input table, reducing the search scope
  # Narrow search global scope of cnefe to bounding box
  path_to_parquet <- paste0(listar_pasta_cache(), "/municipio_logradouro_cep_localidade.parquet")
  cnefe <- arrow_open_dataset( path_to_parquet )

  # filtrar por uf ?


  output_df <- cnefe |>
    dplyr::select(cep, estado, municipio, logradouro, localidade, lat, lon) |>  # Drop the n_casos column
    dplyr::filter(cep %in% cep_padrao) |>
    dplyr::collect()


  # add any missing cep
  missing_cep <- cep_padrao[!cep_padrao %in% output_df$cep]

  if (length(missing_cep) == length(cep_padrao)) {
    cli::cli_abort("Nenhum CEP foi encontrado.")
  }

  if (length(missing_cep)>0) {
    temp_dt <- data.table::data.table(cep= missing_cep)
    output_df <- data.table::rbindlist(list(output_df, temp_dt), fill = TRUE)
  }

  # convert df to simple feature
  if (isTRUE(resultado_sf)) {
    output_sf <- sfheaders::sf_point(
      obj = output_df,
      x = 'lon',
      y = 'lat',
      keep = TRUE
    )

    sf::st_crs(output_sf) <- 4674
    return(output_sf)
  }

  return(output_df)
}
