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
@onready var btn_audio = $CanvasLayer/PainelConfig/VBoxContainer/BtnAudio
@onready var btn_creditos = $CanvasLayer/PainelConfig/VBoxContainer/BtnCreditos

# ── Painel de Brilho ──────────────────────────────────────────

@onready var painel_brilho = $CanvasLayer/PainelConfig/PainelBrilho
@onready var slider_brilho = $CanvasLayer/PainelConfig/PainelBrilho/SliderBrilho
@onready var btn_voltar_brilho = $CanvasLayer/PainelConfig/PainelBrilho/BtnVoltarBrilho
@onready var overlay_brilho = $CanvasLayer/OverlayBrilho

# ── Painel de Áudio ───────────────────────────────────────────

@onready var painel_audio = $CanvasLayer/PainelConfig/PainelAudio
@onready var slider_audio = $CanvasLayer/PainelConfig/PainelAudio/SliderAudio
@onready var btn_voltar_audio = $CanvasLayer/PainelConfig/PainelAudio/BtnVoltarAudio

# ── Painel de Créditos ────────────────────────────────────────

@onready var painel_creditos = $CanvasLayer/PainelConfig/PainelCreditos
@onready var btn_voltar_creditos = $CanvasLayer/PainelConfig/PainelCreditos/BtnVoltarCreditos



func _ready():

	# ── Menu Principal ───────────────────────────────────────

	btn_jogar.pressed.connect(jogar)
	btn_config.pressed.connect(abrir_config)
	btn_sair.pressed.connect(sair)

	# ── Configurações ────────────────────────────────────────

	btn_voltar.pressed.connect(fechar_config)
	btn_acessibilidade.pressed.connect(abrir_brilho)
	btn_audio.pressed.connect(abrir_audio)
	btn_creditos.pressed.connect(abrir_creditos)

	# ── Painel de Brilho ─────────────────────────────────────

	btn_voltar_brilho.pressed.connect(fechar_brilho)
	slider_brilho.value_changed.connect(aplicar_brilho)

	# ── Painel de Áudio ──────────────────────────────────────

	btn_voltar_audio.pressed.connect(fechar_audio)
	slider_audio.value_changed.connect(aplicar_audio)

	# ── Painel de Créditos ───────────────────────────────────

	btn_voltar_creditos.pressed.connect(fechar_creditos)

	# ── Hover nos botões ─────────────────────────────────────

	var lista_botoes = [
		btn_jogar,
		btn_config,
		btn_sair,
		btn_voltar,
		btn_acessibilidade,
		btn_audio,
		btn_creditos,
		btn_voltar_brilho,
		btn_voltar_audio,
		btn_voltar_creditos
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
	painel_audio.visible = false
	painel_creditos.visible = false

	aplicar_brilho(slider_brilho.value)
	aplicar_audio(slider_audio.value)


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

	var alpha_maximo = 0.7

	overlay_brilho.color = Color(
		0,
		0,
		0,
		alpha_maximo * (1.0 - valor)
	)


# ── Painel de Áudio ───────────────────────────────────────────

func abrir_audio():
	painel_audio.visible = true
	menu_config.visible = false


func fechar_audio():
	painel_audio.visible = false
	menu_config.visible = true


func aplicar_audio(valor: float):

	var bus_index = AudioServer.get_bus_index("Master")

	if valor <= 0:
		AudioServer.set_bus_volume_db(bus_index, -80)
	else:
		AudioServer.set_bus_volume_db(
			bus_index,
			linear_to_db(valor)
		)


# ── Painel de Créditos ────────────────────────────────────────

func abrir_creditos():
	painel_creditos.visible = true
	menu_config.visible = false


func fechar_creditos():
	painel_creditos.visible = false
	menu_config.visible = true
	
