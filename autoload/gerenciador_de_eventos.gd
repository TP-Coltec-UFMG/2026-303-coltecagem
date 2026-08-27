extends Node
## ============================================================
## GerenciadorDeEventos
## ------------------------------------------------------------
## Sorteia e dispara as "aulas" e "provas" aleatórias descritas no
## brainstorm, sempre em 3 fases:
##   1. ANÚNCIO — "aula de X começando na sala Y em Z segundos"
##   2. EXECUÇÃO — a aula/prova acontece por uma duração
##   3. FIM — encerra e (no caso da prova) calcula o resultado
##
## Este script NÃO sabe decidir sozinho se o jogador está "dentro"
## ou "fora" da sala — isso depende do mapa (Area2D), que ainda
## não existe (issue "Mapas/Tilemaps"). Por isso ele expõe
## `jogador_presente_na_sala(sala)`, que por enquanto é respondida
## manualmente (ver `jogador_presente_manual` mais abaixo) e depois
## deve ser trocada pela consulta real de posição do personagem.
##
## Quem for aplicar os efeitos em EstadoJogador (aula()/matar_aula())
## deve ouvir os sinais aula_iniciada/aula_finalizada e, durante
## esse intervalo, chamar aula() ou matar_aula() com base em onde o
## jogador está. Isso fica pra quando tivermos a Area2D de sala.
## ============================================================

signal aula_anunciada(nome_sala: String, tempo_aviso: float)
signal aula_iniciada(nome_sala: String, duracao: float)
## fracao_dentro: de 0.0 (ficou fora o tempo todo) a 1.0 (ficou
## dentro o tempo todo) — útil pra UI mostrar feedback ("você
## rendeu 70% dessa aula").
signal aula_finalizada(nome_sala: String, fracao_dentro: float)

signal prova_anunciada(nome_sala: String, tempo_aviso: float)
signal prova_iniciada(nome_sala: String, duracao: float)
signal prova_finalizada(nome_sala: String, nota: int)


# ---------------------------------------------------------------
# CONFIGURAÇÃO
# ---------------------------------------------------------------

## Nomes das salas onde aulas/provas podem acontecer. PLACEHOLDER
## até a issue de Mapas definir as salas de verdade — troquem essa
## lista pelos nomes reais das Area2D quando existirem.
var salas_de_aula: Array[String] = ["Sala 1", "Sala 2", "Sala 3"]

## Intervalo de espera aleatória entre o fim de uma aula e o
## anúncio da próxima
const ESPERA_ENTRE_AULAS_MIN := 2.0
const ESPERA_ENTRE_AULAS_MAX := 6.0

## Tempo de aviso antes da aula começar de fato (canvas/brainstorm
## não dá um número exato — chute inicial)
const TEMPO_AVISO_MIN := 5.0
const TEMPO_AVISO_MAX := 10.0

## Duração da aula em si (brainstorm: "pode durar de 30 a 50 segundos")
const DURACAO_AULA_MIN := 30.0
const DURACAO_AULA_MAX := 50.0

## De quanto em quanto tempo checamos se o jogador está dentro ou
## fora da sala, durante uma aula em andamento — é essa amostragem
## que vira a fração de tempo usada em aula()/matar_aula().
## Menor = mais preciso, mas mais chamadas de sinal/possível custo.
const INTERVALO_AMOSTRAGEM_PRESENCA := 0.5

## Prova: aviso mais curto (é surpresa) e uma janela pequena pro
## jogador chegar até a sala
const TEMPO_AVISO_PROVA := 5.0
const DURACAO_JANELA_PROVA := 8.0


# ---------------------------------------------------------------
# ESTADO INTERNO
# ---------------------------------------------------------------

## Nome da sala com aula rolando agora (vazio = nenhuma aula ativa)
var sala_com_aula_ativa: String = ""

## Nome da sala com prova rolando agora
var sala_com_prova_ativa: String = ""

## Em qual bloco (índice de GerenciadorDeTempo.BLOCOS) vai cair a
## única prova do dia. Sorteado quando o dia começa.
var bloco_da_prova: int = -1

## PLACEHOLDER — enquanto não existe detecção real de posição do
## personagem (Area2D de sala), qualquer script pode setar isso
## manualmente (ex: a cena de teste) pra simular "o jogador está
## na sala X agora".
var jogador_presente_manual: bool = false


func _ready() -> void:
	GerenciadorDeTempo.bloco_iniciado.connect(_on_bloco_iniciado)
	GerenciadorDeTempo.dia_terminado.connect(_on_dia_terminado)


func _on_bloco_iniciado(indice: int, _nome_horario: String, _limite_acoes: int) -> void:
	# No primeiro bloco do dia, sorteia em qual bloco de aula vai
	# cair a prova (só uma por dia, pra não virar avalanche).
	if indice == 0:
		var blocos_de_aula := _indices_dos_blocos_de_aula()
		if not blocos_de_aula.is_empty():
			bloco_da_prova = blocos_de_aula[randi() % blocos_de_aula.size()]

	if GerenciadorDeTempo.tipo_bloco_atual() != "aula":
		return # não sorteia aula/prova em recreio ou almoço

	_agendar_proxima_aula()

	if indice == bloco_da_prova:
		_agendar_prova()


