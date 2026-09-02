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

@export_group("Roteiro Inicial (Cutscene)")
## Fala do Professor mostrada na PRIMEIRA interação do jogador com
## a carteira no dia — o roteiro obrigatório da abertura da aula.
@export var falas_professor_bom_dia: Array[String] = [
	"Bom dia, turma! Peguem o material e comecem as atividades.",
]

## true até a primeira interação do dia acontecer. Depois disso,
## a carteira volta a funcionar no fluxo normal (com/sem caderno).
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
	if DialogoBox.esta_ativo():
		return
	if not event.is_action_pressed("interagir"):
		return

	get_viewport().set_input_as_handled()

	# ROTEIRO OBRIGATÓRIO: na primeira vez que o jogador interage
	# com a carteira no dia, dispara a cutscene do Professor em vez
	# da lógica normal. Nenhuma ficha do GerenciadorDeTempo é
	# consumida aqui (nem _iniciar_missao_caderno nem
	# _sentar_na_carteira chamam consumir_acao), deixando o
	# jogador livre pra escolher onde gastar as fichas depois.
	if _primeira_interacao_do_dia:
		_primeira_interacao_do_dia = false
		_iniciar_cutscene_bom_dia()
		return

	if not Global.tem_caderno:
		_iniciar_missao_caderno()
	else:
		_sentar_na_carteira()


## Mostra o diálogo do Professor mandando começar as atividades e,
## assim que ele terminar, encadeia IMEDIATAMENTE o diálogo interno
## do jogador percebendo que está sem o caderno (o que já liga
## Global.missao_caderno_ativa via _iniciar_missao_caderno).
func _iniciar_cutscene_bom_dia() -> void:
	if falas_professor_bom_dia.is_empty():
		_continuar_apos_bom_dia()
		return
	DialogoBox.dialogo_finalizado.connect(_continuar_apos_bom_dia, CONNECT_ONE_SHOT)
	DialogoBox.mostrar_dialogo("Professor", falas_professor_bom_dia)


func _continuar_apos_bom_dia() -> void:
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
