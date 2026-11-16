# 02b_aplicar_revisao.R ---------------------------------------------------------
# Aplica a revisão manual, valida as categorias, gera a BASE FINAL e o LOG de
# decisões (o que o script sugeriu x o que você decidiu), além da tabela de
# fluxo da coleta (para o apêndice).

source("modelos_reconstruidos/00_config.R")

le <- \(arq) readr::read_csv(file.path(DIR_PROC, arq), col_types = cols(.default = col_character()))
auto <- le("classificacao_automatica.csv")
rev  <- le("revisao_manual_preenchida.csv") |> select(id, grupo_final, observacao)

base <- auto |>
  left_join(rev, by = "id") |>
  mutate(grupo_final = dplyr::na_if(stringr::str_squish(grupo_final), ""),
         revisado    = id %in% rev$id & !is.na(grupo_final),
         grupo_final = dplyr::coalesce(grupo_final,
                         dplyr::if_else(grupo_sugerido == "A_REVISAR", NA_character_, grupo_sugerido)))

pendentes <- base |> filter(is.na(grupo_final))
if (nrow(pendentes) > 0) stop(nrow(pendentes), " matérias sem grupo_final. Conclua a revisão manual.")

invalidos <- base |> rowwise() |>
  filter(!(grupo_final %in% veiculos[[veiculo]]$categorias)) |> ungroup()
if (nrow(invalidos) > 0) {
  print(invalidos |> select(id, veiculo, grupo_final))
  stop("grupo_final fora das categorias do 00_config.R (confira grafia e acentos).")
}

log <- base |> filter(revisado) |>
  transmute(id, veiculo, url, autor_bruto, grupo_sugerido, regra, grupo_final,
            alterado = grupo_sugerido != grupo_final, observacao)
readr::write_excel_csv(log, file.path(DIR_PROC, "log_decisoes_revisao.csv"))
readr::write_excel_csv(base, file.path(DIR_PROC, "base_final.csv"))

fluxo <- le("fluxo_parcial.csv") |>
  left_join(log |> count(veiculo, name = "revisados_manualmente"), by = "veiculo") |>
  left_join(log |> filter(alterado) |> count(veiculo, name = "classificacao_alterada"), by = "veiculo") |>
  left_join(base |> count(veiculo, name = "base_final"), by = "veiculo")
readr::write_excel_csv(fluxo, file.path(DIR_PROC, "tabela_fluxo_coleta.csv"))
print(fluxo)
