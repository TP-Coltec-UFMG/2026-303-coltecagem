extends Node
## ============================================================
## GerenciadorDeEventos
## ------------------------------------------------------------
## Sorteia e dispara as "aulas" e "provas" durante os blocos de
## horário, sempre em 3 fases:
##   1. ANÚNCIO — "aula começando em Z segundos"
##   2. EXECUÇÃO — a aula/prova acontece por uma duração
##   3. FIM — encerra e (no caso da prova) calcula o resultado
##
## A presença do jogador na sala é decidida por
## jogador_presente_na_sala(), que checa Global.mapa_atual (setado
## por mapas/sala_de_aula.gd) — ou seja, ela reflete onde o
## personagem está DE VERDADE no mapa, e continua valendo mesmo se
## um minigame abrir uma cena por cima (minigames não mexem em
## Global.mapa_atual).
##
## Quem for aplicar os efeitos em EstadoJogador (aula()/matar_aula())
## deve ouvir os sinais aula_iniciada/aula_finalizada e, durante
## esse intervalo, chamar aula() ou matar_aula() com base em onde o
## jogador está.
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
## compareceu = false: o jogador não estava na sala (nota 0)
signal prova_resultado(compareceu: bool, nota: int)


# ---------------------------------------------------------------
# CONFIGURAÇÃO
# ---------------------------------------------------------------

## Nome exibido nos avisos/banners. Hoje só existe uma sala de
## aula de verdade no mapa (mapas/SalaDeAula.tscn) — se um dia
## vocês tiverem mais de uma, isso volta a ser uma lista sorteada.
const NOME_SALA_DE_AULA := "Sala de Aula"

## Identificador que Global.mapa_atual precisa ter pra contar como
## "dentro da sala de aula" (ver mapas/sala_de_aula.gd).
const ID_MAPA_SALA_DE_AULA := "SalaDeAula"

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

## Pausa entre o fim da aula e o aviso da prova, no bloco da prova
const ESPERA_ANTES_DA_PROVA_MIN := 3.0
const ESPERA_ANTES_DA_PROVA_MAX := 8.0

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

## Usado só pela cena de debug (debug/teste_eventos.tscn) pra
## simular presença sem precisar do mapa de verdade. No jogo real,
## jogador_presente_na_sala() ignora isso e olha Global.mapa_atual.
## SERVE SÓ PRA DEBUG
var jogador_presente_manual: bool = false


func _ready() -> void:
	GerenciadorDeTempo.bloco_iniciado.connect(_on_bloco_iniciado)
	GerenciadorDeTempo.dia_terminado.connect(_on_dia_terminado)
	#Engine.time_scale = 15.0
	#use a função acima se precisar acelerar o tempo
func _on_bloco_iniciado(indice: int, _nome_horario: String, _limite_acoes: int) -> void:
	# No primeiro bloco do dia, sorteia em qual bloco de aula vai
	# cair a prova (só uma por dia, pra não virar avalanche).
	if indice == 0:
		var blocos_de_aula := _indices_dos_blocos_de_aula()
		if not blocos_de_aula.is_empty():
			bloco_da_prova = blocos_de_aula[randi() % blocos_de_aula.size()]

	if GerenciadorDeTempo.tipo_bloco_atual() != "aula":
		return # não sorteia aula/prova em recreio ou almoço

	_rodar_bloco_de_aula(indice)

func _indices_dos_blocos_de_aula() -> Array:
	var indices := []
	for i in GerenciadorDeTempo.BLOCOS.size():
		if GerenciadorDeTempo.BLOCOS[i][4] == "aula":
			indices.append(i)
	return indices


func _on_dia_terminado() -> void:
	sala_com_aula_ativa = ""
	sala_com_prova_ativa = ""

## Espera `segundos` de TEMPO DO JOGO: só conta quando o relógio do
## dia está rodando (não conta durante diálogo nem minigame).
func _esperar(segundos: float) -> void:
	var acumulado := 0.0
	while acumulado < segundos:
		await get_tree().process_frame
		if GerenciadorDeTempo.rodando:
			acumulado += get_process_delta_time()
			
