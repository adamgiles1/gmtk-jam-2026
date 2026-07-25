extends Node

var first_names: Array[String] = ["Steve", "Sweaty", "Cool", "L33T", "COW", "Bungus"]
var last_names: Array[String] = ["Smith", "Killer", "N00b", "Dude", "Gal", "Fella", "Murderer"]
var post_processing_funcs: Array[Callable] = [codify_name, all_caps, l33tify]

func get_random_name() -> String:
	var name = first_names.pick_random() + "_" + last_names.pick_random()
	
	if randf() < .25:
		name = post_processing_funcs.pick_random().call(name)
	return name

func codify_name(name: String) -> String:
	return "XXX" + name + "XXX"

func all_caps(name: String) -> String:
	return name.to_upper()

func l33tify(name: String) -> String:
	name = name.replace("e", "3")
	name = name.replace("E", "3")
	name = name.replace("i", "1")
	name = name.replace("I", "1")
	return name
