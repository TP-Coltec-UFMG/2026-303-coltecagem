extends CanvasLayer
## ============================================================
## MenuDeAcoes
## ------------------------------------------------------------
## Barra fixa com um botão pra cada ação principal do jogo
## (aula, matar aula, estudar, comer, dormir, entrosar). Cada
## clique:
##   1. checa se ainda há "ficha de ação" no bloco atual
##      (GerenciadorDeTempo.pode_agir())
##   2. chama o método correspondente em EstadoJogador
##   3. se a ação realmente rolou, consome a ficha
##      (GerenciadorDeTempo.consumir_acao())
##
## Os botões se desabilitam sozinhos quando não há mais ações no
## bloco, e reaparecem habilitados no próximo bloco.
##
## IMPORTANTE: essas chamadas usam o efeito CHEIO (intensidade
## padrão) de cada ação — é o "clique único" do menu, pensado pra
## ações que não têm (ainda) uma mecânica de presença/tempo real
## no mapa. `aula()`/`matar_aula()` durante um evento de aula real
## são tratadas à parte pelo GerenciadorDeEventos (ver
## autoload/gerenciador_de_eventos.gd) — este menu é mais um
## atalho manual do que a fonte principal dessas duas específicas.
## ============================================================

@onready var btn_aula: Button = $Control/Barra/BtnAula
@onready var btn_matar_aula: Button = $Control/Barra/BtnMatarAula
@onready var btn_estudar: Button = $Control/Barra/BtnEstudar
@onready var btn_comer: Button = $Control/Barra/BtnComer
@onready var btn_dormir: Button = $Control/Barra/BtnDormir
@onready var btn_entrosar: Button = $Control/Barra/BtnEntrosar

@onready var label_aviso: Label = $Control/LabelAviso

var _botoes: Array[Button] = []


func _ready() -> void:
	_botoes = [btn_aula, btn_matar_aula, btn_estudar, btn_comer, btn_dormir, btn_entrosar]

	btn_aula.pressed.connect(func(): _tentar_acao("aula", func(): return EstadoJogador.aula()))
	btn_matar_aula.pressed.connect(func(): _tentar_acao("matar_aula", func(): return EstadoJogador.matar_aula()))
	btn_estudar.pressed.connect(func(): _tentar_acao("estudar", func(): return EstadoJogador.estudar()))
	btn_comer.pressed.connect(func(): _tentar_acao("comer", func(): return EstadoJogador.comer()))
	btn_dormir.pressed.connect(func(): _tentar_acao("dormir", func(): return EstadoJogador.dormir()))
	btn_entrosar.pressed.connect(func(): _tentar_acao("entrosar", func(): return EstadoJogador.entrosar()))

	EstadoJogador.acao_bloqueada.connect(_on_acao_bloqueada)
	GerenciadorDeTempo.acoes_atualizadas.connect(_on_acoes_atualizadas)
	GerenciadorDeTempo.bloco_iniciado.connect(_on_bloco_iniciado)

	label_aviso.text = ""
	_atualizar_botoes()


## Executa a ação (via callable) só se ainda houver ficha
## disponível no bloco atual, e consome a ficha se a ação
## realmente aconteceu (alguns métodos retornam false quando
## bloqueados por estresse alto, ex: aula()/estudar()/entrosar()).
func _tentar_acao(nome: String, chamada: Callable) -> void:
	if not GerenciadorDeTempo.pode_agir():
		_mostrar_aviso("Sem ações disponíveis nesse período!")
		return

	var resultado: bool = chamada.call()
	if resultado:
		GerenciadorDeTempo.consumir_acao()
		_mostrar_aviso("")
	# se resultado for false, o próprio EstadoJogador já emitiu
	# acao_bloqueada, que a gente escuta em _on_acao_bloqueada


func _on_acao_bloqueada(acao: String, motivo: String) -> void:
	var motivo_texto := "estresse muito alto" if motivo == "estresse_alto" else motivo
	_mostrar_aviso("Não deu pra fazer '%s': %s." % [acao, motivo_texto])


func _mostrar_aviso(texto: String) -> void:
	label_aviso.text = texto


func _on_acoes_atualizadas(_restantes: int) -> void:
	_atualizar_botoes()


func _on_bloco_iniciado(_indice: int, _nome_horario: String, _limite_acoes: int) -> void:
	_atualizar_botoes()
	_mostrar_aviso("")


func _atualizar_botoes() -> void:
	var pode := GerenciadorDeTempo.pode_agir()
	for botao in _botoes:
		botao.disabled = not pode
