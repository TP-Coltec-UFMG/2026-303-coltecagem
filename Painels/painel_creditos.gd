extends Control

signal voltar

const Dados := preload("res://Painels/creditos_dados.gd")

@onready var btn_voltar: Button = $BtnVoltar


func _ready():
	btn_voltar.pressed.connect(func(): voltar.emit())
	var antigo := get_node_or_null("Label")
	if antigo:
		antigo.visible = false
	_montar_lista()


## Lista rolável com a equipe e os créditos de terceiros
## (o texto vem de Painels/creditos_dados.gd).
func _montar_lista() -> void:
	var rolagem := ScrollContainer.new()
	rolagem.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(rolagem)
	rolagem.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rolagem.offset_left = 90
	rolagem.offset_right = -90
	rolagem.offset_top = 30
	rolagem.offset_bottom = -100

	var texto := Label.new()
	texto.text = Dados.TEXTO
	texto.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	texto.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto.add_theme_font_size_override("font_size", 10)
	texto.add_theme_constant_override("line_spacing", 6)
	rolagem.add_child(texto)
