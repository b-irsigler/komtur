extends Node

#Utility functions

#returns the given number with separated 1000s
static func number_to_separated(number, delim: String = '.') -> String:
	var string = String(number)
	var mod = string.length() % 3
	var res = ""
	for i in range(0, string.length()):
		if i != 0 && i % 3 == mod:
			res += delim
		res += string[i]
	return res
