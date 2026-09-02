extends "res://mapas/area_base.gd"
## ============================================================
## SalaDeAula
## ------------------------------------------------------------
## Dispara a cutscene do professor na primeira vez que o jogador
## entra na área de presença da sala.
## ============================================================

@export var falas_professor_sentem: Array[String] = [
	"Bom dia, turma! Já pra dentro, vamos começar a aula.",
	"Cada um na sua carteira, por favor.",
]

var _cutscene_ja_aconteceu: bool = false


func _ready() -> void:
	super._ready()
	
	# Procura automaticamente qualquer nó de presença na sala para ouvir o sinal
	var area_presenca = find_child("*Presenca*", true, false)
	if area_presenca and area_presenca.has_signal("body_entered"):
		area_presenca.body_entered.connect(_on_jogador_entrou_na_sala)


func _on_jogador_entrou_na_sala(body: Node2D) -> void:
	if not body.is_in_group("jogador"):
		return
	if _cutscene_ja_aconteceu:
		return

	_cutscene_ja_aconteceu = true

	if not falas_professor_sentem.is_empty():
		DialogoBox.mostrar_dialogo("Professor", falas_professor_sentem)
