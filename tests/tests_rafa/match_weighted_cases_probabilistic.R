# match_weighted_cases_probabilistic <- function(
#     con = con,
#     x = 'input_padrao_db',
#     y = 'filtered_cnefe',
#     output_tb = "output_db",
#     key_cols,
#     match_type,
#     resultado_completo){
#
#   # read corresponding parquet file
#   table_name <- paste(key_cols, collapse = "_")
#   table_name <- gsub('estado_municipio', 'municipio', table_name)
#   table_name <- gsub('logradouro_sem_numero', 'logradouro', table_name)
#
#   # master table
#   if (match_type %like% 'pn02|pi02|pn03|pi03|pn04|pi04') {
#     table_name <- "municipio_logradouro_numero_cep_localidade"
#   }
#
#   # build path to local file
#   path_to_parquet <- paste0(listar_pasta_cache(), "/", table_name, ".parquet")
#
#
#   # determine geographical scope of the search
#   input_states <- DBI::dbGetQuery(con, "SELECT DISTINCT estado FROM input_padrao_db;")$estado
#   input_municipio <- DBI::dbGetQuery(con, "SELECT DISTINCT municipio FROM input_padrao_db;")$municipio
#
#   # Load CNEFE data and write to DuckDB
#   # filter cnefe to include only states and municipalities
#   # present in the input table, reducing the search scope
#   filtered_cnefe <- arrow::open_dataset( path_to_parquet ) |>
#     dplyr::filter(estado %in% input_states) |>
#     dplyr::filter(municipio %in% input_municipio) |>
#     dplyr::compute()
#
#   # register filtered_cnefe to db
#   duckdb::duckdb_register_arrow(con, "filtered_cnefe", filtered_cnefe)
#
#   # cols that cannot be null
#   cols_not_null <-  paste(
#     glue::glue("{x}.{key_cols} IS NOT NULL"),
#     collapse = ' AND '
#   )
#
#   # remove numero and logradourot from key cols to allow for the matching
#   key_cols <- key_cols[key_cols != 'numero']
#   key_cols <- key_cols[key_cols != 'logradouro_sem_numero']
#
#   # Create the JOIN condition by concatenating the key columns
#   join_condition <- paste(
#     glue::glue("{y}.{key_cols} = {x}.{key_cols}"),
#     collapse = ' AND '
#   )
#
#
#   # whether to keep all columns in the result
#   colunas_encontradas <- ""
#   additional_cols <- ""
#
#   if (isTRUE(resultado_completo)) {
#
#     colunas_encontradas <- paste0(
#       glue::glue("{key_cols}_encontrado"),
#       collapse = ', ')
#
#     colunas_encontradas <- gsub('logradouro_sem_numero_encontrado', 'logradouro_encontrado', colunas_encontradas)
#     colunas_encontradas <- gsub('localidade_encontrado', 'localidade_encontrada', colunas_encontradas)
#     colunas_encontradas <- paste0(", ", colunas_encontradas)
#
#     additional_cols <- paste0(
#       glue::glue("filtered_cnefe.{key_cols} AS {key_cols}_encontrado"),
#       collapse = ', ')
#
#     additional_cols <- gsub('logradouro_sem_numero_encontrado', 'logradouro_encontrado', additional_cols)
#     additional_cols <- gsub('localidade_encontrado', 'localidade_encontrada', additional_cols)
#     additional_cols <- paste0(", ", additional_cols)
#
#   }
#
#
#   # 1st step: match  --------------------------------------------------------
#
#   # min cutoff for string match
#   min_cutoff <- ifelse(match_type %in% c('pn01', 'pi01', 'pr01'), 0.8, 0.9)
#
#   query_match <- glue::glue(
#     "CREATE OR REPLACE TEMPORARY VIEW temp_db AS
#      WITH ranked_data AS (
#       SELECT
#       {x}.tempidgeocodebr, {x}.numero, {y}.numero AS numero_cnefe,
#       {y}.lat, {y}.lon,
#       {x}.logradouro_sem_numero AS logradouro_sem_numero,
#       {y}.logradouro_sem_numero AS logradouro_sem_numero_cnefe,
#       REGEXP_REPLACE( {y}.endereco_completo, ', \\d+ -', CONCAT(', ', {x}.numero, ' (aprox) -')) AS endereco_encontrado,
#       jaro_similarity({x}.logradouro_sem_numero, {y}.logradouro_sem_numero) AS similarity,
#       RANK() OVER (PARTITION BY {x}.tempidgeocodebr ORDER BY similarity DESC) AS rank
#       {additional_cols}
#     FROM {x}
#     LEFT JOIN {y}
#       ON {join_condition}
#       WHERE {cols_not_null} AND {y}.numero IS NOT NULL
#       )
#     SELECT *
#       FROM ranked_data
#       WHERE similarity > {min_cutoff}
#       AND rank = 1;"
#   )
#
#   DBI::dbExecute(con, query_match)
#   # a <- DBI::dbReadTable(con, 'temp_db')
#
#
#
#   # 2nd step: aggregate --------------------------------------------------------
#
#   # summarize query
#   query_aggregate <- glue::glue(
#     "INSERT INTO output_db (tempidgeocodebr, lat, lon, tipo_resultado, endereco_encontrado)
#       SELECT tempidgeocodebr,
#       SUM((1/ABS(numero - numero_cnefe) * lat)) / SUM(1/ABS(numero - numero_cnefe)) AS lat,
#       SUM((1/ABS(numero - numero_cnefe) * lon)) / SUM(1/ABS(numero - numero_cnefe)) AS lon,
#       '{match_type}' AS tipo_resultado,
#       FIRST(endereco_encontrado) AS endereco_encontrado
#       FROM temp_db
#       GROUP BY tempidgeocodebr, endereco_encontrado;"
#   )
#
#
#
#   if (isTRUE(resultado_completo)) {
#
#     additional_cols <- paste0(
#       glue::glue("FIRST({key_cols}_encontrado)"),
#       collapse = ', ')
#
#     additional_cols <- gsub('logradouro_sem_numero_encontrado', 'logradouro_encontrado', additional_cols)
#     additional_cols <- gsub('localidade_encontrado', 'localidade_encontrada', additional_cols)
#     additional_cols <- paste0(", ", additional_cols)
#
#     query_aggregate <- glue::glue(
#       "INSERT INTO output_db (tempidgeocodebr, lat, lon, tipo_resultado, endereco_encontrado, similaridade_logradouro {colunas_encontradas})
#         SELECT tempidgeocodebr,
#         SUM((1/ABS(numero - numero_cnefe) * lat)) / SUM(1/ABS(numero - numero_cnefe)) AS lat,
#         SUM((1/ABS(numero - numero_cnefe) * lon)) / SUM(1/ABS(numero - numero_cnefe)) AS lon,
#         '{match_type}' AS tipo_resultado,
#         FIRST(endereco_encontrado) AS endereco_encontrado,
#         FIRST(similarity) AS similaridade_logradouro
#         {additional_cols}
#       FROM temp_db
#       WHERE similaridade_logradouro > {min_cutoff}
#       GROUP BY tempidgeocodebr, endereco_encontrado;"
#     )
#   }
#
#   DBI::dbExecute(con, query_aggregate)
#   # b <- DBI::dbReadTable(con, 'output_db')
#
#
#   duckdb::duckdb_unregister_arrow(con, "filtered_cnefe")
#
#   # UPDATE input_padrao_db: Remove observations found in previous step
#   temp_n <- update_input_db(
#     con,
#     update_tb = x,
#     reference_tb = output_tb
#   )
#
#   return(temp_n)
# }
