extends Control

func _ready() -> void:
	global.connect("updateUI",self.updateUI)
	global.update("painLevel","text",global.evaluatePain(),"set")

func updateUI(stat:String,attribute,value):
	for property in find_child(stat).get_property_list():
		if property.name == attribute:
			find_child(stat).set(attribute,value)
