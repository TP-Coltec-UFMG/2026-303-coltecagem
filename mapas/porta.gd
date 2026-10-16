extends Area2D
## Porta/saída de um mapa. Quando o jogador entra nessa área,
## troca de cena e avisa o próximo mapa em qual Marker2D o
## personagem deve aparecer.

## Caminho da cena de destino, ex: "res://scenes/mapas/hall.tscn"
@export_file("*.tscn") var cena_destino: String

## Nome do Marker2D (dentro da cena de destino) onde o personagem
## deve surgir. Precisa bater exatamente com o nome do node lá.
@export var ponto_entrada_destino: String

## Depois que um mapa carrega, as portas ignoram o jogador por
## este tempo (ms). Evita teleporte em cadeia quando o ponto de
## chegada fica encostado em outro portal.
const IGNORAR_APOS_TROCA_MS := 600


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("jogador"):
		return
	if Time.get_ticks_msec() - Global.ultima_troca_de_mapa_ms < IGNORAR_APOS_TROCA_MS:
		return
	print("Porta ", name, " -> ", cena_destino, " (ponto ", ponto_entrada_destino, ")")
	Global.proximo_ponto_entrada = ponto_entrada_destino
	get_tree().change_scene_to_file.call_deferred(cena_destino)
