extends Node2D
## Script base pra cada mapa/área (Portaria, Hall, SalaDeAula...).
## No _ready(), decide onde o personagem deve aparecer, em ordem
## de prioridade:
##   1. Voltando de um minigame? Vai pro pixel exato de onde saiu
##      (Global.posicao_retorno_minigame) — ver
##      GerenciadorDeMinigames.iniciar_minigame().
##   2. Veio por uma porta? Procura o Marker2D cujo nome bate com
##      Global.proximo_ponto_entrada e move o personagem pra lá.
##   3. Nenhum dos dois (ex: primeira cena do jogo)? O personagem
##      fica onde já estiver posicionado na cena.
@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	_posicionar_personagem()
	# A HUD é Autoload: qualquer mapa de gameplay que carregar
	# mostra ela e (se ainda não estiver rodando) liga o relógio
	# do dia letivo. Ver HUD/hud.gd -> mostrar_e_iniciar_dia().
	HUD.mostrar_e_iniciar_dia()
	# MenuDeAcoes também é Autoload, pelo mesmo motivo: precisa
	# aparecer em qualquer mapa de gameplay sem precisar ser colado
	# manualmente em cada cena nova.
	MenuDeAcoes.mostrar()

func _process(_delta: float) -> void:
	var personagem = get_tree().get_first_node_in_group("jogador")
	if personagem:
		camera.global_position = personagem.global_position

func _posicionar_personagem() -> void:
	var personagem := get_tree().get_first_node_in_group("jogador")
	if personagem == null:
		return

	# Prioridade 1: voltando de um minigame. Ignora qualquer
	# Marker2D de porta e vai direto pro pixel exato de onde o
	# personagem estava antes do minigame abrir.
	if Global.retornando_de_minigame:
		personagem.global_position = Global.posicao_retorno_minigame
		Global.retornando_de_minigame = false
		return

	# Prioridade 2: veio por uma porta.
	var nome_ponto := Global.proximo_ponto_entrada
	if nome_ponto == "":
		return

	var marker := find_child(nome_ponto, true, false)
	if marker == null or not (marker is Marker2D):
		push_warning("Ponto de entrada '%s' não encontrado em %s" % [nome_ponto, name])
		return

	personagem.global_position = marker.global_position
