extends Node

signal updateUI(stat,attribute,value)

var stats = {
	"base":1,
	"painLevel":0,
	"lightLevel":0,
	"volumeLevel":0
}

func update(stat:String,attribute:String,value,modifier:String):
	if stats.has(stat):
		match modifier:
			"add":
				stats[stat] += value
			"subtract":
				stats[stat] -= value
			"set":
				stats[stat] = value
		emit_signal("updateUI",stat,attribute,stats[stat])

func evaluatePain():
	var total:int = 0
	total += stats["base"]
	
	if stats["lightLevel"] >= 8 and stats["lightLevel"] <= 16:
		total += 1
	
	return total
