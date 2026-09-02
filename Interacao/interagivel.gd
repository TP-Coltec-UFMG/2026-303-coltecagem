extends Area2D
## ============================================================
## Interagivel
## ------------------------------------------------------------
## Componente reutilizável: anexe este script numa Area2D (com um
## CollisionShape2D cobrindo a área de interação) dentro da cena
## de QUALQUER NPC ou objeto interativo. Quando o jogador entra na
## área e aperta E ("interagir"), abre a DialogoBox com as falas
## configuradas.
##
## Pré-requisito: o personagem controlável precisa estar no grupo
## "jogador" (Node > Grupos > adicionar "jogador"), senão a área
## não reconhece quem entrou como sendo o jogador.
##
## Como usar (no editor, sem precisar programar):
##   1. Area2D (com este script) + CollisionShape2D como filhos
##      da cena do NPC/objeto
##   2. No Inspetor, preencher "Nome Personagem" e a lista "Falas"
##   3. (opcional) um Label chamado "LabelDica" como filho, pra
##      mostrar "aperte E" — o script mostra/esconde ele sozinho
##      se existir
##
## MISSÃO DO CADERNO: marque `entrega_caderno = true` num NPC pra
## que ele devolva o caderno ao jogador (Global.tem_caderno = true)
## na primeira interação em que Global.missao_caderno_ativa
## estiver ligada. Falas de `falas_entrega_caderno`, se definidas,
## substituem `falas` só nessa interação específica.
##
## ENTROSAR: marque `permite_entrosar = true` num NPC "social" pra
## que, ao final do diálogo, o jogo tente EstadoJogador.entrosar()
## e consuma uma ficha de ação do GerenciadorDeTempo. Se não houver
## ficha disponível ou a ação for bloqueada (estresse alto), nada
## é consumido e o motivo é emitido nos sinais de sempre
## (EstadoJogador.acao_bloqueada).
## ============================================================

signal interagido
## Emitidos sempre que o jogador entra/sai da área — pensados pra
## outros scripts (ex: o NPC virar pra encarar o jogador) se
## conectarem sem precisar conhecer o interagivel.gd por dentro.
signal jogador_entrou_na_area(jogador: Node2D)
signal jogador_saiu_da_area(jogador: Node2D)

## Emitido quando este Interagivel entrega o caderno ao jogador.
signal caderno_entregue

@export var nome_personagem: String = ""
@export var falas: Array[String] = []

@export_group("Missão do Caderno")
## Se true, este Interagivel devolve o caderno ao jogador quando
## a missão estiver ativa e o jogador ainda não tiver o caderno.
@export var entrega_caderno: bool = false
## Falas específicas da entrega (opcional). Se vazio, usa `falas`.
@export var falas_entrega_caderno: Array[String] = []

@export_group("Socialização")
## Se true, ao terminar o diálogo o jogo tenta
## EstadoJogador.entrosar(), consumindo uma ficha de ação do
## GerenciadorDeTempo (se disponível).
@export var permite_entrosar: bool = false

var _jogador_por_perto: bool = false
var _label_dica: Label
var _entregando_caderno_agora: bool = false

## true só enquanto o diálogo em tela foi aberto POR ESTE
## Interagivel. Necessário porque DialogoBox é um Autoload único:
## o sinal dialogo_finalizado chega pra TODOS os Interagivel da
## cena, então sem essa flag qualquer NPC com permite_entrosar
## reagiria ao diálogo de outro NPC.
var _dialogo_aberto_por_mim: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	DialogoBox.dialogo_finalizado.connect(_on_dialogo_finalizado)

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

	var deve_entregar_caderno := (
		entrega_caderno
		and Global.missao_caderno_ativa
		and not Global.tem_caderno
	)

	var falas_para_mostrar := falas
	if deve_entregar_caderno and not falas_entrega_caderno.is_empty():
		falas_para_mostrar = falas_entrega_caderno

	if falas_para_mostrar.is_empty():
		return

	_entregando_caderno_agora = deve_entregar_caderno
	_dialogo_aberto_por_mim = true

	interagido.emit()
	DialogoBox.mostrar_dialogo(nome_personagem, falas_para_mostrar)
	get_viewport().set_input_as_handled()


## Chamado quando QUALQUER diálogo termina (a DialogoBox é um
## Autoload único, então esse sinal chega pra todos os Interagivel
## da cena). Só reage se foi ESTE Interagivel quem abriu o diálogo
## que acabou de fechar (ver _dialogo_aberto_por_mim).
func _on_dialogo_finalizado() -> void:
	if not _dialogo_aberto_por_mim:
		return
	_dialogo_aberto_por_mim = false

	if _entregando_caderno_agora:
		_entregando_caderno_agora = false
		_entregar_caderno()

	if permite_entrosar:
		_tentar_entrosar()


func _entregar_caderno() -> void:
	Global.tem_caderno = true
	Global.missao_caderno_ativa = false
	caderno_entregue.emit()


func _tentar_entrosar() -> void:
	if not GerenciadorDeTempo.pode_agir():
		return
	if EstadoJogador.entrosar():
		GerenciadorDeTempo.consumir_acao()
	# Se entrosar() retornar false, o próprio EstadoJogador já
	# emitiu acao_bloqueada — a HUD escuta isso e mostra o aviso.
