extends Node2D

@onready var menu_config = $CanvasLayer/PainelConfig/VBoxContainer
@onready var menu_principal = $CanvasLayer/VBoxContainer
@onready var logo = $CanvasLayer/TextureRect
@onready var painel_config = $CanvasLayer/PainelConfig

# ── Botões Menu Principal ─────────────────────────────────────

@onready var btn_jogar = $CanvasLayer/VBoxContainer/BtnJogar
@onready var btn_config = $CanvasLayer/VBoxContainer/BtnConfig
@onready var btn_sair = $CanvasLayer/VBoxContainer/BtnSair

# ── Configurações ─────────────────────────────────────────────

@onready var vbox_config = $CanvasLayer/PainelConfig/VBoxContainer

@onready var btn_voltar = $CanvasLayer/PainelConfig/VBoxContainer/BtnVoltar

@onready var btn_acessibilidade = $CanvasLayer/PainelConfig/VBoxContainer/BtnAcessibilidade

# ── Painel de Brilho ──────────────────────────────────────────

@onready var painel_brilho = $CanvasLayer/PainelConfig/PainelBrilho

@onready var slider_brilho = $CanvasLayer/PainelConfig/PainelBrilho/VBoxContainer/SliderBrilho

@onready var overlay_brilho = $CanvasLayer/OverlayBrilho

@onready var btn_voltar_brilho = $CanvasLayer/PainelConfig/PainelBrilho/VBoxContainer/BtnVoltarBrilho


func _ready():

	# ── Menu Principal ───────────────────────────────────────

	btn_jogar.pressed.connect(jogar)
	btn_config.pressed.connect(abrir_config)
	btn_sair.pressed.connect(sair)

	# ── Configurações ────────────────────────────────────────

	btn_voltar.pressed.connect(fechar_config)

	btn_acessibilidade.pressed.connect(abrir_brilho)

	# ── Painel de Brilho ─────────────────────────────────────

	btn_voltar_brilho.pressed.connect(fechar_brilho)

	slider_brilho.value_changed.connect(aplicar_brilho)

	# ── Hover nos botões ─────────────────────────────────────

	var lista_botoes = [
		btn_jogar,
		btn_config,
		btn_sair,
		btn_voltar,
		btn_acessibilidade,
		btn_voltar_brilho
	]

	for btn in lista_botoes:

		btn.mouse_entered.connect(
			func():
				animar_cor(btn, Color(0.7, 0.7, 0.7))
		)

		btn.mouse_exited.connect(
			func():
				animar_cor(btn, Color(1, 1, 1))
		)

	# ── Estado inicial ───────────────────────────────────────

	painel_config.visible = false

	painel_brilho.visible = false

	# brilho inicial
	aplicar_brilho(slider_brilho.value)


# ── Hover Animation ───────────────────────────────────────────

func animar_cor(btn, cor):

	var tween = create_tween()

	tween.tween_property(
		btn,
		"modulate",
		cor,
		0.1
	)


# ── Menu Principal ────────────────────────────────────────────

func abrir_config():

	menu_principal.visible = false

	logo.visible = false

	painel_config.visible = true

	var pos_final = vbox_config.position

	vbox_config.position.y += 50

	painel_config.modulate.a = 0

	var tween = create_tween()

	tween.tween_property(
		painel_config,
		"modulate:a",
		1.0,
		0.3
	)

	tween.parallel().tween_property(
		vbox_config,
		"position",
		pos_final,
		0.4
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func fechar_config():

	var tween = create_tween()

	tween.tween_property(
		painel_config,
		"modulate:a",
		0.0,
		0.2
	)

	tween.finished.connect(
		func():
			painel_config.visible = false
			menu_principal.visible = true
			logo.visible = true
	)


func jogar():

	get_tree().change_scene_to_file("res://fase_1.tscn")


func sair():

	get_tree().quit()


# ── Painel de Brilho ──────────────────────────────────────────

func abrir_brilho():

	painel_brilho.visible = true

	menu_config.visible = false


func fechar_brilho():

	painel_brilho.visible = false

	menu_config.visible = true


func aplicar_brilho(valor: float):

	overlay_brilho.color = Color(
		0,
		0,
		0,
		1.0 - valor
	)
