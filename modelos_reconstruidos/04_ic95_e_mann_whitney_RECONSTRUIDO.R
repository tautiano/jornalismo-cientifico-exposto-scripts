# 04_ic95_e_mann_whitney_RECONSTRUIDO.R -------------------------------------------
# COMPLEMENTO RECONSTRUÍDO (não é o script original; não executado em R pelo redator).
# O script original da Tabela 5 (originais/05) calcula só o g. Este acrescenta,
# para as mesmas 12 variáveis e a mesma base, o IC 95% do g e o teste de Mann-Whitney
# citados na Seção 7.9.1. O g usa exatamente a mesma fórmula do original.
#   SE(g) = sqrt((n1+n2)/(n1*n2) + g^2/(2*(n1+n2)))   (erro-padrão assintótico usual)
# Se você calculou IC e p de outra forma, substitua este arquivo pelo seu script.

library(readxl); library(dplyr); library(tidyr); library(purrr)

base <- read_excel(file.choose(), sheet = "Base")   # base_unica_83.xlsx (ou a base fictícia)

variaveis_teste <- c("freq_ciencia", "freq_museus", "prioridade_museus",
                     "estrategias", "entretenimento", "visibilidade", "valorizacao",
                     "impacto", "espaco_suficiente", "pauta_museus", "capacitacao", "treinamento_suficiente")

efeito <- function(df, variavel) {
  d  <- df %>% select(perfil, val = all_of(variavel)) %>% filter(!is.na(val))
  x1 <- d %>% filter(perfil == "Jornalista científico") %>% pull(val)
  x2 <- d %>% filter(perfil == "Generalista / outros") %>% pull(val)
  n1 <- length(x1); n2 <- length(x2)
  vazio <- tibble(n1 = n1, n2 = n2, g = NA_real_, ic95_inf = NA_real_, ic95_sup = NA_real_,
                  W = NA_real_, p_mw = NA_real_)
  if (n1 < 2 | n2 < 2) return(vazio)
  sp <- sqrt(((n1 - 1) * var(x1) + (n2 - 1) * var(x2)) / (n1 + n2 - 2))
  if (sp == 0) return(vazio)
  g  <- (mean(x1) - mean(x2)) / sp * (1 - 3 / (4 * (n1 + n2 - 2) - 1))
  se <- sqrt((n1 + n2) / (n1 * n2) + g^2 / (2 * (n1 + n2)))
  mw <- suppressWarnings(wilcox.test(x1, x2, exact = FALSE))   # Likert tem empates
  tibble(n1 = n1, n2 = n2, g = g,
         ic95_inf = g - qnorm(0.975) * se, ic95_sup = g + qnorm(0.975) * se,
         W = unname(mw$statistic), p_mw = mw$p.value)
}

res <- expand_grid(pais = c("BR", "CO", "PT"), variavel = variaveis_teste) %>%
  mutate(r = map2(pais, variavel, \(p, v) efeito(filter(base, pais == p), v))) %>%
  unnest(r) %>%
  mutate(classificacao = cut(abs(g), breaks = c(-Inf, 0.2, 0.5, 0.8, Inf), right = FALSE,
                             labels = c("desprezível", "pequeno", "médio", "grande")),
         across(c(g, ic95_inf, ic95_sup), \(x) round(x, 2)),
         p_mw = round(p_mw, 4))

print(res, n = Inf)
write.csv(res, "tabela_g_IC_mannwhitney.csv", row.names = FALSE)
