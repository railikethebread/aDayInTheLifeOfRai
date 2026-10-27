extends VisibleOnScreenEnabler3D

var modifier:float = 0.5
var base:float = modifier

func _on_screen_entered() -> void:
	global.update("lightLevel","text",get_parent().light_energy*modifier,"add")
	global.update("painLevel","text",global.evaluatePain(),"set")

func _on_screen_exited() -> void:
	global.update("lightLevel","text",get_parent().light_energy*base,"subtract")
	global.update("painLevel","text",global.evaluatePain(),"set")


func _on_modify_screen_entered() -> void:
	global.update("lightLevel","text",get_parent().light_energy*modifier,"add")
	global.update("painLevel","text",global.evaluatePain(),"set")
	modifier = 1


func _on_modify_screen_exited() -> void:
	global.update("lightLevel","text",get_parent().light_energy*base,"subtract")
	global.update("painLevel","text",global.evaluatePain(),"set")
	modifier = 0.5
