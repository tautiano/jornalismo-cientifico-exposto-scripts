# Scripts em R – Apêndice da tese "Jornalismo Científico Exposto"

Autor: Cristiano Rodrigues da Mota · Tese (Doutorado), PROLAM/USP, 2026.

## 1. O que há aqui

| Pasta | Conteúdo | Origem |
|---|---|---|
| `originais/` | Gráficos 17 a 25 (Blocos 1, 2 e 3 do questionário), Tabela 5 (g de Hedges) e mapeamento dos CEPIDs | **Do autor.** Código inalterado; só foi acrescentado um cabeçalho explicativo |
| `modelos_reconstruidos/` | (a) IC 95% e teste de Mann-Whitney para as 12 variáveis; (b) coleta e classificação de autoria em jornais (modelo dos Gráficos 8 a 10) | **Reconstruídos a partir do protocolo descrito na tese.** Não são os scripts originais e **não foram executados em R** |
| `dados_exemplo_FICTICIOS/` | Base de 83 linhas com valores **inventados** e tabela de valores esperados, só para testar os scripts | Fictícios |
| `docs/` | Dicionário da base e modelo de protocolo de coleta | Do autor / modelo |

## 2. Relação entre scripts e figuras/tabelas da tese

| Script | Produz |
|---|---|
| `originais/01_...Bloco1...R` | Gráficos 17 (Brasil), 20 (Colômbia), 23 (Portugal) |
| `originais/02_...Bloco2.R` | Gráficos 18, 21, 24 (e `Bloco2_contagens_*.csv`) |
| `originais/03_...Bloco3.R` | Gráficos 19, 22, 25 |
| `originais/04_Mapeamento_CEPIDs_raspagem.R` | Planilha de liderança e instituições dos CEPIDs (apoio ao Gráfico 2) |
| `originais/05_Tabela5_g_de_Hedges.R` | g de Hedges por variável e país (Tabela 5, Seção 7.9.1) |
| `modelos_reconstruidos/04_ic95_e_mann_whitney_RECONSTRUIDO.R` | IC 95% do g e p de Mann-Whitney para as mesmas variáveis, sobre a mesma base |
| `modelos_reconstruidos/00-03, 99` | Modelos de coleta/classificação de autoria em jornais e gráficos 8 a 10 |

## 3. Fórmulas (Seção 7.9.1)

* Desvio-padrão combinado: s_p = raiz de [ ((n1 - 1)·s1² + (n2 - 1)·s2²) / (n1 + n2 - 2) ]
* d de Cohen: d = (média1 - média2) / s_p (grupo 1 = jornalistas científicos; grupo 2 = demais)
* Fator de Hedges: J = 1 - 3 / (4·gl - 1), com gl = n1 + n2 - 2; g = d · J
* IC 95%: g ± 1,96 · EP, com EP = raiz de [ (n1 + n2)/(n1·n2) + g²/(2·(n1 + n2)) ]
* Teste de Mann-Whitney (Wilcoxon de soma de postos), aproximação normal com correção de continuidade e de empates
* Respostas "não sei/sem opinião" (NA) são excluídas antes de cada cálculo.

## 4. Como usar

1. Instale R (≥ 4.1) e os pacotes citados no cabeçalho de cada script.
2. Defina a pasta do pacote como diretório de trabalho (`setwd()`).
3. Rode os scripts; quando o R abrir a janela de seleção, escolha `base_unica_83.xlsx` (a real, que não está neste repositório) ou a base fictícia para teste. O formato das colunas está em `docs/DICIONARIO_BASE.md`.
4. As contagens que fundamentam cada percentual aparecem no console dos scripts de gráficos.

## 5. O que não está disponível e por quê

As planilhas com as respostas individuais (`base_unica_83.xlsx`) e as bases derivadas das entrevistas **não foram disponibilizadas**, pois exigem anonimização para preservar o sigilo dos participantes, sobretudo nos subgrupos pequenos (por exemplo, jornalistas científicos de Portugal, n = 3). O repositório reproduz apenas os **procedimentos e fórmulas** usados nos cálculos e gráficos.

## 6. Teste com dados fictícios

Rodando `originais/05_...` e `modelos_reconstruidos/04_...` sobre `dados_exemplo_FICTICIOS/base_unica_83_FICTICIA.xlsx`, os valores devem coincidir com os de `valores_esperados_FICTICIOS.csv` (referência independente em Python; a coluna `g_script_original` é o g arredondado em 2 casas). Diferenças na 3ª casa decimal por arredondamento são normais. Os valores são inventados e não têm relação com a pesquisa.

## 7. Cuidados

* A raspagem dos CEPIDs usa páginas públicas, com pausa de 1 s por requisição. Confira os termos de uso do site e registre a data da coleta.
* A extração por expressões regulares exige conferência manual dos resultados (nomes e instituições).
* Registre a versão do R e dos pacotes: `writeLines(capture.output(sessionInfo()), "ambiente_R.txt")`.
