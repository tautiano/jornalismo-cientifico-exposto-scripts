# 99_registrar_ambiente.R -----------------------------------------------------------
# Registra a versão do R e dos pacotes usados (cite no apêndice).
source("modelos_reconstruidos/00_config.R")
writeLines(capture.output(sessionInfo()), "ambiente_R.txt")
message("Gravado em ambiente_R.txt")
