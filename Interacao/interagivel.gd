extends Area2D

signal interagido
signal jogador_entrou_na_area(jogador: Node2D)
signal jogador_saiu_da_area(jogador: Node2D)

@export var nome_personagem: String = ""
@export var falas: Array[String] = []

@export_group("Escolhas de Diálogo")
@export var opcoes: Array[OpcaoDialogo] = []

@export_group("Missão do Caderno")
@export var falas_missao: Array[String] = []
@export var opcoes_missao: Array[OpcaoDialogo] = []
@export var falas_depois_da_tentativa: Array[String] = []

@export_group("Depois da Missão")
@export var falas_pos_missao: Array[String] = []
@export var falas_missao_falhou: Array[String] = []

@export_group("Entrega de Material")
@export var entrega_caderno: bool = false
@export var desaparece_ao_obter_material: bool = false

var _tentativa_de_material_ja_feita: bool = false
var _opcoes_abertas: Array[OpcaoDialogo] = []

var _jogador_por_perto: bool = false
var _label_dica: Label
var _dialogo_aberto_por_mim: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	DialogoBox.dialogo_finalizado.connect(_on_dialogo_finalizado)
	DialogoBox.opcao_escolhida.connect(_on_opcao_escolhida)

	if has_node("LabelDica"):
		_label_dica = $LabelDica
		_label_dica.visible = false

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("jogador"):
		return
	_jogador_por_perto = true
	if _label_dica:
		_label_dica.visible = true
	jogador_entrou_na_area.emit(body)

func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("jogador"):
		return
	_jogador_por_perto = false
	if _label_dica:
		_label_dica.visible = false
	jogador_saiu_da_area.emit(body)

func _unhandled_input(event: InputEvent) -> void:
	if not _jogador_por_perto:
		return
	if DialogoBox.esta_ativo():
		return
	if not event.is_action_pressed("interagir"):
		return

	if falas.is_empty():
		return

	_dialogo_aberto_por_mim = true
	interagido.emit()
	
	if not opcoes.is_empty():
		DialogoBox.mostrar_dialogo_com_opcoes(nome_personagem, falas, opcoes)
	else:
		DialogoBox.mostrar_dialogo(nome_personagem, falas)
		
	get_viewport().set_input_as_handled()

func _on_dialogo_finalizado() -> void:
	if not _dialogo_aberto_por_mim:
		return
	_dialogo_aberto_por_mim = false

func _on_opcao_escolhida(opcao: OpcaoDialogo) -> void:
	if not _dialogo_aberto_por_mim:
		return
	if not opcoes.has(opcao):
		return
	# Se no futuro você criar novas ações para as opções, coloque-as aqui.
