extends Resource
class_name OpcaoDialogo

## Texto exibido no botão.
@export var texto: String = ""

## Falas mostradas quando o jogador escolhe esta opção (a
## "ramificação" do diálogo). Pode ficar vazio se a opção só
## dispara uma ação e encerra o diálogo na hora.
@export var falas: Array[String] = []

## Nome simbólico de uma ação a executar quando a opção for escolhida.
@export var acao: String = ""

## Submenus: Próximas opções que vão aparecer DEPOIS que estas falas terminarem.
@export var proximas_opcoes: Array[OpcaoDialogo] = []
