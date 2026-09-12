extends "res://minigames/shared/scripts/minigame.gd"
## ============================================================
## Aperte Tudo (adaptado do WarioWareGame, MIT, Bartosz
## Budnik/BudzioT: https://github.com/ar-bh/WarioWareGame)
## ------------------------------------------------------------
## Clique em todos os bonecos na tela antes do tempo acabar.
## ============================================================

@export var time_limit := 8.0
@export var buttons_required := 7

@onready var themed_timer: Node2D = $timer

var buttons_pressed := 0
var _rodando := false


func _ready() -> void:
	_instruction = "Clique em todos os bonecos antes do tempo acabar!"


func start() -> void:
	super.start()
	buttons_pressed = 0
	_rodando = true
	_rodar_contagem()


func stop() -> void:
	super.stop()
	_rodando = false


func _rodar_contagem() -> void:
	await themed_timer.Timer(time_limit)
	if _rodando and buttons_pressed < buttons_required:
		_rodando = false
		lost.emit()


func _process(_delta: float) -> void:
	if _rodando and buttons_pressed >= buttons_required:
		_rodando = false
		won.emit()
