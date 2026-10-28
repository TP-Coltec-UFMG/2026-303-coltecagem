extends CanvasLayer
## TelaProva (Autoload)
## Mostra por DURACAO_SEGUNDOS o resultado da prova: a nota
## (desempenho + sorte) se o jogador chegou à sala, ou
## "Prova Perdida!" se não chegou. O jogo e o relógio param.

const DURACAO_SEGUNDOS := 5

const COR_PASSOU := Color(0.45, 0.9, 0.55)
const COR_ABAIXO := Color(1.0, 0.75, 0.35)
const COR_PERDEU := Color(1.0, 0.3, 0.3)

var _raiz: Control
var _etiqueta: Label
var _titulo: Label
var _detalhe: Label
var _contagem: Label
var _consequencia: Label

func _ready() -> void:
	layer = 90 # abaixo da TelaFinal (100)
	process_mode = Node.PROCESS_MODE_ALWAYS # funciona com a árvore pausada
	_montar_interface()
	_raiz.visible = false
	GerenciadorDeEventos.prova_resultado.connect(_on_prova_resultado)


func _montar_interface() -> void:
	_raiz = Control.new()
	_raiz.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_raiz)
	_raiz.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var fundo := ColorRect.new()
	fundo.color = Color(0.04, 0.06, 0.09, 0.9)
	_raiz.add_child(fundo)
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var centro := CenterContainer.new()
	_raiz.add_child(centro)
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var caixa := VBoxContainer.new()
	caixa.custom_minimum_size = Vector2(520, 0)
	caixa.add_theme_constant_override("separation", 14)
	centro.add_child(caixa)

	_etiqueta = Label.new()
	_etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_etiqueta.modulate = Color(1, 1, 1, 0.65)
	caixa.add_child(_etiqueta)

	_titulo = Label.new()
	_titulo.add_theme_font_size_override("font_size", 56)
	_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_titulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caixa.add_child(_titulo)

	_detalhe = Label.new()
	_detalhe.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_detalhe.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caixa.add_child(_detalhe)
	
	_consequencia = Label.new()
	_consequencia.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_consequencia.add_theme_font_size_override("font_size", 16)
	caixa.add_child(_consequencia)
	
	_contagem = Label.new()
	_contagem.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_contagem.modulate = Color(1, 1, 1, 0.5)
	caixa.add_child(_contagem)


func _on_prova_resultado(compareceu: bool, nota: int) -> void:
	if _raiz.visible:
		return

	if compareceu:
		var passou := nota >= EstadoJogador.MEDIA_APROVACAO
		_etiqueta.text = "RESULTADO DA PROVA"
		_titulo.text = "Nota %d" % nota
		_titulo.add_theme_color_override("font_color", COR_PASSOU if passou else COR_ABAIXO)
		_detalhe.add_theme_font_size_override("font_size", 18)
		_detalhe.text = "Desempenho acadêmico %d  |  Sorte %+d\n%s" % [
			EstadoJogador.desempenho_academico,
			EstadoJogador.ultimo_fator_sorte,
			"Acima da média!" if passou else "Abaixo da média (%d)." % EstadoJogador.MEDIA_APROVACAO,
		]
	else:
		_etiqueta.text = "VOCÊ NÃO CHEGOU À SALA"
		_titulo.text = "Prova Perdida!"
		_titulo.add_theme_color_override("font_color", COR_PERDEU)
		_detalhe.add_theme_font_size_override("font_size", 40)
		_detalhe.text = "Nota 0!!!"
		
	var delta := EstadoJogador.ultimo_delta_prova
	if delta != 0:
		_consequencia.text = "Desempenho %+d" % delta
		_consequencia.add_theme_color_override("font_color", COR_PASSOU if delta > 0 else COR_PERDEU)
	else:
		_consequencia.text = ""
		
	var dia_rodava := GerenciadorDeTempo.rodando
	GerenciadorDeTempo.pausar_dia()
	get_tree().paused = true
	_raiz.visible = true

	for segundos in range(DURACAO_SEGUNDOS, 0, -1):
		_contagem.text = "O jogo continua em %d..." % segundos
		await get_tree().create_timer(1.0, true, false, true).timeout

	_raiz.visible = false
	get_tree().paused = false
	if dia_rodava:
		GerenciadorDeTempo.retomar_dia()
