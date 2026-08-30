extends Control
## ============================================================
## Cena de TESTE da HUD + Menu de Ações.
## ------------------------------------------------------------
## Instancia a HUD e o MenuDeAcoes de verdade (não cópias) e só
## inicia o dia — o resto é 100% os componentes reais, então
## testar aqui já vale como teste de integração dos dois.
## ============================================================

func _ready() -> void:
	GerenciadorDeTempo.iniciar_dia()
