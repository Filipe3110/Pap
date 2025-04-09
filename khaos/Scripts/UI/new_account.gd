extends Control

var COLLECTION_ID = "khaos_stats"

func _ready():
	Firebase.Auth.connect("signup_succeeded", Callable(self, "on_signup_succeeded"))
	Firebase.Auth.connect("signup_failed", Callable(self, "on_signup_failed"))

func _on_signup_button_pressed():
	var email = %EmailLineEdit.text
	var password = %PasswordLineEdit.text
	Firebase.Auth.signup_with_email_and_password(email, password)
	%StateLabel.text = "Signing up"
	

func on_signup_succeeded(auth):
	print("Sign-up succeeded: ", auth)
	%StateLabel.text = "Sign up success!"
	Firebase.Auth.save_auth(auth)
	save_data()
	get_tree().change_scene_to_file("res://Cenas/UI/main.tscn")

func save_data():
	var auth = Firebase.Auth.auth
	if auth and auth.localid:
		var collection: FirestoreCollection = Firebase.Firestore.collection(COLLECTION_ID)
		var username = %UsernameEdit.text
		var email = %EmailLineEdit.text
		var password = %PasswordLineEdit.text
		var data: Dictionary = {
			"username": username,
			"email": email,
			"password": password,
		}
		var task: FirestoreTask = collection.update(auth.localid, data)
		task.connect("task_finished", Callable( self, "_on_task_finished"))
	else:
		print("Error: Auth object is invalid or missing localid.")

func _on_task_finished(task_result):
	if task_result.error:
		print("Firestore update failed: ", task_result.error)
	else:
		print("Firestore update succeeded!")

func on_signup_failed(error_code, message):
	print("Error code: ", error_code)
	print("Error message: ", message)
	%StateLabel.text = "Sign up failed. Error: %s (Code: %s)" % [message, error_code]
func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/UI/Authentication.tscn")
