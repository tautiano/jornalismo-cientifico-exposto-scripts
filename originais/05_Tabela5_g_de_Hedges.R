# =============================================================================
# SCRIPT ORIGINAL DO AUTOR (código abaixo do cabeçalho sem alterações)
# Tabela 5: g de Hedges (jornalistas científicos menos demais jornalistas) para as
# 12 variáveis dos Blocos 1, 2 e 3, por país (BR, CO, PT), conforme a Seção 7.9.1.
# g > 0: escore médio mais alto entre os científicos. Resultado arredondado a 2 casas.
# O script NÃO calcula IC 95% nem teste de Mann-Whitney (ver modelos_reconstruidos/04).
# Entrada : base_unica_83.xlsx, aba "Base" (NÃO disponibilizada; ver docs/DICIONARIO_BASE.md).
# Saída   : tabela "resultados_hedges" impressa no console.
# Pacotes : readxl, dplyr, tidyr
# =============================================================================
library(readxl)
library(dplyr)
library(tidyr)

# 1. Carregar a base de dados principal
base <- read_excel(file.choose(), sheet = "Base") # Selecione base_unica_83.xlsx

# 2. Função pura para cálculo paramétrico do g de Hedges (Científicos menos Outros)
calcular_hedges_g <- function(df, variavel) {
  # Filtra missings da variável em questão
  df_valido <- df %>% 
    select(perfil, val = all_of(variavel)) %>% 
    filter(!is.na(val))
  
  # Separa os vetores de resposta
  g_cientistas <- df_valido %>% filter(perfil == "Jornalista científico") %>% pull(val)
  g_demais     <- df_valido %>% filter(perfil == "Generalista / outros") %>% pull(val)
  
  n1 <- length(g_cientistas)
  n2 <- length(g_demais)
  
  # Se faltar dados em um dos grupos para calcular variância, retorna NA
  if(n1 < 2 | n2 < 2) return(NA)
  
  m1 <- mean(g_cientistas)
  m2 <- mean(g_demais)
  s1 <- sd(g_cientistas)
  s2 <- sd(g_demais)
  
  # Desvio-padrão combinado (pooled variance)
  sp <- sqrt(((n1 - 1) * s1^2 + (n2 - 1) * s2^2) / (n1 + n2 - 2))
  
  # Evita divisão por zero se houver unanimidade absoluta (todos responderem igual)
  if(sp == 0) return(NA)
  
  # d de Cohen
  d <- (m1 - m2) / sp
  
  # Fator de Correção de Hedges para amostras pequenas (df = n1 + n2 - 2)
  df_lib <- n1 + n2 - 2
  j_correcao <- 1 - (3 / (4 * df_lib - 1))
  
  # g de Hedges final
  g <- d * j_correcao
  
  return(round(g, 2))
}

# 3. Variáveis dos Blocos 1, 2 e 3
variaveis_teste <- c(
  "freq_ciencia", "freq_museus", "prioridade_museus", 
  "estrategias", "entretenimento", "visibilidade", "valorizacao",
  "impacto", "espaco_suficiente", "pauta_museus", "capacitacao", "treinamento_suficiente"
)

# 4. Estruturar a Tabela de Resultados
resultados_hedges <- data.frame(Variavel = variaveis_teste)

for (pais_alvo in c("BR", "CO", "PT")) {
  base_pais <- base %>% filter(pais == pais_alvo)
  valores_g <- sapply(variaveis_teste, function(v) calcular_hedges_g(base_pais, v))
  resultados_hedges[[paste0("g_", pais_alvo)]] <- valores_g
}

# 5. Exibir a matriz final auditada
print(resultados_hedges)
