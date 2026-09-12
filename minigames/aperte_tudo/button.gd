extends TextureButton

@onready var parent: Node = get_parent()


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	# _unlock_controls vem da classe base Minigame — só conta o
	# clique se o GerenciadorDeMinigames já chamou start().
	if not parent._unlock_controls:
		return
	hide()
	parent.buttons_pressed += 1
