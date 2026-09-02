extends Node

var dialogo_manager_ativo: bool = false
var _retomar_tempo_ao_fechar: bool = false


func _ready() -> void:
	DialogueManager.dialogue_ended.connect(_on_dialogue_manager_ended)


func iniciar_dialogo_manager() -> bool:
	if dialogo_manager_ativo:
		return false

	if DialogoBox.esta_ativo():
		return false

	dialogo_manager_ativo = true
	_retomar_tempo_ao_fechar = GerenciadorDeTempo.rodando

	if _retomar_tempo_ao_fechar:
		GerenciadorDeTempo.pausar_dia()

	return true


func _on_dialogue_manager_ended(_resource: DialogueResource) -> void:
	dialogo_manager_ativo = false

	if _retomar_tempo_ao_fechar:
		GerenciadorDeTempo.retomar_dia()

	_retomar_tempo_ao_fechar = false
