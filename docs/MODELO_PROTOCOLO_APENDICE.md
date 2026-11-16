# Protocolo de coleta e tratamento dos dados de autoria (modelo para o apêndice)

Preencha os campos entre [colchetes]. Itens em **negrito** o texto da tese ainda não informa.

## 1. Objetivo e recorte
* Variável: grupo de autoria das publicações de ciência. Veículos: Folha de S.Paulo, El Espectador e Público.
* Período de publicação: **[01/01/2025 a 31/12/2025?]**. Data(s) da coleta: **[dd/mm/2026]**.
* Critério de seleção dos veículos (intencional, conforme a Seção 3.x): [acessibilidade, acervo digital com editoria de ciência aberta e indexada].

## 2. Coleta
| Veículo | Seção/editoria raspada | URLs de partida | Método | Campos extraídos | Observações |
|---|---|---|---|---|---|
| Folha | [ ] | [ ] | [ ] | título, data, assinatura, seção, URL | [ ] |
| El Espectador | [ ] | [ ] | [ ] | idem | [ ] |
| Público | [ ] | [ ] | [ ] | idem | [ ] |

* Ferramenta e versão: R [versão]; pacotes [lista de ambiente_R.txt].
* Respeito a robots.txt, ritmo de requisições e termos de uso: [descrever]. Acesso a conteúdo restrito: [descrever].

## 3. Fluxo de dados (preencher com tabela_fluxo_coleta.csv)
| Veículo | Coletados | Download ok | Publicados no ano | Sem duplicatas | Revisados à mão | Alterados | Base final |
|---|---|---|---|---|---|---|---|

## 4. Critérios de classificação do grupo de autoria
| Grupo | Definição operacional | Exemplos de assinatura | Regra aplicada |
|---|---|---|---|
| Agência / Agencias / Agências-Veículos | [ ] | [ ] | [regex / lista] |
| Cientistas | [ ] | [ ] | [ ] |
| Jornalista(s) / Periodistas | [ ] | [ ] | [ ] |
| Jornalista(s) científico(s) / de Ciência | [como foi definido: formação, editoria, lista?] | [ ] | [ ] |
| Redacción Ciencia / Público (assinatura institucional) | [ ] | [ ] | [ ] |

Matérias com vários autores: [regra]. Sem assinatura: [regra].

## 5. Limpeza manual
* Veículos com limpeza manual: Folha e El Espectador. Motivo: [ ].
* Procedimento: [quem revisou, ferramenta, critérios de decisão, quantas linhas].
* Auditoria: amostra de [5]% das classificações automáticas; erro encontrado: [x]%.
* Casos limite e como foram decididos: [ ].

## 6. Disponibilização
* Local: [link do Drive], depositado em [data]; SHA-256 do arquivo: [ ].
* Conteúdo: scripts, base final de metadados, log de decisões, tabela de fluxo, ambiente R.
* Não estão disponibilizados: texto integral das matérias [direitos autorais / termos de uso].
