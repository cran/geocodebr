# skip tests because they take too much time
skip_if(Sys.getenv("TEST_ONE") != "")
testthat::skip_on_cran()
testthat::skip_if_not_installed("arrow")


data_path <- system.file("extdata/small_sample.csv", package = "geocodebr")
input_df <- read.csv(data_path)

campos <- definir_campos(
  logradouro = "nm_logradouro",
  numero = "Numero",
  cep = "Cep",
  localidade = "Bairro",
  municipio = "nm_municipio",
  estado = "nm_uf"
)

tester <- function(enderecos = input_df,
                   campos_endereco = campos,
                   resultado_completo = FALSE,
                   resolver_empates = FALSE,
                   resultado_sf = FALSE,
                   verboso = FALSE,
                   cache = TRUE,
                   n_cores = 1) {
  geocode(
    enderecos,
    campos_endereco,
    resultado_completo,
    resolver_empates,
    resultado_sf,
    verboso,
    cache,
    n_cores
  )
}

test_that("expected output", {
  testthat::expect_warning(std_output <- tester())

  # find expected match cases
  match_types_found <- unique(std_output$tipo_resultado)
  testthat::expect_true(length(match_types_found) == 17)

  # full results
  testthat::expect_warning(full_output <- tester(resultado_completo = TRUE))
  testthat::expect_true('endereco_encontrado' %in% names(full_output))

  # output in sf format
  testthat::expect_warning(sf_output <- tester(resultado_sf = TRUE))
  testthat::expect_true(is(sf_output , 'sf'))
})


test_that("test empates", {

  # com empates
  testthat::expect_warning( std_output <- tester(resolver_empates = FALSE) )
  testthat::expect_true(nrow(std_output) > nrow(input_df))

  # resolvendo empates
  testthat::expect_message( std_output <- tester(verboso = TRUE, resolver_empates = TRUE) )
  testthat::expect_true(nrow(std_output) == nrow(input_df))

  # output ordenado como input
  testthat::expect_true( all(std_output$id == 1:nrow(input_df)) )

})

test_that("test no messages", {

  testthat::expect_no_message(
    testthat::expect_warning(
      std_output <- tester(verboso = FALSE,
                           resolver_empates = FALSE)
                               ))

  testthat::expect_no_message( std_output <- tester(verboso = FALSE,
                                                    resolver_empates = TRUE)
                             )
})


test_that("errors with incorrect input", {
  expect_error(tester(unclass(input_df)))

  expect_error(tester(campos_endereco = 1))
  expect_error(tester(campos_endereco = c(hehe = "nm_logradouro")))
  expect_error(tester(campos_endereco = c(logradouro = "hehe")))

  expect_error(tester(resultado_completo = 1))
  expect_error(tester(resultado_completo = NA))
  expect_error(tester(resultado_completo = c(TRUE, TRUE)))

  expect_error(tester(resolver_empates = 1))
  expect_error(tester(resolver_empates = NA))
  expect_error(tester(resolver_empates = c(TRUE, TRUE)))

  expect_error(tester(resultado_sf = 1))
  expect_error(tester(resultado_sf = NA))
  expect_error(tester(resultado_sf = c(TRUE, TRUE)))

  expect_error(tester(n_cores = "a"))
  expect_error(tester(n_cores = 0))
  expect_error(tester(n_cores = Inf))

  expect_error(tester(verboso = 1))
  expect_error(tester(verboso = NA))
  expect_error(tester(verboso = c(TRUE, TRUE)))

  expect_error(tester(cache = 1))
  expect_error(tester(cache = NA))
  expect_error(tester(cache = c(TRUE, TRUE)))
})

