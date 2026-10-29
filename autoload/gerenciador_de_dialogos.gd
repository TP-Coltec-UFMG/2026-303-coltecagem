extends Node

var dialogo_manager_ativo: bool = false
var _retomar_tempo_ao_fechar: bool = false


func _ready() -> void:
	DialogueManager.dialogue_ended.connect(_on_dialogue_manager_ended)


func iniciar_dialogo_manager() -> bool:
	if dialogo_manager_ativo:
		return false

	dialogo_manager_ativo = true
	_retomar_tempo_ao_fechar = GerenciadorDeTempo.rodando

	if _retomar_tempo_ao_fechar and not GerenciadorDeMinigames.esta_ocupado():
		GerenciadorDeTempo.retomar_dia()

	return true


func _on_dialogue_manager_ended(_resource: DialogueResource) -> void:
	dialogo_manager_ativo = false

	if _retomar_tempo_ao_fechar:
		GerenciadorDeTempo.retomar_dia()

	_retomar_tempo_ao_fechar = false
## Encerra o estado de diálogo à força. Usado quando a cena troca no
## meio da conversa (ex: um minigame começa) e o balão é apagado sem
## o Dialogue Manager emitir "dialogue_ended".
func forcar_fim() -> void:
	dialogo_manager_ativo = false
	_retomar_tempo_ao_fechar = false
