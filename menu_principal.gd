extends Node2D

@onready var menu_principal_box: VBoxContainer = $CanvasLayer/VBoxContainer
@onready var logo: TextureRect = $CanvasLayer/Logo
@onready var painel_config: Control = $CanvasLayer/PainelConfig
@onready var overlay_brilho: ColorRect = $CanvasLayer/OverlayBrilho
@onready var filtro_daltonismo: ColorRect = $CanvasLayer2/ColorRect

@onready var btn_jogar: Button = $CanvasLayer/VBoxContainer/BtnJogar
@onready var btn_config: Button = $CanvasLayer/VBoxContainer/BtnConfig
@onready var btn_sair: Button = $CanvasLayer/VBoxContainer/BtnSair


func _ready():
	btn_jogar.pressed.connect(jogar)
	btn_config.pressed.connect(abrir_config)
	btn_sair.pressed.connect(sair)

	painel_config.voltar.connect(fechar_config)
	painel_config.brilho_alterado.connect(aplicar_brilho)
	painel_config.daltonismo_alterado.connect(aplicar_daltonismo)
	painel_config.audio_alterado.connect(aplicar_audio)

	# Hover em todos os botões (menu principal + recursivo dentro do painel de config)
	_conectar_hover(btn_jogar)
	_conectar_hover(btn_config)
	_conectar_hover(btn_sair)
	_conectar_hover_recursivo(painel_config)

	painel_config.visible = false

	aplicar_brilho(1.0)
	aplicar_audio(1.0)


func _conectar_hover_recursivo(node: Node):
	for filho in node.get_children():
		if filho is Button:
			_conectar_hover(filho)
		_conectar_hover_recursivo(filho)


func _conectar_hover(btn: Button):
	btn.mouse_entered.connect(func(): animar_cor(btn, Color(0.7, 0.7, 0.7)))
	btn.mouse_exited.connect(func(): animar_cor(btn, Color(1, 1, 1)))


func animar_cor(btn: Control, cor: Color):
	var tween = create_tween()
	tween.tween_property(btn, "modulate", cor, 0.1)


# ── Menu Principal ────────────────────────────────────────────

func abrir_config():
	menu_principal_box.visible = false
	logo.visible = false
	painel_config.visible = true

	painel_config.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(painel_config, "modulate:a", 1.0, 0.3)


func fechar_config():
	var tween = create_tween()
	tween.tween_property(painel_config, "modulate:a", 0.0, 0.2)
	tween.finished.connect(func():
		painel_config.visible = false
		menu_principal_box.visible = true
		logo.visible = true
	)


func jogar():
	get_tree().change_scene_to_file("res://World.tscn")


func sair():
	get_tree().quit()


# ── Efeitos globais (brilho / daltonismo / áudio) ─────────────

func aplicar_brilho(valor: float):
	var alpha_maximo = 0.7
	overlay_brilho.color = Color(0, 0, 0, alpha_maximo * (1.0 - valor))


func aplicar_daltonismo(modo: int):
	filtro_daltonismo.material.set_shader_parameter("mode", modo)


func aplicar_audio(valor: float):
	var bus_index = AudioServer.get_bus_index("Master")
	if valor <= 0:
		AudioServer.set_bus_volume_db(bus_index, -80)
	else:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(valor))
