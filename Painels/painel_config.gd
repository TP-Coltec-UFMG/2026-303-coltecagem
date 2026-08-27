extends Control

## Painel de configurações: menu com Áudio / Acessibilidade / Créditos / Voltar.
## Repassa (re-emite) os sinais dos sub-painéis para quem instanciar esta cena
## (o menu principal), que é quem sabe aplicar brilho/daltonismo/volume de fato.

signal voltar
signal brilho_alterado(valor: float)
signal daltonismo_alterado(modo: int)
signal audio_alterado(valor: float)

@onready var menu_config: VBoxContainer = $VBoxContainer

@onready var btn_voltar: Button = $VBoxContainer/BtnVoltar
@onready var btn_acessibilidade: Button = $VBoxContainer/BtnAcessibilidade
@onready var btn_audio: Button = $VBoxContainer/BtnAudio
@onready var btn_creditos: Button = $VBoxContainer/BtnCreditos

@onready var painel_brilho: Control = $PainelBrilho
@onready var painel_audio: Control = $PainelAudio
@onready var painel_creditos: Control = $PainelCreditos


func _ready():
	btn_voltar.pressed.connect(func(): voltar.emit())
	btn_acessibilidade.pressed.connect(abrir_brilho)
	btn_audio.pressed.connect(abrir_audio)
	btn_creditos.pressed.connect(abrir_creditos)

	painel_brilho.voltar.connect(fechar_sub_painel)
	painel_brilho.brilho_alterado.connect(func(v): brilho_alterado.emit(v))
	painel_brilho.daltonismo_alterado.connect(func(m): daltonismo_alterado.emit(m))

	painel_audio.voltar.connect(fechar_sub_painel)
	painel_audio.audio_alterado.connect(func(v): audio_alterado.emit(v))

	painel_creditos.voltar.connect(fechar_sub_painel)

	painel_brilho.visible = false
	painel_audio.visible = false
	painel_creditos.visible = false


func abrir_brilho():
	menu_config.visible = false
	painel_brilho.visible = true


func abrir_audio():
	menu_config.visible = false
	painel_audio.visible = true


func abrir_creditos():
	menu_config.visible = false
	painel_creditos.visible = true


func fechar_sub_painel():
	painel_brilho.visible = false
	painel_audio.visible = false
	painel_creditos.visible = false
	menu_config.visible = true


func set_valor_brilho(valor: float):
	painel_brilho.set_valor_brilho(valor)


func set_valor_audio(valor: float):
	painel_audio.set_valor(valor)
