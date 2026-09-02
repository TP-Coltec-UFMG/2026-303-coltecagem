extends CanvasLayer
## ============================================================
## HUD
## ------------------------------------------------------------
## HUD fixa do jogo: 4 barras de atributo (Energia, Estresse,
## Social, Desempenho Acadêmico) + relógio com o horário atual +
## feedback de eventos (avisos de aula/prova, bloqueios de ação e
## fim de dia).
##
## Só precisa instanciar essa cena dentro de World.tscn (ou
## qualquer cena de gameplay) — ela se conecta sozinha nos
## Autoloads (EstadoJogador, GerenciadorDeTempo e
## GerenciadorDeEventos) e se atualiza via sinal, sem precisar que
## ninguém "empurre" dados pra ela.
##
## FIM DE JOGO: esta cena NÃO troca de cena sozinha (ainda não
## existe uma cena de resultados no projeto). Ao receber
## GerenciadorDeTempo.dia_terminado, ela se esconde e emite seu
## próprio sinal `fim_de_jogo_hud`. Quem controla o fluxo do
## mundo (ex: World.gd) deve se conectar a esse sinal e decidir
## pra onde ir (get_tree().change_scene_to_file(...) quando a cena
## de resultados existir).
## ============================================================

## Emitido quando o dia letivo termina e a HUD já se escondeu.
## Quem gerencia a cena do mundo deve ouvir isso pra engatilhar a
## transição pra tela de resultados (ainda não existe no projeto).
signal fim_de_jogo_hud

## Duração (em segundos) que o pop-up de aviso de aula/prova fica
## visível na tela.
const DURACAO_AVISO := 4.0

## Duração (em segundos) da animação do texto flutuante de
## bloqueio de ação.
const DURACAO_ALERTA_FLUTUANTE := 1.2

## Traduz o "motivo" técnico de EstadoJogador.acao_bloqueada pra um
## texto amigável. Motivos não mapeados caem no texto genérico.
const MOTIVOS_BLOQUEIO := {
	"estresse_alto": "Exausto!",
}

@onready var barra_energia: ProgressBar = $Control/PainelBarras/Energia/Barra
@onready var barra_estresse: ProgressBar = $Control/PainelBarras/Estresse/Barra
@onready var barra_social: ProgressBar = $Control/PainelBarras/Social/Barra
@onready var barra_desempenho: ProgressBar = $Control/PainelBarras/Desempenho/Barra

@onready var label_horario: Label = $Control/PainelRelogio/LabelHorario
@onready var label_acoes: Label = $Control/PainelRelogio/LabelAcoes

@onready var painel_aviso: PanelContainer = $Control/PainelAviso
@onready var label_aviso: Label = $Control/PainelAviso/LabelAviso
@onready var timer_aviso: Timer = $Control/PainelAviso/TimerAviso

@onready var camada_alertas: Control = $Control/CamadaAlertas


func _ready() -> void:
	# A HUD agora é Autoload (sobrevive à troca de cena entre os
	# mapas). Começa escondida — quem mostra ela e liga o relógio
	# é a primeira cena de gameplay que carregar, via
	# mostrar_e_iniciar_dia() (ver area_base.gd).
	visible = false

	EstadoJogador.atributo_alterado.connect(_on_atributo_alterado)
	EstadoJogador.acao_bloqueada.connect(_on_acao_bloqueada)

	GerenciadorDeTempo.tempo_atualizado.connect(_on_tempo_atualizado)
	GerenciadorDeTempo.acoes_atualizadas.connect(_on_acoes_atualizadas)
	GerenciadorDeTempo.bloco_iniciado.connect(_on_bloco_iniciado)
	GerenciadorDeTempo.dia_terminado.connect(_on_dia_terminado)

	GerenciadorDeEventos.aula_anunciada.connect(_on_aula_anunciada)
	GerenciadorDeEventos.prova_anunciada.connect(_on_prova_anunciada)

	timer_aviso.timeout.connect(_on_timer_aviso_timeout)
	painel_aviso.visible = false

	_atualizar_barras()
	_atualizar_relogio()
	_atualizar_acoes(GerenciadorDeTempo.acoes_restantes)


# ---------------------------------------------------------------
# BARRAS DE ATRIBUTO
# ---------------------------------------------------------------

