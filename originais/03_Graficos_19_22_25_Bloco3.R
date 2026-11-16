# =============================================================================
# SCRIPT ORIGINAL DO AUTOR (código abaixo do cabeçalho sem alterações)
# Gráficos 19 (Brasil), 22 (Colômbia) e 25 (Portugal): Bloco 3, escala direta de
# 3 níveis, jornalistas científicos x demais jornalistas. Nas perguntas dicotômicas
# (espaço e treinamento), "Sim" (código 2) é recodificado para 3 e exibido em azul.
# Entrada : base_unica_83.xlsx, aba "Base" (NÃO disponibilizada; ver docs/DICIONARIO_BASE.md).
#           O script confere que a base tem 83 linhas.
# Saída   : Grafico_19_Bloco3_BR.png, Grafico_22_Bloco3_CO.png, Grafico_25_Bloco3_PT.png
# Pacotes : readxl, dplyr, tidyr, ggplot2
# =============================================================================
library(readxl); library(dplyr); library(tidyr); library(ggplot2)

base <- read_excel(file.choose(), sheet = "Base")   # escolha base_unica_83.xlsx
stopifnot(nrow(base) == 83)

# ---- Cores e legenda (3 níveis; a intermediária fica no centro) ----
cores3   <- c("1" = "#b2182b", "2" = "#e0e0e0", "3" = "#2166ac")
rotulos3 <- c("Resposta desfavorável", "Resposta intermediária (com ressalvas)", "Resposta favorável")
# Para manter a legenda antiga: c("Percepção negativa/baixa", "Percepção moderada/condicionada", "Percepção positiva/alta")

# ---- As cinco perguntas do Bloco 3, com as opções reais no título do painel ----
vars3 <- c("impacto", "espaco_suficiente", "pauta_museus", "capacitacao", "treinamento_suficiente")
rot3  <- c(
  impacto                = "Impacto do jornalismo na conscientização do público\n(Pouco impacto | Impacto moderado | Muito impacto)",
  espaco_suficiente      = "Suficiência de espaço para a ciência nos meios de comunicação\n(Não, o espaço é limitado | Sim, há espaço suficiente)",
  pauta_museus           = "Relevância dos museus como fontes de pauta\n(Não são relevantes | Sim, com limitações | Sim, são fontes muito relevantes)",
  capacitacao            = "Capacitação dos jornalistas para cobrir ciência\n(Precisam de mais capacitação | Sim, mas há espaço para melhorias | Sim, totalmente capacitados)",
  treinamento_suficiente = "Treinamento contínuo fornecido pelos veículos\n(Não | Sim)"
)

# ---- CORREÇÃO DAS CORES: nas perguntas dicotômicas, "Sim" (código 2) vira 3 (azul), sem barra intermediária ----
base3 <- base %>%
  mutate(across(c(espaco_suficiente, treinamento_suficiente), ~ ifelse(.x == 2, 3, .x)))

# ---- Distribuição calculada da base (NA = "não sei/sem opinião" excluído) ----
dist_k3 <- function(df, vars, rot_vars) {
  cont <- df %>%
    select(perfil, all_of(vars)) %>%
    pivot_longer(all_of(vars), names_to = "variavel", values_to = "codigo") %>%
    filter(!is.na(codigo)) %>%
    mutate(codigo = factor(codigo, levels = 1:3)) %>%
    count(perfil, variavel, codigo) %>%
    complete(perfil, variavel, codigo = factor(1:3, levels = 1:3), fill = list(n = 0)) %>%
    group_by(perfil, variavel) %>%
    mutate(n_valido = sum(n), pct = 100 * n / n_valido) %>%
    ungroup()
  
  wide <- cont %>%
    select(perfil, variavel, n_valido, codigo, pct) %>%
    pivot_wider(names_from = codigo, values_from = pct, names_prefix = "N") %>%
    mutate(
      perfil_nome = recode(perfil,
                           "Jornalista científico" = "Jornalistas Científicos",
                           "Generalista / outros"  = "Demais jornalistas"),
      perfil_lab = paste0(perfil_nome, " (n=", n_valido, ")"),
      var_lab    = factor(unname(rot_vars[variavel]), levels = unname(rot_vars))
    )
  list(cont = cont, wide = wide)
}

