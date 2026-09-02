extends Area2D
## ============================================================
## MinigameTaskArea
## ------------------------------------------------------------
## Componente reutilizável: anexe numa Area2D (com um
## CollisionShape2D) em qualquer objeto/NPC do mapa que deva
## disparar um minigame ("task"). Igual ao Interagivel, mas em vez
## de abrir um diálogo, abre um minigame e converte o resultado em
## pontos de atributo.
##
## Como usar (sem programar nada):
##   1. Area2D (com este script) + CollisionShape2D, dentro da
##      cena do objeto/NPC da task
##   2. No Inspetor: preenche "Cena Do Minigame" (arraste o .tscn
##      do minigame, ex: res://minigames/pants/pants_minigame.tscn)
##   3. Preenche "Recompensas" com os atributos e quantidades
##      (ex: chave "desempenho_academico", valor 8)
##   4. (opcional) um Label "LabelDica" como filho, pro "aperte E"
## ============================================================

@export var cena_do_minigame: PackedScene
@export var recompensas: Dictionary = {}

var _jogador_por_perto: bool = false
var _label_dica: Label


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if has_node("LabelDica"):
		_label_dica = $LabelDica
		_label_dica.visible = false


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("jogador"):
		return
	_jogador_por_perto = true
	if _label_dica:
		_label_dica.visible = true


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("jogador"):
		return
	_jogador_por_perto = false
	if _label_dica:
		_label_dica.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not _jogador_por_perto or cena_do_minigame == null:
		return
	if event.is_action_pressed("interagir"):
		get_viewport().set_input_as_handled()
		GerenciadorDeMinigames.iniciar_minigame(cena_do_minigame.resource_path, recompensas)
