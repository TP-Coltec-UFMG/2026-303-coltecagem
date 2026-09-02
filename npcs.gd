extends CharacterBody2D
## ============================================================
## Script genérico pra NPCs PARADOS (não andam sozinhos).
## Reaproveita a mesma estrutura de Pivot/Body/ArmLeft/ArmRight/
## Head do personagem principal, mas sem input nem movimento —
## só toca a animação "idle" e vira pro lado certo quando o
## jogador chega perto.
##
## Como ligar o "virar pra encarar o jogador":
##   1. Selecione a Area2D de detecção deste NPC (a que tem o
##      script interagivel.gd)
##   2. Aba "Sinais" (do lado de "Cena", no painel de Nós)
##   3. Dê duplo clique em "jogador_entrou_na_area"
##   4. Escolha este nó (o NPC, CharacterBody2D) como alvo e
##      selecione o método "virar_para_jogador"
## Pronto, sem precisar escrever nenhuma linha de código a mais.
## ============================================================

## Quanto o balanço "idle" varia aleatoriamente (efeito vivo)
@export var idle_wobble_amount := 3.0

@onready var anim_player: AnimationPlayer = $Pivot/AnimationPlayer
@onready var pivot: Node2D = $Pivot
@onready var head: Node2D = $Pivot/Body/Head

var _facing := 1  # 1 = direita, -1 = esquerda


func _ready() -> void:
	anim_player.play("idle")


## Vira o NPC pro lado de onde o jogador está. Chame isso quando
## o jogador entrar na área de detecção (ver instruções lá em cima).
func virar_para_jogador(jogador: Node2D) -> void:
	if jogador.global_position.x > global_position.x:
		_facing = -1 # jogador à direita
	else:
		_facing = 1  # jogador à esquerda

	# Inverte o Pivot (não o CharacterBody2D) pra não bagunçar colisão
	pivot.scale.x = _facing


## Chame esta função (ex: via Timer) se quiser adicionar variação
## procedural extra em cima da animação idle, tipo olhar em volta
## de vez em quando.
func apply_random_idle_wobble() -> void:
	if anim_player.current_animation != "idle":
		return
	var tween := create_tween()
	tween.tween_property(
		head, "rotation", randf_range(-0.05, 0.05), 0.6
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _on_area_interacao_jogador_entrou_na_area(jogador: Node2D) -> void:
	pass # Replace with function body.
