extends "res://minigames/shared/scripts/minigame.gd"
## ============================================================
## Pegar os Bonecos (adaptado do WarioWareGame, MIT, Bartosz
## Budnik/BudzioT: https://github.com/ar-bh/WarioWareGame)
## ------------------------------------------------------------
## Plataforma simples: pule entre as plataformas e colete os
## bonecos espalhados antes do tempo acabar.
##
## Diferença pro original: lá ele mesmo trocava de cena e mexia
## num contador de vidas global. Aqui ele só emite won()/lost() —
## quem decide o que fazer depois (voltar pro mapa, dar pontos)
## é o GerenciadorDeMinigames.
## ============================================================

@export var time_limit := 12.0
@export var studs_required := 3

@onready var themed_timer: Node2D = $timer

var studs_collected := 0
var _rodando := false


func _ready() -> void:
	_instruction = "Pegue %d bonecos antes do tempo acabar!" % studs_required
	for child in get_children():
		if child.has_signal("stud_collected"):
			child.stud_collected.connect(_on_stud_collected)


## Sobrescreve Minigame.start() — só desbloqueia o jogador e
## dispara a contagem quando o GerenciadorDeMinigames mandar.
func start() -> void:
	super.start()
	studs_collected = 0
	_rodando = true
	_rodar_contagem()


func stop() -> void:
	super.stop()
	_rodando = false


func _rodar_contagem() -> void:
	await themed_timer.Timer(time_limit)
	if _rodando and studs_collected < studs_required:
		_rodando = false
		lost.emit()


func _process(_delta: float) -> void:
	if _rodando and studs_collected >= studs_required:
		_rodando = false
		won.emit()


func _on_stud_collected() -> void:
	studs_collected += 1
