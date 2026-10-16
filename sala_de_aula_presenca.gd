extends Area2D

@export var nome_sala: String = "Sala 1"

## Sinal avisando que o jogador pisou na sala pela primeira vez
signal jogador_entrou_pela_primeira_vez

var _ja_entrou: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("jogador"):
		return

	if not _ja_entrou:
		_ja_entrou = true
		jogador_entrou_pela_primeira_vez.emit()
