
<!-- README.md is generated from README.Rmd. Please edit that file -->

# geocodebr: Geolocalização de Endereços Brasileiros

[![CRAN
status](https://www.r-pkg.org/badges/version/geocodebr)](https://CRAN.R-project.org/package=geocodebr)
<!-- [![CRAN/METACRAN Total downloads](https://cranlogs.r-pkg.org/badges/grand-total/geocodebr?color=blue)](https://CRAN.R-project.org/package=geocodebr) -->
[![check](https://github.com/ipeaGIT/geocodebr/workflows/check/badge.svg)](https://github.com/ipeaGIT/geocodebr/actions)
[![Codecov test
coverage](https://codecov.io/gh/ipeaGIT/geocodebr/branch/main/graph/badge.svg)](https://app.codecov.io/gh/ipeaGIT/geocodebr?branch=main)
[![Lifecycle:
experimental](https://lifecycle.r-lib.org/articles/figures/lifecycle-experimental.svg)](https://lifecycle.r-lib.org/articles/stages.html)

O **{geocodebr}** é um pacote computacional para geolicalização de
endereços Brasileiros. O pacote oferece uma maneira simples e eficiente
de geolocalizar endereços para encontrar suas coordenadas geográficas. O
pacote é baseado em conjuntos de dados espaciais abertos de endereços
brasileiros, utilizando principalmente o Cadastro Nacional de Endereços
para Fins Estatísticos (CNEFE). O CNEFE é
[publicado](https://www.ibge.gov.br/estatisticas/sociais/populacao/38734-cadastro-nacional-de-enderecos-para-fins-estatisticos.html)
pelo Instituto Brasileiro de Geografia e Estatística (IBGE). Atualmente,
o pacote está disponível apenas em R.

## Instalação

A última versão estável pode ser baixada do CRAN com o comando a seguir:

``` r
# from CRAN
install.packages("geocodebr")
```

Caso prefira, a versão em desenvolvimento:

``` r
# install.packages("remotes")
remotes::install_github("ipeaGIT/geocodebr")
```

## Utilização

### Geolocalização: de endereços para coordenadas espaciais

Uma que você possui uma tabela de dados (`data.frame`) com endereços no
Brasil, a geolocalização desses dados com **{geocodebr}** pode ser feita
em apenas dois passos:

1.  O primeiro passo é usar a função `definir_campos()` para indicar os
    nomes das colunas no seu `data.frame` que correspondem a cada campo
    dos endereços.

2.  O segundo passo é usar a função `geocode()` para encontrar as
    coordenadas geográficas dos endereços de input.

``` r
library(geocodebr)

# carregando uma amostra de dados
input_df <- read.csv(system.file("extdata/small_sample.csv", package = "geocodebr"))

# Primeiro passo: inidicar o nome das colunas com cada campo dos enderecos
campos <- geocodebr::definir_campos(
  logradouro = "nm_logradouro",
  numero = "Numero",
  cep = "Cep",
  localidade = "Bairro",
  municipio = "nm_municipio",
  estado = "nm_uf"
  )

# Segundo passo: geolocalizar
df <- geocodebr::geocode(
  enderecos = input_df,
  campos_endereco = campos,
  resultado_completo = FALSE,
  resolver_empates = FALSE,
  resultado_sf = FALSE,
  verboso = FALSE,
  cache = TRUE,
  n_cores = 1
  )
```

Cabe também destacar aqui outros dois argumentos da função `geocode()`:

- `resolver_empates`: serve para indicar se o usuário quer que a função
  resolva automaticamente casos de empate, i.e. casos que o endereço de
  input do usuário pode se referir a diferentes localidades na cidade
  (e.g. logradouros diferentes com mesmo nome mas em bairros distintos)
- `resultado_sf`: quando `TRUE`, o output é retornado como um objeto
  espacial de classe `sf` simple feature.

Os resultados do **{geocodebr}** são classificados em seis categorias
gerais de `precisao`, dependendo do nível de exatidão com que cada
endereço de input foi encontrado nos dados do CNEFE. Para mais
informações, consulte a documentação da função ou a **vignette de
geocode**.

## Projetos relacionados

Existem diversos pacotes de geolocalização disponíveis, muitos dos quais
podem ser utilizados em R (listados abaixo). A maioria dessas
alternativas depende de softwares e conjuntos de dados comerciais,
geralmente impondo limites de número de consultas gratuitas. Em
contraste, as principais vantagens do **{geocodebr}** são que o pacote:
(a) é completamente gratuito, permitindo consultas ilimitadas sem nenhum
custo; (b) opera com alta velocidade e escalabilidade eficiente,
permitindo geocodificar milhões de endereços em apenas alguns minutos,
sem a necessidade de infraestrutura computacional avançada ou de alto
desempenho.

- [{arcgisgeocode}](https://cran.r-project.org/package=arcgisgeocode)
  and [{arcgeocoder}](https://cran.r-project.org/package=arcgeocoder):
  utiliza serviço de geocode do ArcGIS
- [{nominatimlite}](https://cran.r-project.org/package=nominatimlite):
  baseado dados do OSM
- [{photon}](https://cran.r-project.org/package=photon): baseado dados
  do OSM
- [{tidygeocoder}](https://cran.r-project.org/package=tidygeocoder): API
  para diversos servicos de geolocalização
- [{googleway}](https://cran.r-project.org/package=googleway) and
  [{mapsapi}](https://cran.r-project.org/package=mapsapi): interface
  para API do Google Maps

## Nota <a href="https://www.ipea.gov.br"><img src="man/figures/ipea_logo.png" alt="IPEA" align="right" width="300"/></a>

Os dados originais do CNEFE são coletados pelo Instituto Brasileiro de
Geografia e Estatística (IBGE). O **{geocodebr}** foi desenvolvido por
uma equipe do Instituto de Pesquisa Econômica Aplicada (Ipea)
