# 01_raspagem_modelo.R ------------------------------------------------------
# MODELO de coleta de METADADOS de matérias (título, data, assinatura, seção).
# NÃO coleta o texto integral das matérias.
#
# AVISO: este script é um modelo genérico. NÃO foi testado nos sites da Folha,
# do El Espectador ou do Público. Se você tem os scripts originais com que
# gerou a planilha da tese, SUBSTITUA este arquivo por eles (limpos e
# comentados), pois o apêndice deve registrar o código efetivamente usado.
#
# Boas práticas embutidas: verificação de robots.txt, identificação do agente,
# pausa entre requisições e nova tentativa limitada. Não contorna paywall.

source("modelos_reconstruidos/00_config.R")

pode_raspar <- function(url) {
  isTRUE(tryCatch(
    robotstxt::paths_allowed(url, user_agent = AGENTE, warn = FALSE),
    error = function(e) NA))
}

baixar_html <- function(url) {
  Sys.sleep(ESPERA_SEG)
  resp <- tryCatch(
    request(url) |> req_user_agent(AGENTE) |> req_retry(max_tries = 3) |>
      req_timeout(30) |> req_perform(),
    error = function(e) NULL)
  if (is.null(resp) || resp_status(resp) >= 400) return(NULL)
  read_html(resp_body_string(resp))
}

nome_autor <- function(a) {
  if (is.null(a)) return(NA_character_)
  if (is.character(a)) return(paste(a, collapse = "; "))
  if (!is.null(names(a)) && !is.null(a[["name"]])) return(as.character(a[["name"]])[1])
  paste(purrr::map_chr(a, nome_autor), collapse = "; ")
}

# Muitos veículos publicam metadados estruturados (JSON-LD, schema.org/NewsArticle)
extrair_jsonld <- function(doc) {
  blocos <- doc |> html_elements("script[type='application/ld+json']") |> html_text()
  objs <- purrr::map(blocos, \(b) tryCatch(jsonlite::fromJSON(b, simplifyVector = FALSE),
                                           error = function(e) NULL)) |> purrr::compact()
  achatar <- function(o) {
    if (!is.null(names(o)) && !is.null(o[["@graph"]])) return(o[["@graph"]])
    if (is.null(names(o))) return(o)
    list(o)
  }
  todos <- purrr::map(objs, achatar) |> purrr::list_flatten()
  tipos <- c("NewsArticle", "Article", "ReportageNewsArticle", "AnalysisNewsArticle")
  noticia <- purrr::detect(todos, \(o) any(tipos %in% unlist(o[["@type"]])))
  if (is.null(noticia)) return(NULL)
  tibble(
    titulo         = as.character(noticia[["headline"]] %||% NA_character_)[1],
    data_publicacao = as.character(noticia[["datePublished"]] %||% NA_character_)[1],
    autor_bruto    = nome_autor(noticia[["author"]]),
    secao          = paste(unlist(noticia[["articleSection"]] %||% NA_character_), collapse = "; ")
  )
}

# Plano B: metatags Open Graph / article:*
extrair_meta <- function(doc) {
  meta <- function(prop) {
    v <- html_attr(html_elements(doc, sprintf("meta[property='%s'], meta[name='%s']", prop, prop)), "content")
    if (length(v) > 0) v[1] else NA_character_
  }
  tibble(titulo = meta("og:title"), data_publicacao = meta("article:published_time"),
         autor_bruto = meta("author"), secao = meta("article:section"))
}

coletar_artigo <- function(url) {
  if (!pode_raspar(url)) {
    return(tibble(url = url, titulo = NA_character_, data_publicacao = NA_character_,
                  autor_bruto = NA_character_, secao = NA_character_, status = "bloqueado_robots"))
  }
  doc <- baixar_html(url)
  if (is.null(doc)) {
    return(tibble(url = url, titulo = NA_character_, data_publicacao = NA_character_,
                  autor_bruto = NA_character_, secao = NA_character_, status = "falha_download"))
  }
  dados <- extrair_jsonld(doc) %||% extrair_meta(doc)
  bind_cols(tibble(url = url), dados, tibble(status = "ok"))
}

coletar_links <- function(urls_listagem, seletor = "a", padrao = NULL) {
  links <- purrr::map(urls_listagem, \(u) {
    if (!pode_raspar(u)) { message("robots.txt não permite: ", u); return(character()) }
    doc <- baixar_html(u)
    if (is.null(doc)) return(character())
    href <- doc |> html_elements(seletor) |> html_attr("href")
    xml2::url_absolute(href[!is.na(href)], u)
  }) |> unlist() |> unique()
  if (!is.null(padrao)) links <- links[stringr::str_detect(links, padrao)]
  links
}

raspar_veiculo <- function(chave) {
  v <- veiculos[[chave]]
  links <- coletar_links(v$urls_listagem, v$seletor_links, v$padrao_url)
  message(v$nome, ": ", length(links), " links encontrados")
  dados <- purrr::map(links, coletar_artigo) |> dplyr::bind_rows()
  dados$veiculo      <- chave
  dados$data_coleta  <- as.character(Sys.Date())
  readr::write_csv(dados, file.path(DIR_BRUTO, paste0(chave, "_bruto.csv")))
  invisible(dados)
}

# Execução (descomente depois de preencher o 00_config.R):
# for (k in names(veiculos)) raspar_veiculo(k)
