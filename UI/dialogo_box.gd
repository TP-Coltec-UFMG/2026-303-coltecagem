extends CanvasLayer
## ============================================================
## DialogoBox
## ------------------------------------------------------------
## Caixa de diálogo reutilizável: mostra o nome de quem fala + o
## texto, uma fala de cada vez, avançando com clique ou
## Espaço/Enter (ação embutida "ui_accept").
##
## Uso, de qualquer script:
##
##     DialogoBox.mostrar_dialogo("Honda", [
##         "Ô, tudo certo?",
##         "Já foi na cantina hoje?",
##     ])
##     await DialogoBox.dialogo_finalizado
##
## Enquanto o diálogo está na tela, o jogo continua rodando por
## baixo (o GerenciadorDeTempo NÃO pausa sozinho) — se quiserem
## pausar o tempo durante conversas, chamem
## GerenciadorDeTempo.pausar_dia() antes de mostrar_dialogo() e
## retomar_dia() depois do dialogo_finalizado.
## ============================================================

signal dialogo_finalizado

@onready var painel: Panel = $Control/Painel
@onready var label_nome: Label = $Control/Painel/LabelNome
@onready var label_texto: RichTextLabel = $Control/Painel/LabelTexto
@onready var label_dica: Label = $Control/Painel/LabelDica

var _falas: Array[String] = []
var _indice_atual: int = 0
var _ativo: bool = false
var _tween: Tween 


func _ready() -> void:
	painel.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not _ativo:
		return
		
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
		get_viewport().set_input_as_handled()
		
		# Se a animação não terminou, o input pula a animação. Se terminou, avança a fala.
		if label_texto.visible_characters < label_texto.get_total_character_count() and label_texto.visible_characters >= 0:
			_pular_animacao()
		else:
			_avancar()


func mostrar_dialogo(nome_personagem: String, falas: Array[String]) -> void:
	if falas.is_empty():
		return

	_falas = falas
	_indice_atual = 0
	_ativo = true

	label_nome.text = nome_personagem
	label_nome.visible = nome_personagem != ""
	painel.visible = true

	_mostrar_fala_atual()


func _avancar() -> void:
	_indice_atual += 1
	if _indice_atual >= _falas.size():
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
	label_dica.visible = true
	var ultima := _indice_atual == _falas.size() - 1
	label_dica.text = "[fim]" if ultima else "▼ continuar"


func _encerrar() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	_ativo = false
	painel.visible = false
	dialogo_finalizado.emit()


func fechar_imediatamente() -> void:
	if _ativo:
		_encerrar()


func esta_ativo() -> bool:
	return _ativo