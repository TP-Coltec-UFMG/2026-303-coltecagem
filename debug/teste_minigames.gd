extends Control
## Cena de teste: abre qualquer minigame sem precisar andar pelo mapa.
## Rode com F6. Remover antes de entregar o jogo (task 5.x).

const JOGOS := [
	["Ragdoll", "res://minigames/ragdoll/scenes/ragdoll.tscn", "teclado"],
	["Saw", "res://minigames/saw/scenes/saw_minigame.tscn", "teclado"],
	["Baseball", "res://minigames/baseball/scenes/baseball_minigame.tscn", "teclado"],
	["Platformer", "res://minigames/platformer/scenes/platformer_minigame.tscn", "teclado"],
	["Za", "res://minigames/za/scenes/za_minigame.tscn", "teclado"],
	["Big Rigs", "res://minigames/big_rigs/big_rig_minigame.tscn", "teclado"],
	["Wind", "res://minigames/wind/scenes/wind_minigame.tscn", "teclado"],
	["Shooter", "res://minigames/shooter/scenes/shooter_frame.tscn", "teclado"],
	["Anchovy Quest", "res://minigames/anchovy_quest/scenes/anchovy_game.tscn", "teclado"],
	["Dodge", "res://minigames/dodge/scenes/dodge.tscn", "teclado"],
	["Pants", "res://minigames/pants/pants_minigame.tscn", "teclado"],
	["Pitfall", "res://minigames/pitfall/pitfall_minigame_frame.tscn", "teclado"],
	["Dance", "res://minigames/dance/scenes/dance_minigame.tscn", "teclado"],
	["Goalie", "res://minigames/goalie/goalie_minigame.tscn", "teclado"],
	["Jump", "res://minigames/jump/jump_minigame.tscn", "teclado"],
	["Bother", "res://minigames/bother/bother_minigame.tscn", "teclado"],
	["Ball Tribute", "res://minigames/ball_tribute/scenes/ball_tribute.tscn", "teclado"],
	["Aperte Tudo", "res://minigames/aperte_tudo/aperte_tudo.tscn", "mouse"],
	["Pegar Bonecos", "res://minigames/pegar_bonecos/pegar_bonecos.tscn", "teclado"],
	["Anagogic Clock", "res://minigames/anagogic_clock_minigame.tscn", "mouse"],
	["Ballkeep", "res://minigames/ballkeep_minigame.tscn", "teclado"],
	["Buzzing Lunch", "res://minigames/buzzing_lunch_minigame.tscn", "teclado"],
	["Carnival Shootout", "res://minigames/carnival_shootout_minigame.tscn", "mouse"],
	["Countin' Candy", "res://minigames/countin_candy_minigame.tscn", "mouse"],
	["Digital Warp", "res://minigames/digital_warp_minigame.tscn", "teclado"],
	["File Organizer", "res://minigames/file_organizer_minigame.tscn", "mouse"],
	["Fliperama", "res://minigames/fliperama_minigame.tscn", "teclado"],
	["Gadget Inspection", "res://minigames/gadget_inspection_minigame.tscn", "teclado"],
	["Garden Thyme", "res://minigames/garden_thyme_minigame.tscn", "teclado"],
	["Gem Enchantment", "res://minigames/gem_enchantment_minigame.tscn", "mouse"],
	["Gravity Shift", "res://minigames/gravity_shift_minigame.tscn", "teclado"],
	["Hop for Love", "res://minigames/hop_for_love_minigame.tscn", "teclado"],
	["Input Flow", "res://minigames/input_flow_minigame.tscn", "teclado"],
	["Neo Highway", "res://minigames/neo_highway_minigame.tscn", "teclado"],
	["Papercuts", "res://minigames/papercuts_minigame.tscn", "mouse"],
	["Punchbag Wallop", "res://minigames/punchbag_wallop_minigame.tscn", "teclado"],
	["Rope Hop", "res://minigames/rope_hop_minigame.tscn", "teclado"],
	["Shuffle Dance", "res://minigames/shuffle_dance_minigame.tscn", "mouse"],
	["Suitcase-by-Case", "res://minigames/suitcase_by_case_minigame.tscn", "mouse"],
	["Swatter Swindler", "res://minigames/swatter_swindler_minigame.tscn", "teclado"],
	["Thing Factory", "res://minigames/thing_factory_minigame.tscn", "mouse"],
	["Void Avoider", "res://minigames/void_avoider_minigame.tscn", "teclado"],
	["Woozy Chomper", "res://minigames/woozy_chomper_minigame.tscn", "teclado"],
]


func _ready() -> void:
	print("teste_minigames: _ready rodou, %d jogos" % JOGOS.size())

	var fundo := ColorRect.new()
	fundo.color = Color(0.12, 0.13, 0.16)
	add_child(fundo)
	fundo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var raiz := VBoxContainer.new()
	add_child(raiz)
	raiz.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var titulo := Label.new()
	titulo.text = "TESTE DE MINIGAMES - clique num jogo"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	raiz.add_child(titulo)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	raiz.add_child(scroll)

	var grade := GridContainer.new()
	grade.columns = 3
	grade.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(grade)

	for i in JOGOS.size():
		var j: Array = JOGOS[i]
		var b := Button.new()
		b.text = "%d. %s (%s)" % [i + 1, j[0], j[2]]
		b.custom_minimum_size = Vector2(300, 44)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(_abrir.bind(j[1]))
		grade.add_child(b)


func _abrir(caminho: String) -> void:
	GerenciadorDeMinigames.iniciar_minigame(caminho, {})
