% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/download_cnefe.R
\name{download_cnefe}
\alias{download_cnefe}
\title{Faz download dos dados do CNEFE}
\usage{
download_cnefe(tabela = "todas", verboso = TRUE, cache = TRUE)
}
\arguments{
\item{tabela}{Nome da tabela para ser baixada. Por padrão, baixa \code{"todas"}.}

\item{verboso}{Um valor lógico. Indica se barras de progresso e mensagens
devem ser exibidas durante o download dos dados do CNEFE e a geocodificação
dos endereços. O padrão é \code{TRUE}.}

\item{cache}{Um valor lógico. Indica se os dados do CNEFE devem ser salvos ou
lidos do cache, reduzindo o tempo de processamento em chamadas futuras. O
padrão é \code{TRUE}. Quando \code{FALSE}, os dados do CNEFE são baixados para um
diretório temporário.}
}
\value{
Retorna o caminho para o diretório onde os dados foram salvos.
}
\description{
Faz o download de uma versão pre-processada e enriquecida do CNEFE (Cadastro
Nacional de Endereços para Fins Estatísticos) que foi criada para o uso deste
pacote.
}
\examples{
\dontshow{if (identical(tolower(Sys.getenv("NOT_CRAN")), "true")) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
download_cnefe(verboso = FALSE)
\dontshow{\}) # examplesIf}
}
