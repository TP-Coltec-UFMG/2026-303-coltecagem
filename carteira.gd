extends Area2D
## ============================================================
## Carteira
## ------------------------------------------------------------
## A carteira do jogador dentro da SalaDeAula.tscn. Ao interagir
## (tecla "interagir"):
##   - Se Global.tem_caderno == false: o jogador percebe que
##     esqueceu o caderno. Isso INICIA a missão (mostra um
##     diálogo de aviso e liga Global.missao_caderno_ativa).
##     Nenhum ganho de pontos de aula acontece nesse estado.
##   - Se Global.tem_caderno == true: o jogador já tem o caderno
##     em mãos, senta e começa a prestar atenção — liga
##     GerenciadorDeEventos.jogador_presente_manual = true, que é
##     o gatilho (placeholder) pro ganho de pontos da aula.
##
## Pré-requisito: o personagem controlável precisa estar no grupo
## "jogador".
##
## Como usar (no editor):
##   1. Area2D (com este script) + CollisionShape2D como filhos,
##      posicionados sobre a carteira do jogador no tilemap.
##   2. (opcional) um Label "LabelDica" como filho, pra "aperte E".
## ============================================================

signal missao_iniciada
signal sentou_na_carteira

## Falas mostradas quando o jogador percebe que esqueceu o caderno.
@export var falas_sem_caderno: Array[String] = [
	"Cadê meu caderno? Acho que esqueci em algum lugar...",
	"Preciso achar meu caderno antes que a aula comece.",
]

## Falas mostradas quando o jogador já tem o caderno e senta.
@export var falas_com_caderno: Array[String] = [
	"Beleza, caderno em mãos. Bora prestar atenção na aula.",
]

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
	if DialogoBox.esta_ativo():
		return
	if not event.is_action_pressed("interagir"):
		return

	get_viewport().set_input_as_handled()

	if not Global.tem_caderno:
		_iniciar_missao_caderno()
	else:
		_sentar_na_carteira()


func _iniciar_missao_caderno() -> void:
	Global.missao_caderno_ativa = true
	missao_iniciada.emit()
	if not falas_sem_caderno.is_empty():
		DialogoBox.mostrar_dialogo("", falas_sem_caderno)


func _sentar_na_carteira() -> void:
	GerenciadorDeEventos.jogador_presente_manual = true
	sentou_na_carteira.emit()
	if not falas_com_caderno.is_empty():
		DialogoBox.mostrar_dialogo("", falas_com_caderno)
