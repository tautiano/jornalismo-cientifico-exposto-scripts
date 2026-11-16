# =============================================================================
# SCRIPT ORIGINAL DO AUTOR (código abaixo do cabeçalho sem alterações)
# Mapeamento da liderança e das instituições de cada CEPID (FAPESP) a partir do
# site cepid.fapesp.br (apoio à análise dos CEPIDs na Seção 3.x e ao Gráfico 2).
# Método : raspagem de páginas públicas (rvest), pausa de 1 s entre requisições,
#          extração por expressões regulares do texto das páginas.
# Saída  : Mapeamento_Lideranca_CEPIDs.xlsx (nome do CEPID, liderança, instituições citadas).
# Pacotes : rvest, tidyverse, writexl
# =============================================================================
# 1. Carregar os pacotes necessários
# (Se der erro de pacote não encontrado, use: install.packages(c("rvest", "tidyverse", "writexl")))
library(rvest)
library(tidyverse)
library(writexl)

# 2. Acessar a página principal e extrair os links
url_centros <- "https://cepid.fapesp.br/centros"
pagina_principal <- read_html(url_centros)

links_cepids <- pagina_principal %>%
  html_nodes("a") %>% 
  html_attr("href") %>%
  str_subset("/centro") %>% 
  unique()

url_base <- "https://cepid.fapesp.br"
links_completos <- ifelse(str_starts(links_cepids, "http"), links_cepids, paste0(url_base, links_cepids))

message(paste("Extraindo dados de", length(links_completos), "links... Aguarde."))

# 3. Função para varrer cada CEPID
extrair_dados_cepid <- function(url_centro) {
  
  Sys.sleep(1) # Pausa para não bloquear o servidor
  
  pagina_centro <- tryCatch({
    read_html(url_centro)
  }, error = function(e) { return(NULL) })
  
  if (is.null(pagina_centro)) return(tibble())
  
  # Pega o nome do CEPID no título da aba
  nome_cepid <- pagina_centro %>% 
    html_node("title") %>% 
    html_text(trim = TRUE) %>%
    str_remove(" - Centros de Pesquisa, Inovação e Difusão") %>%
    str_remove(" - Cepid-Fapesp")
  
  # Extrai o texto do corpo
  texto_pagina <- pagina_centro %>% html_nodes("p, div") %>% html_text(trim = TRUE)
  texto_completo <- paste(texto_pagina, collapse = " | ")
  
  # Regex para Diretoria e Instituições
  pesquisadores <- str_extract_all(texto_completo, "(?i)(Pesquisador responsável|Diretor|Coordenador)[^:]*:\\s*[A-ZÀ-Ÿ][a-zà-ÿA-ZÀ-Ÿ\\s]+")[[1]]
  pesquisadores <- str_remove_all(pesquisadores, "\\s*\\|\\s*") %>% trimws()
  
  instituicoes <- str_extract_all(texto_completo, "(?i)(Universidade|Instituto|Faculdade|Centro Brasileiro|Fundação)[A-Za-zÀ-ÿ\\sde]+(?:\\([A-Z-]+\\))?")[[1]]
  instituicoes <- unique(trimws(instituicoes))
  instituicoes <- instituicoes[str_length(instituicoes) > 15] 
  
  # Estrutura a linha de dados
  tibble(
    CEPID = ifelse(is.na(nome_cepid) | nome_cepid == "", "Nome não encontrado", nome_cepid),
    Lideranca = paste(pesquisadores, collapse = "; "),
    Instituicoes_Citadas = paste(instituicoes, collapse = "; ")
  )
}

# 4. Executar a varredura (pode levar alguns segundos)
df_cepids <- map_df(links_completos, extrair_dados_cepid)

# 5. Limpar os resultados vazios e remover duplicatas
df_cepids_limpo <- df_cepids %>%
  filter(Lideranca != "" | Instituicoes_Citadas != "") %>%
  distinct(CEPID, .keep_all = TRUE)

# 6. Salvar em XLSX e visualizar
write_xlsx(df_cepids_limpo, "Mapeamento_Lideranca_CEPIDs.xlsx")

message("Extração concluída! O arquivo 'Mapeamento_Lideranca_CEPIDs.xlsx' foi salvo na sua pasta:")
print(getwd())

View(df_cepids_limpo)
