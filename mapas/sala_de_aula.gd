extends "res://mapas/area_base.gd"
## ============================================================
## SalaDeAula
## ------------------------------------------------------------
## Dispara a cutscene do professor na primeira vez que o jogador
## entra na área de presença da sala.
## ============================================================

@export var falas_professor_sentem: Array[String] = [
	"Bom dia, turma! vamos começar a aula de hoje.",
	"Senta ai galera.",
]

var _cutscene_ja_aconteceu: bool = false


func _ready() -> void:
	super._ready()
	
	# Procura automaticamente qualquer nó de presença na sala para ouvir o sinal
	var area_presenca = find_child("*Presenca*", true, false)
	if area_presenca and area_presenca.has_signal("body_entered"):
		area_presenca.body_entered.connect(_on_jogador_entrou_na_sala)


func _on_jogador_entrou_na_sala(body: Node2D) -> void:
	print("1. O jogador entrou na área de colisão")
	
	if not body.is_in_group("jogador"):
		return
	if _cutscene_ja_aconteceu:
		return

	_cutscene_ja_aconteceu = true
	print("2. Iniciando a espera de 1.5 segundos...")

	# Atraso de 1.5 segundos
	await get_tree().create_timer(1.5).timeout
	print("3. O tempo de espera acabou!")

	# Trava de segurança: impede que a fala do professor atropele 
	# outro diálogo caso você tenha interagido com a carteira nesse meio tempo.
	if DialogoBox.esta_ativo():
		print("4. Outro diálogo já está na tela, cancelando a fala do professor.")
		return

	if not falas_professor_sentem.is_empty():
		print("5. Exibindo o diálogo do professor.")
		DialogoBox.mostrar_dialogo("Professor", falas_professor_sentem)
