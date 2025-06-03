extends Control

var COLLECTION_ID = "khaos_stats"
@onready var transição = $"Transição/AnimationPlayer"

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
	transição.play("Trasição1")
	await transição.animation_finished
	Global.from_authentication = true
	get_tree().change_scene_to_file("res://Cenas/UI/main.tscn")

func save_data():
	var auth = Firebase.Auth.auth
	if auth and auth.localid:
		var collection: FirestoreCollection = Firebase.Firestore.collection(COLLECTION_ID)
		var username = %UsernameEdit.text
		var email = %EmailLineEdit.text
		var data: Dictionary = {
			"username": username,
			"email": email,
		}
		var task: FirestoreTask = collection.add(auth.localid, data)  # Usar add em vez de update para criar o documento
		task.connect("task_finished", Callable(self, "_on_task_finished"))
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
	
	# Short messages for common errors
	var short_errors = {
		"EMAIL_EXISTS": "Email already registered",
		"INVALID_EMAIL": "Invalid email",
		"WEAK_PASSWORD": "Weak password (min. 6 chars)",
		"MISSING_PASSWORD": "Missing password",
		"MISSING_EMAIL": "Missing email",
		"INVALID_LOGIN_CREDENTIALS": "Invalid credentials",
		"OPERATION_NOT_ALLOWED": "Signup disabled",
		"TOO_MANY_ATTEMPTS_TRY_LATER": "Too many attempts, try later"
	}
	
	# Check if we have a short message for this error
	var error_key = message.get_slice(":", 0).strip_edges()
	if short_errors.has(error_key):
		%StateLabel.text = short_errors[error_key]
	else:
		# Fallback to generic error
		%StateLabel.text = "Signup failed"
func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/UI/Authentication.tscn")
