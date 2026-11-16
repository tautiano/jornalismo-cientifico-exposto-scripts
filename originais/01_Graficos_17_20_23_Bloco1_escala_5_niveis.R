# =============================================================================
# SCRIPT ORIGINAL DO AUTOR (código abaixo do cabeçalho sem alterações)
# Gráficos 17 (Brasil), 20 (Colômbia) e 23 (Portugal): Bloco 1, escala clássica
# de 5 níveis, jornalistas científicos x demais jornalistas (Seção 7.x da tese).
# Entrada : base_unica_83.xlsx, aba "Base" (NÃO disponibilizada: dados a anonimizar;
#           ver docs/DICIONARIO_BASE.md para colunas e codificação).
# Saída   : Grafico_Bloco1_BR.png, _CO.png, _PT.png e, no console, as contagens
#           que fundamentam cada percentual.
# Pacotes : readxl, dplyr, tidyr, ggplot2
# =============================================================================
library(readxl); library(dplyr); library(tidyr); library(ggplot2)

base <- read_excel(file.choose(), sheet = "Base")   # escolha base_unica_83.xlsx

# ---- 1. Distribuição percentual calculada da base (NA excluído) ----
dist_likert <- function(df, vars, rot_vars, k) {
  cont <- df %>%
    select(perfil, all_of(vars)) %>%
    pivot_longer(all_of(vars), names_to = "variavel", values_to = "codigo") %>%
    filter(!is.na(codigo)) %>%
    mutate(codigo = factor(codigo, levels = 1:k)) %>%
    count(perfil, variavel, codigo) %>%
    complete(perfil, variavel, codigo = factor(1:k, levels = 1:k), fill = list(n = 0)) %>%
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

# ---- 2. Segmentos do gráfico divergente (k = 5 ou 3 níveis) ----
long_seg <- function(d, k) {
  if (k == 5) {
    d <- d %>% mutate(
      i1 = -(N1 + N2 + N3/2), f1 = -(N2 + N3/2),
      i2 = -(N2 + N3/2),      f2 = -(N3/2),
      i3 = -(N3/2),           f3 =  (N3/2),
      i4 =  (N3/2),           f4 =  (N3/2) + N4,
      i5 =  (N3/2) + N4,      f5 =  (N3/2) + N4 + N5,
      neg = N1 + N2, neu = N3, pos = N4 + N5)
  } else {
    d <- d %>% mutate(
      i1 = -(N1 + N2/2), f1 = -(N2/2),
      i2 = -(N2/2),      f2 =  (N2/2),
      i3 =  (N2/2),      f3 =  (N2/2) + N3,
      neg = N1, neu = N2, pos = N3)
  }
  d %>%
    pivot_longer(cols = matches("^[if][0-9]$"),
                 names_to = c(".value", "nivel"), names_pattern = "([if])([0-9])") %>%
    rename(ini = i, fim = f)
}

# ---- 3. Gráfico ----
plot_div <- function(wide, k, cores, rotulos) {
  labs <- wide %>% distinct(perfil, perfil_lab) %>%
    arrange(desc(perfil == "Generalista / outros"), perfil_lab)
  wide$perfil_lab <- factor(wide$perfil_lab, levels = unique(labs$perfil_lab))
  seg <- long_seg(wide, k)
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
    scale_color_manual(values = cores, breaks = names(cores), labels = rotulos) +
    scale_x_continuous(limits = c(-120, 120), breaks = seq(-100, 100, 50), labels = abs) +
    labs(x = "Frequência (%)", y = "", color = "") +
    guides(color = guide_legend(nrow = 1, byrow = TRUE)) +
    theme_minimal(base_size = 12) +
    theme(legend.position = "bottom", legend.text = element_text(size = 9.5),
          strip.text = element_text(size = 11), panel.spacing = unit(1.2, "lines"),
          panel.grid.major.y = element_blank(), axis.text.y = element_text(face = "bold"))
}

# ---- 4. Bloco 1 para os três países ----
vars1 <- c("freq_museus", "freq_ciencia", "prioridade_museus")
rot1  <- c(freq_museus       = "Frequência de cobertura de museus de ciência",
           freq_ciencia      = "Frequência de cobertura de temas científicos",
           prioridade_museus = "Nível de prioridade da comunicação pelos museus")
cores5   <- c("1" = "#b2182b", "2" = "#ef8a62", "3" = "#e0e0e0", "4" = "#2166ac", "5" = "#67a9cf")
rotulos5 <- c("Muito baixo/Nunca", "Baixo/Raramente", "Moderado/Ocasionalmente", "Alto/Freq.", "Muito alto/Sempre")

for (p in c("BR", "CO", "PT")) {
  r <- dist_likert(filter(base, pais == p), vars1, rot1, k = 5)
  print(p); print(r$cont %>% arrange(variavel, perfil, codigo), n = Inf)   # CONFIRA as contagens
  g <- plot_div(r$wide, 5, cores5, rotulos5)
  ggsave(paste0("Grafico_Bloco1_", p, ".png"), g, width = 11.5, height = 5.5, dpi = 300)
}