# ---- Gráfico divergente ----
plot_k3 <- function(wide, nota) {
  labs_p <- wide %>% distinct(perfil, perfil_lab) %>%
    arrange(desc(perfil == "Generalista / outros"), perfil_lab)
  wide$perfil_lab <- factor(wide$perfil_lab, levels = unique(labs_p$perfil_lab))
  
  seg <- wide %>%
    mutate(i1 = -(N1 + N2/2), f1 = -(N2/2),
           i2 = -(N2/2),      f2 =  (N2/2),
           i3 =  (N2/2),      f3 =  (N2/2) + N3,
           neg = N1, neu = N2, pos = N3) %>%
    pivot_longer(cols = matches("^[if][0-9]$"),
                 names_to = c(".value", "nivel"), names_pattern = "([if])([0-9])") %>%
    rename(ini = i, fim = f)
  rot <- seg %>% distinct(perfil_lab, var_lab, neg, neu, pos)
  
  ggplot(seg, aes(y = perfil_lab)) +
    facet_wrap(~ var_lab, ncol = 1, scales = "free_y") +
    geom_segment(aes(x = ini, xend = fim, color = nivel), linewidth = 10) +
    geom_text(data = rot, inherit.aes = FALSE, size = 3.5, hjust = 1,
              aes(x = -105, y = perfil_lab, label = ifelse(neg > 0, paste0(round(neg), "%"), ""))) +
    geom_text(data = rot, inherit.aes = FALSE, size = 3.5, hjust = 0,
              aes(x = 105, y = perfil_lab, label = ifelse(pos > 0, paste0(round(pos), "%"), ""))) +
    geom_text(data = rot, inherit.aes = FALSE, size = 3.5, color = "gray20",
              aes(x = 0, y = perfil_lab, label = ifelse(neu > 0, paste0(round(neu), "%"), ""))) +
    scale_color_manual(values = cores3, breaks = names(cores3), labels = rotulos3) +
    scale_x_continuous(limits = c(-120, 120), breaks = seq(-100, 100, 50), labels = abs) +
    labs(x = "Distribuição das respostas válidas (%)", y = "", color = "", caption = nota) +
    guides(color = guide_legend(nrow = 1, byrow = TRUE)) +
    theme_minimal(base_size = 12) +
    theme(legend.position = "bottom", legend.text = element_text(size = 9.5),
          strip.text = element_text(size = 10.5, lineheight = 0.95),
          plot.caption = element_text(hjust = 0, size = 8.5, color = "grey30"),
          panel.spacing = unit(1.2, "lines"),
          panel.grid.major.y = element_blank(), axis.text.y = element_text(face = "bold"))
}

# ---- Gráficos 19 (BR), 22 (CO) e 25 (PT) ----
num <- c(BR = 19, CO = 22, PT = 25)
for (p in names(num)) {
  r <- dist_k3(filter(base3, pais == p), vars3, rot3)
  cat("\n=== ", p, " ===\n"); print(r$cont %>% arrange(variavel, perfil, codigo), n = Inf)   # CONFIRA
  nota <- paste0("Respostas 'não sei/sem opinião' excluídas; n válido em cada barra. Espaço e treinamento têm apenas duas alternativas.",
                 if (p == "PT") " Jornalistas científicos de Portugal: n = 3 (percentuais meramente ilustrativos)." else "")
  nota <- paste(strwrap(nota, width = 140), collapse = "\n")        # <- quebra a nota em linhas
  g <- plot_k3(r$wide, nota) +
    theme(plot.caption.position = "plot",                            # <- alinha a nota à borda esquerda da figura
          plot.margin = margin(10, 15, 10, 10))                      # <- margem para nada encostar na borda
  ggsave(paste0("Grafico_", num[p], "_Bloco3_", p, ".png"), g, width = 11.5, height = 9.5, dpi = 300)
}
