extends Node


onready var auth = Firebase.Auth

var collection : FirestoreCollection


func _ready():
	auth.connect("auth_request", self, "_on_auth_request")
	collection = Firebase.Firestore.collection("highscore")
	
	authenticate()


func authenticate():
	auth.check_auth_file()


func _on_auth_request(return_code, auth_or_error):
	if typeof(return_code) == 4:
		print("Error message: ", return_code)
	elif typeof(return_code) == 2:
		if return_code == 1:
			print("Authenticated with existing auth file.")
			auth.save_auth(auth_or_error)
		else:
			print("Make anonymous login.")
			auth.login_anonymous()
	else:
		print("Severe error. Call your backend specialiests 0190666666!")
		

func add_score(name):
	var score = Global.game_score
	var add_task : FirestoreTask = collection.add("", {'name': name, 'score' : score, 'time_left': Global.game_time_left, "first_100_beeches": Global.first_100_beeches})
	
	return add_task
	

func get_score_list():
		# create a query
	var query : FirestoreQuery = FirestoreQuery.new()

	# FROM a collection
	query.from("highscore")	

	# ORDER BY points, from the user with the best score to the latest
	query.order_by("score", FirestoreQuery.DIRECTION.DESCENDING)

	# LIMIT to the first 10 users
	query.limit(5)

	# Issue the query
	var query_task : FirestoreTask = Firebase.Firestore.query(query)

	# Yield on the request to get a result
	var result = yield(query_task, "result_query")
	
	return result

