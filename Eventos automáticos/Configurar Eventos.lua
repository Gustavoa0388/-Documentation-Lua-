-- CONFIGURAÇÕES DOS EVENTOS AUTOMÁTICOS

-- Na opção abaixo, se estiver = 1 os eventos iniciarão automáticamente e aleatóriamente de 1 em 1 minuto caso não haja staffers online.
-- Se estiver = 0 os eventos iniciarão nos horários que você definir abaixo.
EVENTOS_INICIO_AUTOMATICO = 0


-- CONFIGURAR APENAS SE NA OPÇÃO ACIMA ESTIVER = 0 (você pode definir até 3 horários para cada evento)
-- Obs: Configure com Hora, Minuto e Segundo, exemplo: 15:30:45 (iniciará às 15 horas, 30 minutos e 45 segundos).
-- Obs 2: Nesta configuração, os eventos iniciarão mesmo com staffers online

HORARIO_MATAMATA = "00:00:00" -- Horário do 1º MATA-MATA
HORARIO_MATAMATA2 = "00:00:00" -- Horário do 2º MATA-MATA
HORARIO_MATAMATA3 = "00:00:00" -- Horário do 3º MATA-MATA

HORARIO_X1PREMIADO = "00:00:00" -- Horário do 1º X1 PREMIADO
HORARIO_X1PREMIADO2 = "00:00:00" -- Horário do 2º X1 PREMIADO
HORARIO_X1PREMIADO3 = "00:00:00" -- Horário do 3º X1 PREMIADO

HORARIO_CORRIDADAMORTE = "00:00:00" -- Horário do 1º CORRIDA DA MORTE
HORARIO_CORRIDADAMORTE2 = "00:00:00" -- Horário do 2º CORRIDA DA MORTE
HORARIO_CORRIDADAMORTE3 = "00:00:00" -- Horário do 3º CORRIDA DA MORTE

HORARIO_ESCONDEESCONDE = "00:00:00" -- Horário do 1º ESCONDE ESCONDE
HORARIO_ESCONDEESCONDE2 = "00:00:00" -- Horário do 2º ESCONDE ESCONDE
HORARIO_ESCONDEESCONDE3 = "00:00:00" -- Horário do 3º ESCONDE ESCONDE

HORARIO_MOVEUACHOU = "00:00:00" -- Horário do 1º MOVEU ACHOU
HORARIO_MOVEUACHOU2 = "00:00:00" -- Horário do 2º MOVEU ACHOU
HORARIO_MOVEUACHOU3 = "00:00:00" -- Horário do 3º MOVEU ACHOU

HORARIO_PKSVSHEROS = "00:00:00" -- Horário do 1º PKS VS HEROS
HORARIO_PKSVSHEROS2 = "00:00:00" -- Horário do 2º PKS VS HEROS
HORARIO_PKSVSHEROS3 = "00:00:00" -- Horário do 3º PKS VS HEROS

HORARIO_QUIZX4 = "00:00:00" -- Horário do 1º QUIZ X4
HORARIO_QUIZX42 = "00:00:00" -- Horário do 2º QUIZ X4
HORARIO_QUIZX43 = "00:00:00" -- Horário do 3º QUIZ X4

HORARIO_RESTA1 = "00:00:00" -- Horário do 1º RESTA 1
HORARIO_RESTA12 = "00:00:00" -- Horário do 2º RESTA 1
HORARIO_RESTA13 = "00:00:00" -- Horário do 3º RESTA 1

HORARIO_SOBREVIVENCIA = "00:00:00" -- Horário do 1º SOBREVIVÊNCIA
HORARIO_SOBREVIVENCIA2 = "00:00:00" -- Horário do 2º SOBREVIVÊNCIA
HORARIO_SOBREVIVENCIA3 = "00:00:00" -- Horário do 3º SOBREVIVÊNCIA

HORARIO_THEFLASH = "00:00:00" -- Horário do 1º THE FLASH
HORARIO_THEFLASH2 = "00:00:00" -- Horário do 2º THE FLASH
HORARIO_THEFLASH3 = "00:00:00" -- Horário do 3º THE FLASH

HORARIO_TIMEXTIME = "00:00:00" -- Horário do 1º TIME X TIME
HORARIO_TIMEXTIME2 = "00:00:00" -- Horário do 2º TIME X TIME
HORARIO_TIMEXTIME3 = "00:00:00" -- Horário do 3º TIME X TIME

