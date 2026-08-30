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
## ============================================================

signal interagido
## Emitidos sempre que o jogador entra/sai da área — pensados pra
## outros scripts (ex: o NPC virar pra encarar o jogador) se
## conectarem sem precisar conhecer o interagivel.gd por dentro.
signal jogador_entrou_na_area(jogador: Node2D)
signal jogador_saiu_da_area(jogador: Node2D)

@export var nome_personagem: String = ""
@export var falas: Array[String] = []

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
	jogador_entrou_na_area.emit(body)


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("jogador"):
		return
	_jogador_por_perto = false
	if _label_dica:
		_label_dica.visible = false
	jogador_saiu_da_area.emit(body)


func _unhandled_input(event: InputEvent) -> void:
	if not _jogador_por_perto or falas.is_empty():
		return
	if DialogoBox.esta_ativo():
		return # já tem um diálogo rolando, não abre outro em cima
	if event.is_action_pressed("interagir"):
		interagido.emit()
		DialogoBox.mostrar_dialogo(nome_personagem, falas)
		get_viewport().set_input_as_handled()
