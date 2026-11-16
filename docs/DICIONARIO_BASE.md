# Dicionário da base `base_unica_83.xlsx` (aba "Base"), uma linha por respondente (N = 83)

A base real **não está disponibilizada** (anonimização). Este dicionário permite montar um arquivo
equivalente. `NA` (célula vazia) = "não sei / sem opinião" ou evasão; é excluído dos percentuais.

| Coluna | Valores | Conteúdo |
|---|---|---|
| pais | BR, CO, PT | País do respondente (BR = 43, CO = 19, PT = 21) |
| perfil | "Jornalista científico" ou "Generalista / outros" | Perfil de atuação |
| freq_museus | 1-5 | Frequência de cobertura de museus de ciência (1 = Nunca ... 5 = Sempre) |
| freq_ciencia | 1-5 | Frequência de cobertura de temas científicos (1 = Nunca ... 5 = Sempre) |
| prioridade_museus | 1-5 | Prioridade da comunicação pelos museus (1 = Muito baixo ... 5 = Muito alto) |
| estrategias | 1-3 | Carecem de estratégias / Utilizam algumas / Utilizam estratégias eficazes |
| entretenimento | 1-3 | Pode desviar o foco / Sim, com limitações / Sim, completamente |
| visibilidade | 1-3 | Não teria impacto / Sim, de forma limitada / Sim, significativamente |
| valorizacao | 1-3 | É subvalorizado / Está começando a ganhar relevância / Está valorizado |
| impacto | 1-3 | Pouco impacto / Impacto moderado / Muito impacto |
| espaco_suficiente | 1-2 | 1 = Não, o espaço é limitado; 2 = Sim, há espaço suficiente (o script recodifica 2 para 3) |
| pauta_museus | 1-3 | Não são relevantes / Sim, com limitações / Sim, são fontes muito relevantes |
| capacitacao | 1-3 | Precisam de mais capacitação / Sim, mas há espaço para melhorias / Sim, totalmente capacitados |
| treinamento_suficiente | 1-2 | 1 = Não; 2 = Sim (o script recodifica 2 para 3) |

Os rótulos exatos de cada alternativa estão nos próprios scripts (`rot1`, `rot2`, `rot3`).
Para testar os scripts, use `dados_exemplo_FICTICIOS/base_unica_83_FICTICIA.xlsx` (valores inventados).
