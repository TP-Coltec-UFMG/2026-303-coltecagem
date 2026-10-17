extends Area2D
## ============================================================
## MinigameTaskArea
## ------------------------------------------------------------
## Estação de minigame: anexe numa Area2D (com um CollisionShape2D)
## em qualquer objeto ou NPC. Ao apertar E perto dela, abre o
## minigame e converte o resultado em pontos de atributo.
##
## Sem custo de ação. Depois de jogar, a estação fica em cooldown
## (contado em tempo de jogo, só enquanto o dia roda).
##
## No Inspetor:
##   Cena Do Minigame  -> o .tscn do minigame
##   Recompensas       -> Energia, Estresse, Social, Desempenho Academico -> números (positivos ou negativos).
##   Cooldown Segundos -> quanto tempo até poder jogar de novo
##   Texto Dica        -> texto mostrado perto da estação
## A dica é criada sozinha; se existir um filho "LabelDica", ele
## é usado no lugar.
## ============================================================

@export var cena_do_minigame: PackedScene

@export_group("Recompensa ao vencer (perder dá metade)")
## Use números pares: ao perder, o jogador recebe metade.
@export var energia: int = 0
@export var estresse: int = 0
@export var social: int = 0
@export var desempenho_academico: int = 0
@export_group("")

@export var cooldown_segundos: float = 60.0
@export var texto_dica: String = "[E] jogar"

var _jogador_por_perto: bool = false
var _label_dica: Label


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_preparar_dica()


func _process(_delta: float) -> void:
	if _label_dica == null or not _jogador_por_perto:
		return

	var restante := _segundos_restantes()
	if restante > 0.0:
		_label_dica.text = "Disponível em %d s" % ceili(restante)
		_label_dica.modulate = Color(1, 1, 1, 0.6)
	else:
		_label_dica.text = texto_dica
		_label_dica.modulate = Color(1, 1, 1, 1)

	# Esconde a dica durante diálogos
	_label_dica.visible = not GerenciadorDeDialogos.dialogo_manager_ativo


func _preparar_dica() -> void:
	if has_node("LabelDica"):
		_label_dica = $LabelDica
	else:
		_label_dica = Label.new()
		_label_dica.name = "LabelDica"
		var tema := load("res://theme/theme.tres") as Theme
		if tema:
			_label_dica.theme = tema
		_label_dica.add_theme_font_size_override("font_size", 8)
		_label_dica.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_label_dica.custom_minimum_size = Vector2(72, 16)
		_label_dica.position = _posicao_da_dica()
		add_child(_label_dica)

	_label_dica.text = texto_dica
	_label_dica.visible = false
	
	
## Monta o dicionário que o GerenciadorDeMinigames espera,
## ignorando os campos que ficaram em 0.
func _montar_recompensas() -> Dictionary:
	var r := {}
	if energia != 0:
		r["energia"] = energia
	if estresse != 0:
		r["estresse"] = estresse
	if social != 0:
		r["social"] = social
	if desempenho_academico != 0:
		r["desempenho_academico"] = desempenho_academico
	return r

## Põe a dica acima do formato de colisão da estação.
func _posicao_da_dica() -> Vector2:
	var centro := Vector2.ZERO
	var meia_altura := 8.0
	for filho in get_children():
		if filho is CollisionShape2D:
			centro = filho.position
			var forma = filho.shape
			if forma is RectangleShape2D:
				meia_altura = forma.size.y * 0.5
			elif forma is CircleShape2D:
				meia_altura = forma.radius
			elif forma is CapsuleShape2D:
				meia_altura = forma.height * 0.5
			break
	return Vector2(centro.x - 36.0, centro.y - meia_altura - 24.0)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("jogador"):
		return
	_jogador_por_perto = true


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("jogador"):
		return
	_jogador_por_perto = false
	if _label_dica:
		_label_dica.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not _jogador_por_perto or cena_do_minigame == null:
		return
	if not event.is_action_pressed("interagir"):
		return

	get_viewport().set_input_as_handled()

	if GerenciadorDeDialogos.dialogo_manager_ativo:
		return
	if GerenciadorDeMinigames.esta_ocupado():
		return
	if _segundos_restantes() > 0.0:
		return

	Global.estacoes_liberam_em[_id_da_estacao()] = Global.tempo_de_jogo + cooldown_segundos
	GerenciadorDeMinigames.iniciar_minigame(cena_do_minigame.resource_path, _montar_recompensas())

## Identifica ESTA estação entre recarregamentos da cena.
func _id_da_estacao() -> String:
	return str(get_path())


func _segundos_restantes() -> float:
	var libera_em: float = Global.estacoes_liberam_em.get(_id_da_estacao(), 0.0)
	return maxf(0.0, libera_em - Global.tempo_de_jogo)
