extends Node

var first_names: Array[String] = ["Steve", "Sweaty", "Cool", "L33T", "COW", "Bungus", "Loric", "Zerkon", "Baseball", "Northern", "Southern", "Simple", "Complex", "Gray", "Beige", "Zezima", "Red", "Blue", "Green", "Noob", "Woox", "Leeroy", "TheReal", "Mister", "Sir", "Miss", "Lord", "Epic", "Lady"]
var last_names: Array[String] = ["Smith", "Killer", "N00b", "Dude", "Gal", "Fella", "Murderer", "Cherg", "Lion", "Tiger", "Flips", "Tumbles", "Fruit", "Veggie", "Burger", "Jenkins", "Boy", "Girl", "Man", "Lady", "Woman", "Incarnate", "Guy", "Freak", "Lord"]
var post_processing_funcs: Array[Callable] = [codify_name, all_caps, l33tify, numberify]

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
	name = name.replace("o", "0")
	name = name.replace("O", "0")
	return name
	
func numberify(name: String) -> String:
	return name + str(randi_range(0, 1000))
