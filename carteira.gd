extends Area2D

signal missao_iniciada
signal sentou_na_carteira

@export var dialogo_primeira_aula: DialogueResource

var _primeira_interacao_do_dia: bool = true
var _jogador_por_perto: bool = false
var _label_dica: Label


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if has_node("LabelDica"):
		_label_dica = $LabelDica
		_label_dica.visible = false


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("jogador"):
		return

	_jogador_por_perto = true

	if _label_dica:
		_label_dica.visible = true


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("jogador"):
		return

	_jogador_por_perto = false

	if _label_dica:
		_label_dica.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not _jogador_por_perto:
		return

	if not event.is_action_pressed("interagir"):
		return

	if event.is_echo():
		return

	if dialogo_primeira_aula == null:
		push_warning("Defina o diálogo da primeira aula na carteira.")
		return

	if not GerenciadorDeDialogos.iniciar_dialogo_manager():
		return

	get_viewport().set_input_as_handled()

	if _primeira_interacao_do_dia:
		_primeira_interacao_do_dia = false
		_iniciar_cutscene_bom_dia()
		return

	if Global.tem_caderno:
		_sentar_na_carteira()
	else:
		_iniciar_missao_caderno()


func _mostrar_dialogo(cue: String) -> void:
	DialogueManager.show_dialogue_balloon(
		dialogo_primeira_aula,
		cue
	)


func _ativar_missao_se_necessario() -> void:
	if Global.tem_caderno:
		return

	if Global.missao_caderno_ativa or Global.missao_caderno_falhou:
		return

	Global.iniciar_missao_caderno()
	missao_iniciada.emit()


func _iniciar_cutscene_bom_dia() -> void:
	if Global.tem_caderno:
		GerenciadorDeEventos.jogador_presente_manual = true
		sentou_na_carteira.emit()
		_mostrar_dialogo("primeira_interacao_com_material")
	else:
		_ativar_missao_se_necessario()
		_mostrar_dialogo("primeira_interacao_sem_material")


func _iniciar_missao_caderno() -> void:
	_ativar_missao_se_necessario()
	_mostrar_dialogo("sem_material")


func _sentar_na_carteira() -> void:
	GerenciadorDeEventos.jogador_presente_manual = true
	sentou_na_carteira.emit()
	_mostrar_dialogo("com_material")
