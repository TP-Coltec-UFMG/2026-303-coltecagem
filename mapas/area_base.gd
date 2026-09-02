extends Node2D
## Script base pra cada mapa/área (Portaria, Hall, SalaDeAula...).
## No _ready(), procura o Marker2D cujo nome bate com
## Global.proximo_ponto_entrada e move o personagem pra lá.
## Se não houver ponto definido (ex: primeira cena do jogo),
## o personagem fica onde já estiver posicionado na cena.
@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	_posicionar_personagem()
	# A HUD é Autoload: qualquer mapa de gameplay que carregar
	# mostra ela e (se ainda não estiver rodando) liga o relógio
	# do dia letivo. Ver HUD/hud.gd -> mostrar_e_iniciar_dia().
	HUD.mostrar_e_iniciar_dia()
	
func _process(_delta: float) -> void:
	var personagem = get_tree().get_first_node_in_group("jogador")
	if personagem:
		camera.global_position = personagem.global_position

func _posicionar_personagem() -> void:
	
	var nome_ponto := Global.proximo_ponto_entrada
	if nome_ponto == "":
		return

	var personagem := get_tree().get_first_node_in_group("jogador")
	if personagem == null:
		return

	var marker := find_child(nome_ponto, true, false)
	if marker == null or not (marker is Marker2D):
		push_warning("Ponto de entrada '%s' não encontrado em %s" % [nome_ponto, name])
		return

	personagem.global_position = marker.global_position
