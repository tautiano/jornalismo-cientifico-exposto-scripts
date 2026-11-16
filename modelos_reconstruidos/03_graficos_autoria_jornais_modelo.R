# 03_graficos_autoria.R ---------------------------------------------------------
# Gráficos de barras empilhadas: publicações de ciência por mês e grupo de
# autoria (modelo dos Gráficos 8, 9 e 10 da tese). Lê dados_processados/base_final.csv.
# As cores aproximam as dos gráficos da tese; ajuste em 'cores' no 00_config.R.

source("modelos_reconstruidos/00_config.R")

meses <- c("jan", "fev", "mar", "abr", "mai", "jun", "jul", "ago", "set", "out", "nov", "dez")
base <- readr::read_csv(file.path(DIR_PROC, "base_final.csv"),
                        col_types = cols(.default = col_character())) |>
  mutate(data = as.Date(data))

grafico_autoria <- function(chave) {
  v <- veiculos[[chave]]
  d <- base |> filter(veiculo == chave) |>
    mutate(mes   = factor(meses[lubridate::month(data)], levels = meses),
           grupo = factor(grupo_final, levels = v$categorias)) |>
    count(mes, grupo, .drop = FALSE)
  tot <- d |> group_by(mes) |> summarise(total = sum(n), .groups = "drop")

  p <- ggplot(d, aes(mes, n, fill = grupo)) +
    geom_col(position = position_stack(reverse = TRUE), width = 0.6) +
    geom_text(data = filter(d, n > 0), aes(label = n),
              position = position_stack(vjust = 0.5, reverse = TRUE),
              colour = "white", size = 2.8) +
    geom_text(data = tot, aes(mes, total, label = total), inherit.aes = FALSE,
              vjust = -0.5, size = 3, fontface = "bold") +
    scale_fill_manual(values = setNames(v$cores, v$categorias), name = "Grupo de Autoria", drop = FALSE) +
    scale_y_continuous(expand = expansion(mult = c(0, 0.1))) +
    labs(x = "Mês", y = "Total de Publicações") +
    theme_minimal(base_size = 11) +
    theme(legend.position = "top", panel.grid.minor = element_blank(),
          panel.grid.major.x = element_blank())
  ggsave(file.path(DIR_FIG, paste0("grafico_autoria_", chave, ".png")),
         p, width = 10, height = 5.5, dpi = 300, bg = "white")
  invisible(p)
}

# Também salva a tabela mês x grupo, útil para conferir com os números dos gráficos
tabela_mes_grupo <- function(chave) {
  base |> filter(veiculo == chave) |>
    mutate(mes = meses[lubridate::month(data)]) |>
    count(mes, grupo_final) |>
    tidyr::pivot_wider(names_from = grupo_final, values_from = n, values_fill = 0)
}

for (k in names(veiculos)) {
  grafico_autoria(k)
  readr::write_excel_csv(tabela_mes_grupo(k), file.path(DIR_PROC, paste0("tabela_mes_grupo_", k, ".csv")))
}
