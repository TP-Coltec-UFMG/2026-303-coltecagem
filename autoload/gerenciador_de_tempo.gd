extends Node
## ============================================================
## GerenciadorDeTempo
## ------------------------------------------------------------
## Autoload responsável pelo "relógio" do jogo: os 7 blocos de
## horário reais do COLTEC (07:30 → 09:10 → 09:30 → 11:10 → 13:30
## → 15:10 → 15:30 → 17:10), com o tempo real de cada bloco
## proporcional à duração real dele (recreios curtos passam rápido,
## aulas longas demoram mais), e quantas ações o jogador ainda pode
## fazer dentro do bloco atual.
##
## IMPORTANTE — como isso se encaixa com as ações (aula, estudar,
## comer, dormir, prova):
## Este script NÃO sabe como uma ação acontece por dentro (se é
## por timer de presença, clique, ou instantânea). Ele só conta
## "1 ficha de ação" toda vez que uma ação é CONCLUÍDA. Quem
## implementar a mecânica de cada ação (timer de presença na sala
## de aula, cliques na biblioteca, etc) deve:
##   1. checar GerenciadorDeTempo.pode_agir() antes de começar
##   2. no final da ação, chamar GerenciadorDeTempo.consumir_acao()
##
## Como usar de qualquer script:
##     GerenciadorDeTempo.iniciar_dia()
##     if GerenciadorDeTempo.pode_agir():
##         ...
##         GerenciadorDeTempo.consumir_acao()
## ============================================================

# ---------------------------------------------------------------
# SINAIS
# ---------------------------------------------------------------

## Disparado sempre que um novo bloco de horário começa.
## nome_horario = hora de início do bloco (ex: "07:30")
## limite_acoes = ACOES_ILIMITADAS (-1) ou um número fixo
signal bloco_iniciado(indice: int, nome_horario: String, limite_acoes: int)

## Disparado a cada frame com o tempo restante do bloco atual.
## progresso vai de 0.0 (início do bloco) a 1.0 (fim do bloco) —
## útil pra UI animar uma barra de tempo.
signal tempo_atualizado(segundos_restantes: float, progresso: float)

## Disparado sempre que o número de ações restantes muda.
## restantes = ACOES_ILIMITADAS (-1) quando o bloco é ilimitado.
signal acoes_atualizadas(restantes: int)

## Disparado quando um bloco termina (acabou o tempo dele)
signal bloco_terminado(indice: int, nome_horario_fim: String)

## Disparado quando o último bloco termina — é o "fim do dia
## letivo". Quem estiver ouvindo isso normalmente vai chamar
## EstadoJogador.verificar_final() e mostrar a tela de resultado.
signal dia_terminado()


# ---------------------------------------------------------------
# CONFIGURAÇÃO DOS BLOCOS
# ---------------------------------------------------------------
# Horários reais do COLTEC (07:30 até 17:10). Como o relógio
# aparece pro jogador na HUD, cada bloco dura, em tempo REAL, uma
# fração proporcional ao tanto de "tempo de aula" que ele
# representa — assim um recreio de 20 min passa rápido e uma aula
# de 100 min demora mais, mas o dia inteiro sempre cabe em
# TOTAL_SEGUNDOS (10 minutos de jogo, como definido no brainstorm).

## Duração total do dia letivo em tempo real (10 minutos)
const TOTAL_SEGUNDOS := 600.0

## Usado no lugar de um número quando o bloco não tem limite de
## ações (ex: bloco do almoço, "o máximo que você conseguir")
const ACOES_ILIMITADAS := -1

## Cada entrada: [hora_inicio, hora_fim, limite_de_ações, duracao_segundos, tipo]
## tipo é usado pelo GerenciadorDeEventos pra saber onde pode
## sortear aula/prova ("aula") e onde não pode ("recreio", "almoco").
## A duração de cada bloco já vem pré-calculada (proporcional ao
## tamanho real do período) — se mudarem os horários, é só rodar
## de novo a conta: duracao = (minutos_do_bloco / minutos_do_dia) * TOTAL_SEGUNDOS
const BLOCOS := [
	["07:30", "09:10", 2, 103.4, "aula"],
	["09:10", "09:30", 1, 20.7, "recreio"],
	["09:30", "11:10", 2, 103.4, "aula"],
	["11:10", "13:30", ACOES_ILIMITADAS, 144.8, "almoco"],
	["13:30", "15:10", 2, 103.4, "aula"],
	["15:10", "15:30", 1, 20.7, "recreio"],
	["15:30", "17:10", 2, 103.4, "aula"],
]