func _indices_dos_blocos_de_aula() -> Array:
	var indices := []
	for i in GerenciadorDeTempo.BLOCOS.size():
		if GerenciadorDeTempo.BLOCOS[i][4] == "aula":
			indices.append(i)
	return indices


func _on_dia_terminado() -> void:
	sala_com_aula_ativa = ""
	sala_com_prova_ativa = ""


# ---------------------------------------------------------------
# FLUXO DA AULA (anúncio → execução → fim → encadeia a próxima)
# ---------------------------------------------------------------

func _agendar_proxima_aula() -> void:
	var espera := randf_range(ESPERA_ENTRE_AULAS_MIN, ESPERA_ENTRE_AULAS_MAX)
	await get_tree().create_timer(espera).timeout

	# se o bloco já mudou (ex: virou recreio) enquanto esperávamos,
	# não dispara a aula
	if GerenciadorDeTempo.tipo_bloco_atual() != "aula":
		return

	await _disparar_aula()

	# encadeia a próxima aula, se ainda estivermos num bloco de aula
	if GerenciadorDeTempo.tipo_bloco_atual() == "aula":
		_agendar_proxima_aula()


func _disparar_aula() -> void:
	var sala: String = salas_de_aula[randi() % salas_de_aula.size()]
	var tempo_aviso := randf_range(TEMPO_AVISO_MIN, TEMPO_AVISO_MAX)

	aula_anunciada.emit(sala, tempo_aviso)
	await get_tree().create_timer(tempo_aviso).timeout

	if GerenciadorDeTempo.tipo_bloco_atual() != "aula":
		return # o bloco acabou durante o aviso; cancela a aula

	var duracao := randf_range(DURACAO_AULA_MIN, DURACAO_AULA_MAX)
	sala_com_aula_ativa = sala
	aula_iniciada.emit(sala, duracao)

	# Amostra a presença do jogador várias vezes ao longo da aula
	# em vez de só checar no instante final — é isso que faz o
	# efeito ser proporcional ao tempo dentro/fora, como pedido no
	# brainstorm ("o contador vai sendo convertido no efeito
	# conforme o tempo passa").
	var tempo_decorrido := 0.0
	var tempo_dentro := 0.0
	while tempo_decorrido < duracao:
		var intervalo: float = minf(INTERVALO_AMOSTRAGEM_PRESENCA, duracao - tempo_decorrido)
		await get_tree().create_timer(intervalo).timeout
		tempo_decorrido += intervalo
		if jogador_presente_na_sala(sala):
			tempo_dentro += intervalo

	var fracao_dentro := tempo_dentro / duracao
	var fracao_fora := 1.0 - fracao_dentro

	# Aplica os dois efeitos proporcionalmente. Se o jogador ficou
	# 70% do tempo dentro e 30% fora, ele recebe 70% do efeito de
	# aula() E 30% do efeito de matar_aula() — não é um "ou outro".
	if fracao_dentro > 0.0:
		EstadoJogador.aula(fracao_dentro)
	if fracao_fora > 0.0:
		EstadoJogador.matar_aula(fracao_fora)
	# Nota: se o jogador dividiu o tempo entre dentro/fora, ambos os
	# métodos rodam e cada um incrementa EstadoJogador.dias_passados
	# — esse contador pode ficar "adiantado". Não afeta nada hoje
	# (não é usado em verificar_final), mas ajustem se for usar pra
	# alguma coisa importante depois.

	GerenciadorDeTempo.consumir_acao()

	sala_com_aula_ativa = ""
	aula_finalizada.emit(sala, fracao_dentro)


# ---------------------------------------------------------------
# FLUXO DA PROVA (anúncio → janela pra chegar → resultado)
# ---------------------------------------------------------------

func _agendar_prova() -> void:
	var sala: String = salas_de_aula[randi() % salas_de_aula.size()]

	prova_anunciada.emit(sala, TEMPO_AVISO_PROVA)
	await get_tree().create_timer(TEMPO_AVISO_PROVA).timeout

	sala_com_prova_ativa = sala
	prova_iniciada.emit(sala, DURACAO_JANELA_PROVA)

	await get_tree().create_timer(DURACAO_JANELA_PROVA).timeout

	# Regra do brainstorm: se o jogador não chegou a tempo, nota 0.
	# Se chegou, calcula a nota de verdade.
	var nota := 0
	if jogador_presente_na_sala(sala):
		nota = EstadoJogador.fazer_prova()

	GerenciadorDeTempo.consumir_acao()

	sala_com_prova_ativa = ""
	prova_finalizada.emit(sala, nota)


## Verifica se o jogador está na sala indicada. PLACEHOLDER: hoje
## só olha a flag manual (ver comentário dela lá em cima). Troquem
## por uma consulta real de posição/Area2D quando o mapa existir.
func jogador_presente_na_sala(_sala: String) -> bool:
	return jogador_presente_manual
