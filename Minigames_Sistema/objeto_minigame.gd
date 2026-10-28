extends "res://Minigames_Sistema/minigame_task_area.gd"
## ============================================================
## ObjetoMinigame
## ------------------------------------------------------------
## Objeto parado do mapa que abre um minigame ao apertar E.
## Tudo da estação (cena do minigame, recompensa, cooldown, dica)
## vem do minigame_task_area.gd. Aqui só entram o visual e os
## tamanhos, ajustáveis no Inspetor da instância:
##   Textura            -> a imagem do objeto
##   Escala Da Textura  -> aumenta ou diminui a imagem
##   Tamanho Da Zona    -> área em volta onde o E funciona
##   Bloqueia Passagem  -> o jogador esbarra no objeto (corpo sólido)
##   Tamanho Do Corpo   -> tamanho do corpo sólido, na base do objeto
## ============================================================
## Valores da tabela por categoria (vale quando Categoria não é "Manual").


const CATEGORIAS := {
	"Estudo": {"energia": -2, "estresse": 4, "social": 0, "desempenho_academico": 6, "cooldown": 90.0},
	"Social": {"energia": -6, "estresse": 0, "social": 10, "desempenho_academico": 0, "cooldown": 60.0},
	"Ação": {"energia": -6, "estresse": -6, "social": 4, "desempenho_academico": 0, "cooldown": 45.0},
	"Relax": {"energia": 0, "estresse": -10, "social": 0, "desempenho_academico": -2, "cooldown": 60.0},
	"Comida": {"energia": 10, "estresse": 0, "social": -2, "desempenho_academico": 0, "cooldown": 90.0},
	"Descarregar": {"energia": -8, "estresse": -12, "social": 0, "desempenho_academico": 0, "cooldown": 60.0},
}

## Escolha uma categoria e a recompensa e o cooldown vêm da tabela.
## "Manual" mantém os números digitados nos campos abaixo.
@export_enum("Manual", "Estudo", "Social", "Ação", "Relax", "Comida", "Descarregar") var categoria: String = "Manual"

@export_group("Visual")
@export var textura: Texture2D
@export var escala_da_textura: Vector2 = Vector2.ONE

@export_group("Colisão")
@export var tamanho_da_zona: Vector2 = Vector2(48, 48)
@export var bloqueia_passagem: bool = true
@export var tamanho_do_corpo: Vector2 = Vector2(20, 12)
@export_group("")

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _zona: CollisionShape2D = $CollisionShape2D
@onready var _corpo: StaticBody2D = $Corpo
@onready var _forma_do_corpo: CollisionShape2D = $Corpo/CollisionShape2D


func _ready() -> void:
	if textura:
		_sprite.texture = textura
		_sprite.scale = escala_da_textura

	# A zona precisa estar pronta ANTES do super._ready(), que usa
	# o formato dela para posicionar a dica acima do objeto.
	var zona := RectangleShape2D.new()
	zona.size = tamanho_da_zona
	_zona.shape = zona

	if bloqueia_passagem:
		var forma := RectangleShape2D.new()
		forma.size = tamanho_do_corpo
		_forma_do_corpo.shape = forma
	else:
		_corpo.queue_free()
		
	if categoria != "Manual" and CATEGORIAS.has(categoria):
		var c: Dictionary = CATEGORIAS[categoria]
		energia = c["energia"]
		estresse = c["estresse"]
		social = c["social"]
		desempenho_academico = c["desempenho_academico"]
		cooldown_segundos = c["cooldown"]
		
	super._ready()
