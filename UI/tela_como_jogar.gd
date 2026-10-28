extends Control
## ============================================================
## Tela "Como jogar"
## ------------------------------------------------------------
## Aberta pelo botão "Como jogar" do menu principal.
## Não precisa de cena: o menu cria esta tela por código.
## Quem a criou escuta o sinal:
##   voltar -> o jogador apertou "Voltar" (ou Esc)
## ============================================================

signal voltar

const SECOES := [
	["OBJETIVO", "Termine o dia, às 17:10, com desempenho 60 ou mais. Seu final depende das barras de energia, estresse, social e desempenho."],
	["CONTROLES", "W A S D: andar\nE: falar e jogar minigames\nEspaço ou Enter: avançar o diálogo"],
	["AULAS E PROVA", "Um aviso no alto da tela diz quando há aula. Dentro da sala você assiste (ganha desempenho, gasta energia). Fora, você mata aula (ganha social, perde desempenho). A prova é surpresa: corra para a sala ou tire zero."],
	["MINIGAMES", "Aperte E perto de objetos e personagens para jogar. Cada um dá algo e cobra algo, e leva um tempo para jogar de novo. Com estresse a partir de 90 você não consegue ir às aulas."],
]


func _ready() -> void:
	theme = load("res://theme/theme.tres") as Theme
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var fundo := ColorRect.new()
	fundo.color = Color(0.05, 0.06, 0.1, 0.96)
	add_child(fundo)
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var margem := MarginContainer.new()
	for lado in ["left", "right"]:
		margem.add_theme_constant_override("margin_" + lado, 70)
	for lado in ["top", "bottom"]:
		margem.add_theme_constant_override("margin_" + lado, 30)
	add_child(margem)
	margem.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var coluna := VBoxContainer.new()
	coluna.add_theme_constant_override("separation", 14)
	margem.add_child(coluna)

	var titulo := Label.new()
	titulo.text = "COMO JOGAR"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 26)
	coluna.add_child(titulo)

	var rolagem := ScrollContainer.new()
	rolagem.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rolagem.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	coluna.add_child(rolagem)

	var secoes := VBoxContainer.new()
	secoes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	secoes.add_theme_constant_override("separation", 16)
	rolagem.add_child(secoes)

	for s in SECOES:
		var cabecalho := Label.new()
		cabecalho.text = s[0]
		cabecalho.add_theme_font_size_override("font_size", 14)
		cabecalho.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
		secoes.add_child(cabecalho)

		var texto := Label.new()
		texto.text = s[1]
		texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		texto.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		texto.add_theme_font_size_override("font_size", 11)
		texto.add_theme_constant_override("line_spacing", 6)
		secoes.add_child(texto)

	var botoes := HBoxContainer.new()
	botoes.alignment = BoxContainer.ALIGNMENT_CENTER
	botoes.add_theme_constant_override("separation", 24)
	coluna.add_child(botoes)

	var btn_voltar := Button.new()
	btn_voltar.text = "Voltar"
	btn_voltar.custom_minimum_size = Vector2(220, 50)
	btn_voltar.pressed.connect(func(): voltar.emit())
	botoes.add_child(btn_voltar)

	btn_voltar.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		voltar.emit()