HORARIO_TRADEWINS = "00:00:00" -- Horário do 1º TRADE WINS
HORARIO_TRADEWINS2 = "00:00:00" -- Horário do 2º TRADE WINS
HORARIO_TRADEWINS3 = "00:00:00" -- Horário do 1º TRADE WINS

HORARIO_CACAAOTESOURO = "00:00:00" -- Horário do 1º CAÇA AO TESOURO
HORARIO_CACAAOTESOURO2 = "00:00:00" -- Horário do 2º CAÇA AO TESOURO
HORARIO_CACAAOTESOURO3 = "00:00:00" -- Horário do 3º CAÇA AO TESOURO


-- Colunas de eventos:
-- Obs: Colunas de eventos ficam tudo na tabela: Character!
COLUNA_MATAMATA = "mtmt"
COLUNA_X1PREMIADO = "x1premiado"
COLUNA_CORRIDADAMORTE = "corridadamorte"
COLUNA_ESCONDEESCONDE = "escesc"
COLUNA_MOVEUACHOU = "machou"
COLUNA_PKSVSHEROS = "pksvsheros"
COLUNA_QUIZX4 = "quizx4"
COLUNA_RESTA1 = "resta1"
COLUNA_SOBREVIVENCIA = "sobre"
COLUNA_THEFLASH = "theflash"
COLUNA_TIMEXTIME = "timextime"
COLUNA_TRADEWINS = "tradew"
COLUNA_CACAAOTESOURO = "cacatesouro"

-- Colunas que registram quantos eventos os players ganharam
-- ** Obs: Essas colunas não são alteráveis. Somente essas. **
EVENTOS_DIARIO = "eventos_diario"
EVENTOS_SEMANAL = "eventos_semanal"
EVENTOS_TOTAL = "eventos_total"


-- Colunas de Premiação de eventos
COLUNA_PREMIOEVENTOS = "gold"
NOME_MOEDA_EVENTO = "CGold's" -- Nome da Moeda

-- Premiação de eventinhos
PREMIO_EVENTINHOS = 5

-- Premiação de eventos grandes (mata-mata, etç)
PREMIO_EVENTOGRANDE_1LUGAR = 20 -- prêmio 1º lugar
PREMIO_EVENTOGRANDE_2LUGAR = 15 -- prêmio 2º lugar
PREMIO_EVENTOGRANDE_3LUGAR = 10 -- prêmio 3º lugar

-- Premiação em pontos para eventinhos
PONTOS_EVENTINHOS = 1

-- Premiação em pontos para eventos grandes
PONTOS_1LUGAR = 3
PONTOS_2LUGAR = 2
PONTOS_3LUGAR = 1


-- Itens Permitidos no Mata-Mata Bônus

MATAMATABONUS_ID_SET = 60 -- ID do Set no item.txt
MATAMATABONUS_NOME_SET = "Set Darkness" -- Nome do Set Bônus

MATAMATABONUS_SECTION_ARMA = 0 -- Section da Arma no item.txt (Exemplo: Swords = 0 / Axes = 1 / Maces = 2)
MATAMATABONUS_ID_ARMA = 50 -- ID da Arma (Sword/Mace,etç) no item.txt
MATAMATABONUS_NOME_ARMA = "Sword Darkness" -- Nome da Arma Bônus

MATAMATABONUS_ID_SHIELD = 100 -- ID do Shield no item.txt
MATAMATABONUS_NOME_SHIELD = "Shield Darkness" -- Nome do Shield Bônus

MATAMATABONUS_ID_WING = 120 -- ID da Wing no item.txt
MATAMATABONUS_NOME_WING = "Wing Darkness" -- Nome da Wing Bônus

MATAMATABONUS_ID_PET = 70 -- ID do Pet no item.txt
MATAMATABONUS_NOME_PET = "Pet Darkness" -- Nome do Pet Bônus

MATAMATABONUS_ID_PENDANT = 80 -- ID do Pendant no item.txt
MATAMATABONUS_NOME_PENDANT = "Pendant Darkness" -- Nome do Pendant Bônus

MATAMATABONUS_ID_RING = 70 -- ID do Ring no item.txt
MATAMATABONUS_NOME_RING = "Rings Darkness" -- Nome do Ring Bônus
