# 02a_preparar_revisao.R ------------------------------------------------------
# 1) junta as bases brutas; 2) filtra o ano e remove duplicatas (registrando o
# fluxo); 3) pré-classifica o grupo de autoria por regras; 4) gera o arquivo de
# REVISÃO MANUAL (casos não resolvidos + amostra de auditoria).
#
# A revisão manual é feita no Excel/Planilhas, na coluna 'grupo_final'.

source("modelos_reconstruidos/00_config.R")

normalizar <- function(x) {
  x |> stringr::str_to_lower() |> stringi::stri_trans_general("Latin-ASCII") |> stringr::str_squish()
}
ler_nomes <- function(arquivo) {
  if (file.exists(arquivo)) normalizar(readr::read_csv(arquivo, show_col_types = FALSE)$nome) else character()
}

# Pré-classificação de UM autor individual ------------------------------------
classificar_um <- function(a, chave, nomes_jc, nomes_cient) {
  v <- veiculos[[chave]]
  if (!is.null(v$regex_redacao) && stringr::str_detect(a, v$regex_redacao))
    return(c(grupo = v$cat_redacao, regra = "regex_redacao"))
  if (stringr::str_detect(a, v$regex_agencia))
    return(c(grupo = v$cat_agencia, regra = "regex_agencia"))
  if (a %in% nomes_jc)
    return(c(grupo = v$cat_jornalista_cientifico, regra = "lista_jornalistas_cientificos"))
  if (!is.null(v$cat_cientista) && a %in% nomes_cient)
    return(c(grupo = v$cat_cientista, regra = "lista_cientistas"))
  c(grupo = "A_REVISAR", regra = "nao_resolvido")
}

# Classificação de uma matéria (pode ter vários autores) ------------------------
classificar <- function(autor_bruto, chave) {
  nomes_jc    <- ler_nomes(file.path(DIR_DIC, paste0("jornalistas_cientificos_", chave, ".csv")))
  nomes_cient <- ler_nomes(file.path(DIR_DIC, paste0("cientistas_", chave, ".csv")))
  if (is.na(autor_bruto) || stringr::str_squish(autor_bruto) == "")
    return(tibble(grupo_sugerido = "A_REVISAR", regra = "sem_assinatura"))
  autores <- normalizar(autor_bruto) |> stringr::str_split("\\s*;\\s*|\\s*,\\s*|\\s+e\\s+|\\s+y\\s+|\\s+and\\s+|\\s*/\\s*") |> unlist()
  autores <- autores[autores != ""]
  res <- purrr::map(autores, classificar_um, chave = chave, nomes_jc = nomes_jc, nomes_cient = nomes_cient)
  grupos <- unique(purrr::map_chr(res, \(r) r[["grupo"]]))
  if (length(grupos) == 1 && grupos != "A_REVISAR")
    return(tibble(grupo_sugerido = grupos, regra = res[[1]][["regra"]]))
  if (length(autores) > 1 && length(grupos) > 1)
    return(tibble(grupo_sugerido = "A_REVISAR", regra = "autores_divergentes"))
  tibble(grupo_sugerido = "A_REVISAR", regra = "nao_resolvido")
}

# 1) Leitura e fluxo --------------------------------------------------------------
ler <- \(k) readr::read_csv(file.path(DIR_BRUTO, paste0(k, "_bruto.csv")),
                            col_types = cols(.default = col_character()))
bruto <- purrr::map(names(veiculos), ler) |> dplyr::bind_rows()

f0 <- bruto |> count(veiculo, name = "coletados")
b1 <- bruto |> filter(status == "ok")
f1 <- b1 |> count(veiculo, name = "download_ok")
b2 <- b1 |> mutate(data = as.Date(substr(data_publicacao, 1, 10))) |>
  filter(!is.na(data), lubridate::year(data) == ANO)
f2 <- b2 |> count(veiculo, name = "publicados_no_ano")
b3 <- b2 |> distinct(veiculo, url, .keep_all = TRUE) |>
  distinct(veiculo, titulo, data, .keep_all = TRUE)
f3 <- b3 |> count(veiculo, name = "sem_duplicatas")

fluxo <- purrr::reduce(list(f0, f1, f2, f3), dplyr::left_join, by = "veiculo")
readr::write_excel_csv(fluxo, file.path(DIR_PROC, "fluxo_parcial.csv"))

# 2) Pré-classificação -------------------------------------------------------------
base <- b3 |> mutate(id = paste0(veiculo, "_", dplyr::row_number()))
cls  <- purrr::map2(base$autor_bruto, base$veiculo, classificar) |> dplyr::bind_rows()
base <- dplyr::bind_cols(base, cls)
readr::write_excel_csv(base, file.path(DIR_PROC, "classificacao_automatica.csv"))

# 3) Arquivo de revisão manual ------------------------------------------------------
set.seed(SEMENTE)
resolvidos <- base |> filter(grupo_sugerido != "A_REVISAR")
auditoria  <- resolvidos |> group_by(veiculo) |> slice_sample(prop = AMOSTRA_AUDITORIA) |> ungroup() |>
  mutate(motivo_revisao = "amostra_auditoria")
pendentes  <- base |> filter(grupo_sugerido == "A_REVISAR") |> mutate(motivo_revisao = "a_revisar")

revisao <- dplyr::bind_rows(pendentes, auditoria) |>
  select(id, veiculo, url, titulo, autor_bruto, grupo_sugerido, regra, motivo_revisao) |>
  mutate(grupo_final = "", observacao = "")
readr::write_excel_csv(revisao, file.path(DIR_PROC, "revisao_manual.csv"))

message("Revise ", nrow(revisao), " linhas em ", file.path(DIR_PROC, "revisao_manual.csv"),
        ". Preencha 'grupo_final' (use exatamente os nomes das categorias do 00_config.R)",
        " e salve como 'revisao_manual_preenchida.csv' na mesma pasta.")