# ---------------------------------------------------------------
# FLUXO DA AULA (anúncio → execução → fim → encadeia a próxima)
# ---------------------------------------------------------------

func _rodar_bloco_de_aula(indice: int) -> void:
	var espera := randf_range(ESPERA_ENTRE_AULAS_MIN, ESPERA_ENTRE_AULAS_MAX)
	await _esperar(espera)
	if GerenciadorDeTempo.indice_bloco != indice:
		return

	await _disparar_aula(indice)

	if indice == bloco_da_prova and GerenciadorDeTempo.indice_bloco == indice:
		var pausa := randf_range(ESPERA_ANTES_DA_PROVA_MIN, ESPERA_ANTES_DA_PROVA_MAX)
		await _esperar(pausa)
		if GerenciadorDeTempo.indice_bloco == indice:
			await _agendar_prova()


func _disparar_aula(indice: int) -> void:
	print("AULA no bloco ", indice)
	var sala: String = NOME_SALA_DE_AULA
	var tempo_aviso := randf_range(TEMPO_AVISO_MIN, TEMPO_AVISO_MAX)

	aula_anunciada.emit(sala, tempo_aviso)
	await _esperar(tempo_aviso)

	if GerenciadorDeTempo.indice_bloco != indice:
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
		await _esperar(intervalo)
		tempo_decorrido += intervalo
		if jogador_presente_na_sala(sala):
			tempo_dentro += intervalo

	var fracao_dentro := tempo_dentro / duracao
	var fracao_fora := 1.0 - fracao_dentro

	# Aplica os dois efeitos proporcionalmente. Se o jogador ficou
	# 70% do tempo dentro e 30% fora, ele recebe 70% do efeito de
	# aula() E 30% do efeito de matar_aula() — não é um "ou outro".
	print("Presença nesta aula: ", snappedf(fracao_dentro, 0.01))
	if fracao_dentro > 0.0:
		EstadoJogador.aula(fracao_dentro)
	if fracao_fora > 0.0:
		EstadoJogador.matar_aula(fracao_fora)
	# Nota: se o jogador dividiu o tempo entre dentro/fora, ambos os
	# métodos rodam e cada um incrementa EstadoJogador.dias_passados
	# — esse contador pode ficar "adiantado". Não afeta nada hoje
	# (não é usado em verificar_final), mas ajustem se for usar pra
	# alguma coisa importante depois.

	sala_com_aula_ativa = ""
	aula_finalizada.emit(sala, fracao_dentro)


# ---------------------------------------------------------------
# FLUXO DA PROVA (anúncio → janela pra chegar → resultado)
# ---------------------------------------------------------------

func _agendar_prova() -> void:
	var sala: String = NOME_SALA_DE_AULA

	prova_anunciada.emit(sala, TEMPO_AVISO_PROVA)
	await _esperar(TEMPO_AVISO_PROVA)

	sala_com_prova_ativa = sala
	prova_iniciada.emit(sala, DURACAO_JANELA_PROVA)

	await _esperar(DURACAO_JANELA_PROVA)

	# Regra do brainstorm: se o jogador não chegou a tempo, nota 0.
	# Se chegou, calcula a nota de verdade.
	var compareceu := jogador_presente_na_sala(sala)
	var nota := 0
	if compareceu:
		nota = EstadoJogador.fazer_prova()

	sala_com_prova_ativa = ""
	prova_resultado.emit(compareceu, nota)
	prova_finalizada.emit(sala, nota)

## Verifica se o jogador está na sala de aula de verdade. Usa
## Global.mapa_atual (a fonte real, setada por sala_de_aula.gd) OU
## a flag manual de debug — o "ou" existe só pra não quebrar a
## cena de teste antiga.
func jogador_presente_na_sala(_sala: String) -> bool:
	return jogador_presente_manual or Global.mapa_atual == ID_MAPA_SALA_DE_AULA
