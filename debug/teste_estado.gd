extends Control
## ============================================================
## Cena de TESTE do EstadoJogador.
## ------------------------------------------------------------
## Não é uma tela final do jogo — é só um painel simples com um
## botão pra cada ação, feito pra você conseguir apertar F6 nesta
## cena (ou rodar ela como principal) e ver os atributos mudando
## em tempo real, sem precisar mexer em nada visual ainda.
##
## Depois que tiver confiança que a lógica está funcionando,
## você troca esses botões pela UI de verdade do jogo (que vai
## chamar as mesmas funções: EstadoJogador.aula(), etc).
## ============================================================

@onready var label_status: RichTextLabel = $Margem/VBox/LabelStatus
@onready var label_log: RichTextLabel = $Margem/VBox/LabelLog

@onready var btn_aula: Button = $Margem/VBox/Botoes/BtnAula
@onready var btn_matar_aula: Button = $Margem/VBox/Botoes/BtnMatarAula
@onready var btn_estudar: Button = $Margem/VBox/Botoes/BtnEstudar
@onready var btn_comer: Button = $Margem/VBox/Botoes/BtnComer
@onready var btn_dormir: Button = $Margem/VBox/Botoes/BtnDormir
@onready var btn_entrosar: Button = $Margem/VBox/Botoes/BtnEntrosar
@onready var btn_prova: Button = $Margem/VBox/Botoes2/BtnProva
@onready var btn_final: Button = $Margem/VBox/Botoes2/BtnFinal
@onready var btn_reiniciar: Button = $Margem/VBox/Botoes2/BtnReiniciar


func _ready() -> void:
	btn_aula.pressed.connect(func(): _executar("aula", EstadoJogador.aula()))
	btn_matar_aula.pressed.connect(func(): _executar("matar_aula", EstadoJogador.matar_aula()))
	btn_estudar.pressed.connect(func(): _executar("estudar", EstadoJogador.estudar()))
	btn_comer.pressed.connect(func(): _executar("comer", EstadoJogador.comer()))
	btn_dormir.pressed.connect(func(): _executar("dormir", EstadoJogador.dormir()))
	btn_entrosar.pressed.connect(func(): _executar("entrosar", EstadoJogador.entrosar()))

	btn_prova.pressed.connect(_on_prova)
	btn_final.pressed.connect(_on_ver_final)
	btn_reiniciar.pressed.connect(_on_reiniciar)

	EstadoJogador.acao_bloqueada.connect(_on_acao_bloqueada)

	_atualizar_status()
	_log("Painel de teste pronto. Aperte os botões pra testar o EstadoJogador.")


func _executar(nome_acao: String, resultado: bool) -> void:
	if resultado:
		_log("Ação executada: %s" % nome_acao)
	_atualizar_status()


func _on_acao_bloqueada(acao: String, motivo: String) -> void:
	_log("[color=orange]Ação '%s' bloqueada (%s)[/color]" % [acao, motivo])


func _on_prova() -> void:
	var nota := EstadoJogador.fazer_prova()
	_log("Prova feita! Nota: %d" % nota)
	_atualizar_status()


func _on_ver_final() -> void:
	var final := EstadoJogador.verificar_final()
	_log("[b]Final atingido: %s[/b]" % EstadoJogador.NOME_FINAL[final])


func _on_reiniciar() -> void:
	EstadoJogador.reiniciar()
	_log("Estado reiniciado.")
	_atualizar_status()


func _atualizar_status() -> void:
	label_status.text = (
		"[b]Energia:[/b] %d\n" +
		"[b]Estresse:[/b] %d\n" +
		"[b]Social:[/b] %d\n" +
		"[b]Desempenho:[/b] %d\n" +
		"[b]Dias passados:[/b] %d\n" +
		"[b]Última nota:[/b] %s"
	) % [
		EstadoJogador.energia,
		EstadoJogador.estresse,
		EstadoJogador.social,
		EstadoJogador.desempenho_academico,
		EstadoJogador.dias_passados,
		"—" if EstadoJogador.ultima_nota < 0 else str(EstadoJogador.ultima_nota),
	]


func _log(texto: String) -> void:
	label_log.text += texto + "\n"