func _atualizar_barras() -> void:
	barra_energia.value = EstadoJogador.energia
	barra_estresse.value = EstadoJogador.estresse
	barra_social.value = EstadoJogador.social
	barra_desempenho.value = EstadoJogador.desempenho_academico


func _on_atributo_alterado(nome: String, _valor_antigo: int, valor_novo: int) -> void:
	match nome:
		"energia":
			barra_energia.value = valor_novo
		"estresse":
			barra_estresse.value = valor_novo
		"social":
			barra_social.value = valor_novo
		"desempenho_academico":
			barra_desempenho.value = valor_novo


# ---------------------------------------------------------------
# RELÓGIO / AÇÕES
# ---------------------------------------------------------------

func _atualizar_relogio() -> void:
	label_horario.text = GerenciadorDeTempo.horario_formatado()


func _on_tempo_atualizado(_segundos_restantes: float, _progresso: float) -> void:
	_atualizar_relogio()


func _on_bloco_iniciado(_indice: int, _nome_horario: String, _limite_acoes: int) -> void:
	_atualizar_relogio()


func _atualizar_acoes(restantes: int) -> void:
	if restantes == GerenciadorDeTempo.ACOES_ILIMITADAS:
		label_acoes.text = "Ações: livre"
	else:
		label_acoes.text = "Ações: %d" % restantes


func _on_acoes_atualizadas(restantes: int) -> void:
	_atualizar_acoes(restantes)


# ---------------------------------------------------------------
# AVISOS DE AULA / PROVA (pop-up temporário no topo)
# ---------------------------------------------------------------

func _on_aula_anunciada(nome_sala: String, tempo_aviso: float) -> void:
	_mostrar_aviso("Aula na %s em %ds" % [nome_sala, roundi(tempo_aviso)])


func _on_prova_anunciada(nome_sala: String, tempo_aviso: float) -> void:
	_mostrar_aviso("Prova na %s em %ds!" % [nome_sala, roundi(tempo_aviso)])


func _mostrar_aviso(texto: String) -> void:
	label_aviso.text = texto
	painel_aviso.visible = true
	painel_aviso.modulate.a = 1.0
	timer_aviso.start(DURACAO_AVISO)


func _on_timer_aviso_timeout() -> void:
	painel_aviso.visible = false


# ---------------------------------------------------------------
# ALERTAS DE BLOQUEIO (texto flutuante vermelho)
# ---------------------------------------------------------------

func _on_acao_bloqueada(acao: String, motivo: String) -> void:
	var texto: String = MOTIVOS_BLOQUEIO.get(motivo, "Não deu pra %s!" % acao)
	_criar_texto_flutuante(texto)


func _criar_texto_flutuante(texto: String) -> void:
	var label := Label.new()
	label.text = texto
	label.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2))
	label.add_theme_font_size_override("font_size", 18)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	camada_alertas.add_child(label)

	# Centraliza (aprox.) no topo da área da câmada de alertas, com
	# um leve espalhamento horizontal aleatório pra não empilhar
	# textos idênticos exatamente um em cima do outro.
	var largura := camada_alertas.size.x
	var offset_x := randf_range(-40.0, 40.0)
	label.position = Vector2(largura * 0.5 - 60.0 + offset_x, 80.0)
	label.size = Vector2(120.0, 24.0)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 40.0, DURACAO_ALERTA_FLUTUANTE)
	tween.tween_property(label, "modulate:a", 0.0, DURACAO_ALERTA_FLUTUANTE)
	tween.chain().tween_callback(label.queue_free)


# ---------------------------------------------------------------
# FIM DE JOGO
# ---------------------------------------------------------------

func _on_dia_terminado() -> void:
	visible = false
	fim_de_jogo_hud.emit()


# ---------------------------------------------------------------
# CONTROLE DE VISIBILIDADE ENTRE CENAS
# ---------------------------------------------------------------

## Chame isso a partir de qualquer mapa de gameplay assim que ele
## carregar (ver area_base.gd). Mostra a HUD e, se o relógio ainda
## não estiver rodando, começa o dia letivo. Chamar de novo em
## outro mapa (ex: ao trocar de Portaria pra SalaDeAula) só volta
## a mostrar a HUD — não reinicia o dia que já está em andamento.
func mostrar_e_iniciar_dia() -> void:
	visible = true
	if not GerenciadorDeTempo.rodando:
		GerenciadorDeTempo.iniciar_dia()
