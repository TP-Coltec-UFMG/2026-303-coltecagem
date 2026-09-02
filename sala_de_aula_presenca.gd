extends Area2D

@export var nome_sala: String = "Sala 1"

## NOVO: Sinal avisando que o jogador pisou na sala pela primeira vez
signal jogador_entrou_pela_primeira_vez

var _ja_entrou: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("jogador"):
		return
	GerenciadorDeEventos.jogador_presente_manual = true

	if not _ja_entrou:
		_ja_entrou = true
		jogador_entrou_pela_primeira_vez.emit()


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("jogador"):
		return
	GerenciadorDeEventos.jogador_presente_manual = false
