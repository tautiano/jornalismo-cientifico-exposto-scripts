# 00_config.R ---------------------------------------------------------------
# Configuração comum a todos os scripts. Edite SOMENTE este arquivo para
# ajustar veículos, categorias, ano e parâmetros de coleta.
# Requer R >= 4.1 (usa o operador |> e funções anônimas \(x)).

pacotes <- c("tidyverse", "lubridate", "rvest", "httr2", "jsonlite", "robotstxt")
faltando <- setdiff(pacotes, rownames(installed.packages()))
if (length(faltando) > 0) install.packages(faltando)
invisible(lapply(pacotes, library, character.only = TRUE))

`%||%` <- function(a, b) if (is.null(a)) b else a

# --- Parâmetros gerais ------------------------------------------------------
ANO        <- 2025                       # ano de publicação analisado
AGENTE     <- "Pesquisa academica USP (contato: SEU-EMAIL@usp.br)"  # identifique-se
ESPERA_SEG <- 3                          # pausa entre requisições (segundos)
AMOSTRA_AUDITORIA <- 0.05                # fração da classificação automática conferida à mão
SEMENTE    <- 2025                       # semente da amostra de auditoria

DIR_BRUTO <- "dados_brutos"
DIR_PROC  <- "dados_processados"
DIR_FIG   <- "figuras"
DIR_DIC   <- "dicionarios"
for (d in c(DIR_BRUTO, DIR_PROC, DIR_FIG, DIR_DIC)) dir.create(d, showWarnings = FALSE)

# --- Veículos -----------------------------------------------------------------
# ATENÇÃO: urls_listagem, seletor_links e padrao_url são PLACEHOLDERS.
# Substitua pelos endereços e seletores que você realmente usou.
# 'categorias' define a ordem da legenda e da pilha (de baixo para cima) nos gráficos.
veiculos <- list(
  folha = list(
    nome = "Folha de S.Paulo",
    urls_listagem = c("PREENCHER: URLs das páginas de listagem/arquivo da editoria de ciência"),
    seletor_links = "a", padrao_url = "PREENCHER: regex que identifica URLs de matérias",
    categorias = c("Agência", "Cientistas", "Jornalista", "Jornalista científico"),
    cores      = c("#66C2A5", "#FC8D62", "#8DA0CB", "#E78AC3"),
    cat_agencia = "Agência", cat_cientista = "Cientistas",
    cat_jornalista = "Jornalista", cat_jornalista_cientifico = "Jornalista científico",
    cat_redacao = NULL,
    regex_agencia = "reuters|\\bafp\\b|\\befe\\b|associated press|\\bap\\b|agencia brasil|agencia estado|europa press|bloomberg|\\bdpa\\b|ansa|lusa",
    regex_redacao = NULL
  ),
  espectador = list(
    nome = "El Espectador",
    urls_listagem = c("PREENCHER"),
    seletor_links = "a", padrao_url = "PREENCHER",
    categorias = c("Periodistas", "Periodistas Científicos", "Agencias", "Redacción Ciencia"),
    cores      = c("#66C2A5", "#FC8D62", "#8DA0CB", "#E78AC3"),
    cat_agencia = "Agencias", cat_cientista = NULL,
    cat_jornalista = "Periodistas", cat_jornalista_cientifico = "Periodistas Científicos",
    cat_redacao = "Redacción Ciencia",
    regex_agencia = "reuters|\\bafp\\b|\\befe\\b|associated press|\\bap\\b|europa press|bloomberg|\\bdpa\\b|ansa",
    regex_redacao = "redaccion ciencia"
  ),
  publico = list(
    nome = "Público",
    urls_listagem = c("PREENCHER"),
    seletor_links = "a", padrao_url = "PREENCHER",
    categorias = c("Público", "Cientistas", "Jornalistas", "Agências / Veículos", "Jornalistas de Ciência"),
    cores      = c("#984EA3", "#FC8D62", "#66C2A5", "#8DA0CB", "#E78AC3"),
    cat_agencia = "Agências / Veículos", cat_cientista = "Cientistas",
    cat_jornalista = "Jornalistas", cat_jornalista_cientifico = "Jornalistas de Ciência",
    cat_redacao = "Público",
    regex_agencia = "reuters|\\bafp\\b|\\befe\\b|associated press|\\bap\\b|lusa|europa press|bloomberg|\\bdpa\\b|ansa",
    regex_redacao = "^publico$"
  )
)
