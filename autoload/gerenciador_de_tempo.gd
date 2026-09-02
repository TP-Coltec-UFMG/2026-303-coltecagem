extends Node

signal bloco_iniciado(
	indice: int,
	nome_horario: String,
	limite_acoes: int
)

signal tempo_atualizado(
	segundos_restantes: float,
	progresso: float
)

signal acoes_atualizadas(restantes: int)
signal bloco_terminado(indice: int, nome_horario_fim: String)
signal dia_terminado()

const TOTAL_SEGUNDOS := 600.0
const ACOES_ILIMITADAS := -1

# Início, fim, ações, duração em segundos, tipo e nome.
const BLOCOS := [
	["07:30", "09:10", 4, 103.4, "aula", "Primeiro horário"],
	["09:10", "09:30", 2, 20.7, "recreio", "Primeiro recreio"],
	["09:30", "11:10", 4, 103.4, "aula", "Segundo horário"],
	[
		"11:10",
		"13:30",
		ACOES_ILIMITADAS,
		144.8,
		"almoco",
		"Intervalo para almoço"
	],
	["13:30", "15:10", 4, 103.4, "aula", "Terceiro horário"],
	["15:10", "15:30", 2, 20.7, "recreio", "Segundo recreio"],
	["15:30", "17:10", 4, 103.4, "aula", "Quarto horário"],
]

var indice_bloco: int = -1
var tempo_restante: float = 0.0
var acoes_restantes: int = 0
var rodando: bool = false


func _process(delta: float) -> void:
	if not rodando:
		return

	if not _bloco_valido():
		return

	tempo_restante -= delta

	var duracao_total: float = BLOCOS[indice_bloco][3]
	var progresso := clampf(
		1.0 - (tempo_restante / duracao_total),
		0.0,
		1.0
	)

	tempo_atualizado.emit(
		maxf(tempo_restante, 0.0),
		progresso
	)

	if tempo_restante <= 0.0:
		_terminar_bloco_atual()


func iniciar_dia() -> void:
	indice_bloco = -1
	rodando = false
	_avancar_bloco()
	rodando = true


func pausar_dia() -> void:
	rodando = false


func retomar_dia() -> void:
	if _bloco_valido():
		rodando = true


func _bloco_valido() -> bool:
	return indice_bloco >= 0 and indice_bloco < BLOCOS.size()


func _avancar_bloco() -> void:
	indice_bloco += 1

	if not _bloco_valido():
		rodando = false
		dia_terminado.emit()
		return

	var bloco: Array = BLOCOS[indice_bloco]

	tempo_restante = bloco[3]
	acoes_restantes = bloco[2]

	bloco_iniciado.emit(
		indice_bloco,
		bloco[0],
		acoes_restantes
	)

	acoes_atualizadas.emit(acoes_restantes)


func _terminar_bloco_atual() -> void:
	if not _bloco_valido():
		return

	var bloco: Array = BLOCOS[indice_bloco]

	bloco_terminado.emit(indice_bloco, bloco[1])
	_avancar_bloco()


func pode_agir() -> bool:
	if not rodando or not _bloco_valido():
		return false

	return (
		acoes_restantes == ACOES_ILIMITADAS
		or acoes_restantes > 0
	)


func consumir_acao() -> bool:
	# Uma escolha de diálogo pode consumir ação
	# mesmo quando o relógio está pausado.
	if not _bloco_valido():
		return false

	if acoes_restantes != ACOES_ILIMITADAS and acoes_restantes <= 0:
		return false

	if acoes_restantes != ACOES_ILIMITADAS:
		acoes_restantes -= 1
		acoes_atualizadas.emit(acoes_restantes)

	return true


func tipo_bloco_atual() -> String:
	if not _bloco_valido():
		return ""

	return BLOCOS[indice_bloco][4]


func nome_bloco_atual() -> String:
	if not _bloco_valido():
		return ""

	return BLOCOS[indice_bloco][5]


func horario_formatado() -> String:
	if not _bloco_valido():
		return "--:--"

	var bloco: Array = BLOCOS[indice_bloco]
	var duracao_total: float = bloco[3]

	var progresso := clampf(
		1.0 - (tempo_restante / duracao_total),
		0.0,
		1.0
	)

	return _interpolar_horario(
		bloco[0],
		bloco[1],
		progresso
	)


func _interpolar_horario(inicio: String, fim: String, t: float) -> String:
	var minutos_inicio := _horario_para_minutos(inicio)
	var minutos_fim := _horario_para_minutos(fim)

	var minutos_atual := roundi(
		lerp(float(minutos_inicio), float(minutos_fim), t)
	)

	return _minutos_para_horario(minutos_atual)


func _horario_para_minutos(horario: String) -> int:
	var partes := horario.split(":")
	return int(partes[0]) * 60 + int(partes[1])


func _minutos_para_horario(minutos: int) -> String:
	var horas := int(minutos / 60.0)
	var minutos_restantes := minutos % 60

	return "%02d:%02d" % [horas, minutos_restantes]
