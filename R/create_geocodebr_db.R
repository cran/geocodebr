create_geocodebr_db <- function( # nocov start
    db_path = "tempdir",
    n_cores = NULL){

  # check input
  checkmate::assert_number(n_cores, null.ok = TRUE)
  # checkmate::assert_string(db_path, pattern = "tempdir|memory")


  # this creates a local database which allows DuckDB to
  # perform **larger-than-memory** workloads
  if(db_path == 'tempdir'){
    db_path <- tempfile(pattern = 'geocodebr', fileext = '.duckdb')
  }

  if(db_path == 'memory'){
    con <- duckdb::dbConnect(duckdb::duckdb(), dbdir= ":memory:" )
  }

  # create db connection
  con <- duckdb::dbConnect(
    duckdb::duckdb( bigint = "integer64" ),
    dbdir= db_path
    ) # db_path ":memory:"

  # Set Number of cores for parallel operation
  if (is.null(n_cores)) {
    n_cores <- parallel::detectCores()
    n_cores <- n_cores - 1
    if (n_cores<1) {n_cores <- 1}
  }

  DBI::dbExecute(con, sprintf("SET threads = %s;", n_cores))

  # Set Memory limit
  # DBI::dbExecute(con, "SET memory_limit = '8GB'")

  return(con)
} # nocov end
