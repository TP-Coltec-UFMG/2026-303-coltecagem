extends Area2D

signal interagido
signal jogador_entrou_na_area(jogador: Node2D)
signal jogador_saiu_da_area(jogador: Node2D)

@export var nome_personagem: String = ""
@export var falas: Array[String] = []

@export_group("Escolhas de Diálogo")
@export var opcoes: Array[OpcaoDialogo] = []

@export_group("Task (opcional)")
## Cena do minigame que essa interação pode abrir. Preencha isso
## e crie uma OpcaoDialogo com acao = "iniciar_minigame" (ex: a
## resposta "Sim" de um "Você pode me ajudar com isso?") pra
## disparar o minigame quando o jogador escolher essa opção.
@export var cena_do_minigame: PackedScene
## Mesmo formato de recompensas usado pelo MinigameTaskArea:
## nome_do_atributo -> quantidade (ex: "desempenho_academico": 8).
@export var recompensas_minigame: Dictionary = {
	"desempenho_academico": 1,
	"estresse": -3,
	"social": +7
}


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
	if not _opcao_pertence_a_mim(opcao, opcoes):
		return

	match opcao.acao:
		"iniciar_minigame":
			# Não chama na hora: esse sinal dispara NO MEIO da
			# lógica do próprio DialogoBox fechando/avançando a
			# caixa de diálogo. Trocar de cena aqui, síncrono,
			# arrisca derrubar coisas que o DialogoBox ainda vai
			# tentar usar em seguida (mesmo tipo de problema de
			# ordem que já resolvemos no MinigameTaskArea). Um
			# call_deferred garante que isso só roda depois que o
			# diálogo terminar de se resolver sozinho.
			call_deferred("_iniciar_minigame_da_task")
		# Se no futuro você criar outras ações (ex: "entregar_caderno"),
		# adicione novos casos aqui.


## Busca `opcao` em `lista`, incluindo dentro de proximas_opcoes
## (submenus), pra confirmar que a escolha realmente pertence a
## este Interagivel antes de agir sobre ela.
func _opcao_pertence_a_mim(opcao: OpcaoDialogo, lista: Array[OpcaoDialogo]) -> bool:
	for item in lista:
		if item == null:
			continue
		if item == opcao:
			return true
		if not item.proximas_opcoes.is_empty() and _opcao_pertence_a_mim(opcao, item.proximas_opcoes):
			return true
	return false


func _iniciar_minigame_da_task() -> void:
	if cena_do_minigame == null:
		push_warning("Interagivel '%s': a opção escolhida tem acao = \"iniciar_minigame\", mas 'Cena Do Minigame' não foi preenchida no Inspetor." % nome_personagem)
		return
	GerenciadorDeMinigames.iniciar_minigame(cena_do_minigame.resource_path, recompensas_minigame)
