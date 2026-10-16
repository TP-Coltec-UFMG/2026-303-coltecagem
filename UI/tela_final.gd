extends CanvasLayer
## TelaFinal (Autoload)
## Aparece quando o dia letivo termina (HUD.fim_de_jogo_hud):
## calcula o final, mostra o resultado e deixa jogar de novo.
## A interface é montada por código no _ready().

const CENA_JOGO := "res://scenes/mapas/Coltec.tscn"
const CENA_MENU := "res://scenes/menu_principal.tscn"

## Mesma ordem do enum EstadoJogador.Final
const DESCRICOES := [
	"Notas altas e a cabeça no lugar. Você provou que dá para estudar sem se acabar.", # ALUNO_EXEMPLAR
	"Nota excelente, mas poucos amigos para comemorar. Valeu a pena?", # GENIO_SOLITARIO
	"Passou, e o Coltec inteiro sabe seu nome. As notas foram só o suficiente.", # MAIS_POPULAR_DA_TURMA
	"Passou de ano se arrastando, sem energia e no limite do estresse.", # SOBREVIVEU_POR_POUCO
	"Não passou, mas fez amizades para a vida toda.", # VIDA_SOCIAL_EM_PRIMEIRO_LUGAR
	"As notas vieram, mas o estresse cobrou o preço. Hora de descansar.", # BURNOUT_ACADEMICO
	"As notas não chegaram à média. O ano que vem vai ser outro.", # REPETENTE
	"Nada de extraordinário: você passou, e isso já é uma vitória.", # FORMADO_NA_MEDIA
]

var _raiz: Control
var _titulo: Label
var _descricao: Label
var _nota: Label
var _linhas := {} # nome do atributo -> {"barra": ProgressBar, "valor": Label}
var _btn_jogar: Button


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS # funciona com a árvore pausada
	_montar_interface()
	_raiz.visible = false
	HUD.fim_de_jogo_hud.connect(_mostrar)


func _montar_interface() -> void:
	_raiz = Control.new()
	_raiz.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_raiz)
	_raiz.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var fundo := ColorRect.new()
	fundo.color = Color(0.04, 0.06, 0.09, 0.93)
	_raiz.add_child(fundo)
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var centro := CenterContainer.new()
	_raiz.add_child(centro)
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var caixa := VBoxContainer.new()
	caixa.custom_minimum_size = Vector2(520, 0)
	caixa.add_theme_constant_override("separation", 14)
	centro.add_child(caixa)

	var etiqueta := Label.new()
	etiqueta.text = "FIM DO DIA LETIVO"
	etiqueta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiqueta.modulate = Color(1, 1, 1, 0.6)
	caixa.add_child(etiqueta)

	_titulo = Label.new()
	_titulo.add_theme_font_size_override("font_size", 40)
	_titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_titulo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caixa.add_child(_titulo)

	_descricao = Label.new()
	_descricao.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_descricao.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caixa.add_child(_descricao)

	caixa.add_child(HSeparator.new())

	for nome in ["Energia", "Estresse", "Social", "Desempenho"]:
		caixa.add_child(_criar_linha(nome))

	_nota = Label.new()
	_nota.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caixa.add_child(_nota)

	var botoes := HBoxContainer.new()
	botoes.alignment = BoxContainer.ALIGNMENT_CENTER
	botoes.add_theme_constant_override("separation", 16)
	caixa.add_child(botoes)

	_btn_jogar = Button.new()
	_btn_jogar.text = "Jogar de novo"
	_btn_jogar.custom_minimum_size = Vector2(200, 44)
	_btn_jogar.pressed.connect(_jogar_de_novo)
	botoes.add_child(_btn_jogar)

	var btn_menu := Button.new()
	btn_menu.text = "Voltar ao menu"
	btn_menu.custom_minimum_size = Vector2(200, 44)
	btn_menu.pressed.connect(_voltar_ao_menu)
	botoes.add_child(btn_menu)


func _criar_linha(nome: String) -> HBoxContainer:
	var linha := HBoxContainer.new()
	linha.add_theme_constant_override("separation", 10)

	var rotulo := Label.new()
	rotulo.text = nome
	rotulo.custom_minimum_size = Vector2(120, 0)
	linha.add_child(rotulo)

	var barra := ProgressBar.new()
	barra.max_value = 100
	barra.show_percentage = false
	barra.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	barra.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	barra.custom_minimum_size = Vector2(0, 18)
	linha.add_child(barra)

	var valor := Label.new()
	valor.custom_minimum_size = Vector2(40, 0)
	valor.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	linha.add_child(valor)

	_linhas[nome] = {"barra": barra, "valor": valor}
	return linha


func _mostrar() -> void:
	if _raiz.visible:
		return

	var final: int = EstadoJogador.verificar_final()
	_titulo.text = EstadoJogador.NOME_FINAL[final]
	_descricao.text = DESCRICOES[final]

	_definir("Energia", EstadoJogador.energia)
	_definir("Estresse", EstadoJogador.estresse)
	_definir("Social", EstadoJogador.social)
	_definir("Desempenho", EstadoJogador.desempenho_academico)

	if EstadoJogador.ultima_nota >= 0:
		_nota.text = "Nota da última prova: %d (média para passar: %d)" % [
			EstadoJogador.ultima_nota, EstadoJogador.MEDIA_APROVACAO]
	else:
		_nota.text = "Você não fez nenhuma prova."

	_raiz.visible = true
	get_tree().paused = true
	_btn_jogar.grab_focus()


func _definir(nome: String, valor: int) -> void:
	_linhas[nome]["barra"].value = valor
	_linhas[nome]["valor"].text = str(valor)


func _fechar() -> void:
	_raiz.visible = false
	get_tree().paused = false
	Global.reiniciar_partida()


func _jogar_de_novo() -> void:
	_fechar()
	get_tree().change_scene_to_file(CENA_JOGO)


func _voltar_ao_menu() -> void:
	_fechar()
	get_tree().change_scene_to_file(CENA_MENU)
