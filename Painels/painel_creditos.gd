extends Control

signal voltar

@onready var btn_voltar: Button = $BtnVoltar


func _ready():
	btn_voltar.pressed.connect(func(): voltar.emit())