# ---------------------------------------------------------------
# ESTADO INTERNO
# ---------------------------------------------------------------
var indice_bloco: int = -1
var tempo_restante: float = 0.0
var acoes_restantes: int = 0
var rodando: bool = false


func _process(delta: float) -> void:
	if not rodando:
		return

	tempo_restante -= delta
	var duracao_total: float = BLOCOS[indice_bloco][3]
	var progresso := clampf(1.0 - (tempo_restante / duracao_total), 0.0, 1.0)
	tempo_atualizado.emit(maxf(tempo_restante, 0.0), progresso)

	if tempo_restante <= 0.0:
		_terminar_bloco_atual()


# ---------------------------------------------------------------
# CONTROLE DO DIA
# ---------------------------------------------------------------

## Começa o dia letivo do zero, no primeiro bloco (07:30).
## Chame isso quando a cena do mundo/jogo carregar.
func iniciar_dia() -> void:
	indice_bloco = -1
	rodando = false
	_avancar_bloco()
	rodando = true


## Pausa o cronômetro (ex: durante um menu ou diálogo). O tempo
## só volta a passar depois de retomar_dia().
func pausar_dia() -> void:
	rodando = false


func retomar_dia() -> void:
	if indice_bloco >= 0 and indice_bloco < BLOCOS.size():
		rodando = true


func _avancar_bloco() -> void:
	indice_bloco += 1

	if indice_bloco >= BLOCOS.size():
		rodando = false
		dia_terminado.emit()
		return

	var bloco: Array = BLOCOS[indice_bloco]
	tempo_restante = bloco[3]
	acoes_restantes = bloco[2]

	bloco_iniciado.emit(indice_bloco, bloco[0], acoes_restantes)
	acoes_atualizadas.emit(acoes_restantes)


func _terminar_bloco_atual() -> void:
	var bloco: Array = BLOCOS[indice_bloco]
	bloco_terminado.emit(indice_bloco, bloco[1])
	_avancar_bloco()


# ---------------------------------------------------------------
# CONSUMO DE AÇÕES
# ---------------------------------------------------------------

## Verifica se o jogador ainda pode iniciar uma ação neste bloco.
## Chame ANTES de começar qualquer mecânica (timer de presença,
## abrir menu de estudo, etc).
func pode_agir() -> bool:
	if not rodando:
		return false
	return acoes_restantes == ACOES_ILIMITADAS or acoes_restantes > 0


## "Gasta" uma ficha de ação do bloco atual. Chame isso quando uma
## ação for CONCLUÍDA (a aula acabou, o player parou de estudar,
## terminou de comer, acordou, saiu da prova) — não quando ela
## começa. Retorna false se, por algum motivo, não havia mais
## ações disponíveis (ex: chamado fora de hora).
func consumir_acao() -> bool:
	if not pode_agir():
		return false

	if acoes_restantes != ACOES_ILIMITADAS:
		acoes_restantes -= 1
		acoes_atualizadas.emit(acoes_restantes)

	return true


## Retorna o tipo do bloco atual: "aula", "recreio" ou "almoco".
## Retorna "" se o dia não estiver rodando.
func tipo_bloco_atual() -> String:
	if indice_bloco < 0 or indice_bloco >= BLOCOS.size():
		return ""
	return BLOCOS[indice_bloco][4]


# ---------------------------------------------------------------
# RELÓGIO PRA UI (HUD vai usar isso)
# ---------------------------------------------------------------

## Retorna o horário atual formatado (ex: "08:14"), interpolado
## suavemente entre o início e o fim do bloco conforme o tempo
## real passa. Pensado pra alimentar o relógio da HUD.
func horario_formatado() -> String:
	if indice_bloco < 0 or indice_bloco >= BLOCOS.size():
		return "--:--"

	var bloco: Array = BLOCOS[indice_bloco]
	var duracao_total: float = bloco[3]
	var progresso := clampf(1.0 - (tempo_restante / duracao_total), 0.0, 1.0)
	return _interpolar_horario(bloco[0], bloco[1], progresso)


func _interpolar_horario(inicio: String, fim: String, t: float) -> String:
	var minutos_inicio := _horario_para_minutos(inicio)
	var minutos_fim := _horario_para_minutos(fim)
	var minutos_atual := roundi(lerp(float(minutos_inicio), float(minutos_fim), t))
	return _minutos_para_horario(minutos_atual)


func _horario_para_minutos(horario: String) -> int:
	var partes := horario.split(":")
	return int(partes[0]) * 60 + int(partes[1])


func _minutos_para_horario(minutos: int) -> String:
	var h := int(minutos / 60)
	var m := minutos % 60
	return "%02d:%02d" % [h, m]
