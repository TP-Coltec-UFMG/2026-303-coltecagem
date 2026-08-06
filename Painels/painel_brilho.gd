extends Control

signal voltar
signal brilho_alterado(valor: float)
signal daltonismo_alterado(modo: int)

@onready var btn_voltar: Button = $BtnVoltar
@onready var slider_brilho: HSlider = $SliderBrilho

@onready var btn_normal: Button = $DaltonismoVBox/BtnNormal
@onready var btn_protanopia: Button = $DaltonismoVBox/BtnProtanopia
@onready var btn_deuteranopia: Button = $DaltonismoVBox/BtnDeuteranopia
@onready var btn_tritanopia: Button = $DaltonismoVBox/BtnTritanopia
@onready var btn_acromatopsia: Button = $DaltonismoVBox/BtnAcromatopsia


func _ready():
	btn_voltar.pressed.connect(func(): voltar.emit())
	slider_brilho.value_changed.connect(func(valor): brilho_alterado.emit(valor))

	btn_normal.pressed.connect(func(): daltonismo_alterado.emit(0))
	btn_protanopia.pressed.connect(func(): daltonismo_alterado.emit(1))
	btn_deuteranopia.pressed.connect(func(): daltonismo_alterado.emit(2))
	btn_tritanopia.pressed.connect(func(): daltonismo_alterado.emit(3))
	btn_acromatopsia.pressed.connect(func(): daltonismo_alterado.emit(4))


func set_valor_brilho(valor: float):
	slider_brilho.value = valor
