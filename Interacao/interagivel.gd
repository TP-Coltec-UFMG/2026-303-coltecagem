extends Area2D

signal jogador_entrou_na_area(jogador: Node2D)
signal jogador_saiu_da_area(jogador: Node2D)
signal interagido

@export var dialogo: DialogueResource
@export var ponto_inicial: String = "inicio"

var _jogador_por_perto: bool = false
var _label_dica: Label


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if has_node("LabelDica"):
		_label_dica = $LabelDica
		_label_dica.visible = false

# Esconde a dica durante os diálogos
func _process(_delta: float) -> void:
	if _label_dica:
		_label_dica.visible = _jogador_por_perto and not GerenciadorDeDialogos.dialogo_manager_ativo


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("jogador"):
		return
	_jogador_por_perto = true
	jogador_entrou_na_area.emit(body)


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("jogador"):
		return
	_jogador_por_perto = false
	jogador_saiu_da_area.emit(body)


func _unhandled_input(event: InputEvent) -> void:
	if not _jogador_por_perto:
		return

	if not event.is_action_pressed("interagir"):
		return

	if dialogo == null:
		return

	if not GerenciadorDeDialogos.iniciar_dialogo_manager():
		return

	interagido.emit()
	DialogueManager.show_dialogue_balloon(dialogo, ponto_inicial)
	get_viewport().set_input_as_handled()
	
