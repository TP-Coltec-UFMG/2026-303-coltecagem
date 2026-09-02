extends CanvasLayer
## ============================================================
## DialogoBox
## ------------------------------------------------------------
## Caixa de diálogo com efeito de máquina de escrever. O texto
## aparece gradualmente. Pressionar "interagir" (ui_accept ou clique)
## durante a animação faz o texto aparecer inteiro de uma vez.
##
## NOVO: suporte a botões de múltipla escolha (estilo Kindergarten).
## Quando a fala atual tem opções associadas (ver mostrar_opcoes /
## mostrar_dialogo_com_opcoes), ao terminar a última fala a caixa
## troca a dica "▼ continuar" por botões clicáveis. Escolher um
## deles emite `opcao_escolhida` com o OpcaoDialogo selecionado.
##
## Enquanto o diálogo está na tela, o tempo do jogo é PAUSADO
## automaticamente e retomado ao finalizar.
## ============================================================

signal dialogo_finalizado
signal opcao_escolhida(opcao: OpcaoDialogo)

@onready var painel: Panel = $Control/Painel
@onready var label_nome: Label = $Control/Painel/LabelNome
@onready var label_texto: RichTextLabel = $Control/Painel/LabelTexto
@onready var label_dica: Label = $Control/Painel/LabelDica
@onready var opcoes_container: VBoxContainer = $Control/OpcoesContainer

var _falas: Array[String] = []
var _opcoes_atuais: Array[OpcaoDialogo] = []
var _indice_atual: int = 0
var _ativo: bool = false
var _tween: Tween


func _ready() -> void:
	painel.visible = false
	opcoes_container.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not _ativo:
		return

	# Enquanto os botões de opção estão visíveis, quem responde ao
	# clique é o próprio Button (_on_opcao_pressionada). Ignoramos
	# o avanço "normal" pra não pular a escolha sem querer.
	if opcoes_container.visible:
		return

	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
		get_viewport().set_input_as_handled()

		# Se a animação não terminou, o input pula a animação. Se terminou, avança a fala.
		if label_texto.visible_characters < label_texto.get_total_character_count() and label_texto.visible_characters >= 0:
			_pular_animacao()
		else:
			_avancar()


## Uso simples (compatível com o comportamento antigo): mostra as
## falas em sequência e encerra no final.
func mostrar_dialogo(nome_personagem: String, falas: Array[String]) -> void:
	mostrar_dialogo_com_opcoes(nome_personagem, falas, [])


## Mostra as falas normalmente; ao final da ÚLTIMA fala, em vez de
## encerrar, exibe os botões de `opcoes` pro jogador escolher.
## Se `opcoes` estiver vazio, se comporta como mostrar_dialogo().
func mostrar_dialogo_com_opcoes(nome_personagem: String, falas: Array[String], opcoes: Array[OpcaoDialogo]) -> void:
	if falas.is_empty() and opcoes.is_empty():
		return

	# PAUSA O TEMPO AQUI
	GerenciadorDeTempo.pausar_dia()

	_falas = falas
	_opcoes_atuais = opcoes
	_indice_atual = 0
	_ativo = true

	label_nome.text = nome_personagem
	label_nome.visible = nome_personagem != ""
	painel.visible = true
	opcoes_container.visible = false

	if _falas.is_empty():
		_mostrar_opcoes()
	else:
		_mostrar_fala_atual()


func _avancar() -> void:
	_indice_atual += 1
	if _indice_atual >= _falas.size():
		if not _opcoes_atuais.is_empty():
			_mostrar_opcoes()
		else:
			_encerrar()
	else:
		_mostrar_fala_atual()


func _mostrar_fala_atual() -> void:
	label_dica.visible = false # Esconde a seta de avançar enquanto o texto é digitado

	var texto := _falas[_indice_atual]
	label_texto.text = texto
	label_texto.visible_characters = 0

	if _tween and _tween.is_valid():
		_tween.kill()

	_tween = create_tween()

	# Calcula o tempo total baseado na quantidade de letras (0.03 segundos por letra)
	var duracao := texto.length() * 0.03

	_tween.tween_property(label_texto, "visible_characters", texto.length(), duracao)
	_tween.tween_callback(_ao_terminar_animacao)


func _pular_animacao() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()

	label_texto.visible_characters = -1 # O valor -1 força todas as letras a aparecerem na hora
	_ao_terminar_animacao()


func _ao_terminar_animacao() -> void:
	var ultima := _indice_atual == _falas.size() - 1
	if ultima and not _opcoes_atuais.is_empty():
		# Última fala com opções pendentes: já exibe os botões
		# em vez da dica "continuar".
		_mostrar_opcoes()
		return

	label_dica.visible = true
	label_dica.text = "[fim]" if ultima else "▼ continuar"


## Limpa e recria os botões de escolha a partir de _opcoes_atuais.
func _mostrar_opcoes() -> void:
	label_dica.visible = false

	for filho in opcoes_container.get_children():
		filho.queue_free()

	for opcao in _opcoes_atuais:
		# Trava de segurança: pula qualquer item vazio deixado no Inspetor
		if opcao == null:
			continue
			
		var botao := Button.new()
		botao.text = opcao.texto
		botao.pressed.connect(_on_opcao_pressionada.bind(opcao))
		opcoes_container.add_child(botao)

	opcoes_container.visible = true


func _on_opcao_pressionada(opcao: OpcaoDialogo) -> void:
	opcoes_container.visible = false
	opcao_escolhida.emit(opcao)

	# Se a opção tem falas para ler, lê as falas e já prepara as próximas opções
	if not opcao.falas.is_empty():
		_falas = opcao.falas
		_opcoes_atuais = opcao.proximas_opcoes # Pega as opções "filhas"
		_indice_atual = 0
		_mostrar_fala_atual()
		
	# Se a opção não tem fala, mas tem novas opções (ex: submenus diretos)
	elif not opcao.proximas_opcoes.is_empty():
		_falas = []
		_opcoes_atuais = opcao.proximas_opcoes
		_mostrar_opcoes()
		
	else:
		_encerrar()


func _encerrar() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	_ativo = false
	painel.visible = false
	opcoes_container.visible = false

	# RETOMA O TEMPO AQUI
	GerenciadorDeTempo.retomar_dia()

	dialogo_finalizado.emit()


func fechar_imediatamente() -> void:
	if _ativo:
		_encerrar()


func esta_ativo() -> bool:
	return _ativo
