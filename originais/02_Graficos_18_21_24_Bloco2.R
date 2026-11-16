# =============================================================================
# SCRIPT ORIGINAL DO AUTOR (código abaixo do cabeçalho sem alterações)
# Gráficos 18 (Brasil), 21 (Colômbia) e 24 (Portugal): Bloco 2, quatro perguntas
# com três alternativas cada (códigos 1-2-3), jornalistas científicos x demais.
# Entrada : base_unica_83.xlsx, aba "Base" (NÃO disponibilizada; ver docs/DICIONARIO_BASE.md).
# Saída   : Grafico_Bloco2_BR.png, _CO.png, _PT.png; Bloco2_contagens_BR/CO/PT.csv
#           (as contagens dessas tabelas fundamentam os percentuais dos gráficos).
# Pacotes : readxl, dplyr, tidyr, ggplot2
# =============================================================================
library(readxl); library(dplyr); library(tidyr); library(ggplot2)

base <- read_excel(file.choose(), sheet = "Base")   # escolha base_unica_83.xlsx

# ---- 1. As quatro perguntas do Bloco 2 (códigos 1-2-3 = da menos à mais favorável) ----
vars2 <- c("estrategias", "entretenimento", "visibilidade", "valorizacao")
rot2  <- c(
  estrategias    = "Adequação das estratégias de atração midiática\n(Carecem de estratégias | Utilizam algumas | Utilizam estratégias eficazes)",
  entretenimento = "Eficácia do entretenimento como aproximação\n(Pode desviar o foco | Sim, com limitações | Sim, completamente)",
  visibilidade   = "Potencial do jornalismo científico para aumentar a visibilidade\n(Não teria impacto | Sim, de forma limitada | Sim, significativamente)",
  valorizacao    = "Valorização do jornalismo científico no campo\n(É subvalorizado | Está começando a ganhar relevância | Está valorizado)"
)
cores3   <- c("1" = "#b2182b", "2" = "#e0e0e0", "3" = "#2166ac")
rotulos3 <- c("Resposta desfavorável", "Resposta intermediária (com ressalvas)", "Resposta favorável")

# ---- 2. Distribuição calculada da base (NA = "não sei"/"sem opinião" excluído) ----
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

# ---- 3. Gráfico divergente de 3 opções (a intermediária fica no centro) ----
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

# ---- 4. Os três países ----
for (p in c("BR", "CO", "PT")) {
  r <- dist_k3(filter(base, pais == p), vars2, rot2)
  cat("\n=== ", p, " ===\n"); print(r$cont %>% arrange(variavel, perfil, codigo), n = Inf)  # CONFIRA
  write.csv(r$cont, paste0("Bloco2_contagens_", p, ".csv"), row.names = FALSE)
  nota <- paste0("Respostas 'não sei/sem opinião' excluídas; n válido em cada barra.",
                 if (p == "PT") " Jornalistas científicos de Portugal: n = 3 (percentuais meramente ilustrativos)." else "")
  g <- plot_k3(r$wide, nota)
  ggsave(paste0("Grafico_Bloco2_", p, ".png"), g, width = 11.5, height = 7.8, dpi = 300)
}
