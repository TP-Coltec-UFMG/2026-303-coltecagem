extends Control

signal voltar
signal audio_alterado(valor: float)

@onready var btn_voltar: Button = $BtnVoltar
@onready var slider_audio: HSlider = $SliderAudio


func _ready():
	btn_voltar.pressed.connect(func(): voltar.emit())
	slider_audio.value_changed.connect(func(valor): audio_alterado.emit(valor))


func set_valor(valor: float):
	slider_audio.value = valor
