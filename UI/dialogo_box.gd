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


func _ready() -> void:
	painel.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not _ativo:
		return
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
		_avancar()
		get_viewport().set_input_as_handled()


## Começa um diálogo novo. `nome_personagem` pode ser "" pra
## diálogos sem nome (ex: narração/pensamento do jogador).
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
	label_texto.text = _falas[_indice_atual]
	var ultima := _indice_atual == _falas.size() - 1
	label_dica.text = "[fim]" if ultima else "▼ continuar"


func _encerrar() -> void:
	_ativo = false
	painel.visible = false
	dialogo_finalizado.emit()


## Fecha o diálogo imediatamente, mesmo no meio de uma fala
## (ex: se um evento urgente precisar interromper).
func fechar_imediatamente() -> void:
	if _ativo:
		_encerrar()


func esta_ativo() -> bool:
	return _ativo
