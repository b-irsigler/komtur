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
	if return_code == 1:
		print("Authenticated with existing auth file.")
		auth.save_auth(auth_or_error)
	else:
		print("Make anonymous login.")
		auth.login_anonymous()
		

func add_score(name, time_left):
	var add_task : FirestoreTask = collection.add("", {'name': name, 'time_left': time_left})
	print(name, time_left)
	

func get_score_list():
		# create a query
	var query : FirestoreQuery = FirestoreQuery.new()

	# FROM a collection
	query.from("highscore")	

	# ORDER BY points, from the user with the best score to the latest
	query.order_by("time_left", FirestoreQuery.DIRECTION.DESCENDING)

	# LIMIT to the first 10 users
	query.limit(10)

	# Issue the query
	var query_task : FirestoreTask = Firebase.Firestore.query(query)

	# Yield on the request to get a result
	var result = yield(query_task, "result_query")
	
	return result

