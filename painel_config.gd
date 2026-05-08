extends Control

# Lembre-se de verificar se este caminho aponta pro seu ColorRect!
@onready var filtro = $"../../CanvasLayer2/ColorRect"


func _on_btn_normal_pressed():
	filtro.material.set_shader_parameter("mode", 0)

func _on_btn_protanopia_pressed():
	filtro.material.set_shader_parameter("mode", 1)

func _on_btn_deuteranopia_pressed():
	filtro.material.set_shader_parameter("mode", 2)

func _on_btn_tritanopia_pressed():
	filtro.material.set_shader_parameter("mode", 3)

func _on_btn_acromatopsia_pressed():
	filtro.material.set_shader_parameter("mode", 4)
