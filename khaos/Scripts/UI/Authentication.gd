extends Control

@onready var transição = $"Transição/AnimationPlayer"

func _ready():
	Firebase.Auth.login_succeeded.connect(on_login_succeeded)
	Firebase.Auth.login_failed.connect(on_login_failed)
	
	if Firebase.Auth.check_auth_file():
		%StateLabel.text = "Logged in"
		Global.from_authentication = true
		get_tree().change_scene_to_file("res://Cenas/UI/tela_inicial.tscn")


func _on_login_button_pressed():
	var email = %EmailLineEdit.text
	var password = %PasswordLineEdit.text
	Firebase.Auth.login_with_email_and_password(email, password)
	%StateLabel.text = "Logging in"



func on_login_succeeded(auth):
	print(auth)
	%StateLabel.text = "Login success!"
	Firebase.Auth.save_auth(auth)
	transição.play("Trasição1")
	await transição.animation_finished
	Global.from_authentication = true
	get_tree().change_scene_to_file("res://Cenas/UI/tela_inicial.tscn")
	

	
func on_login_failed(error_code, message):
	print("Error code: ", error_code)
	print("Error message: ", message)
	
	# Short messages for common login errors
	var short_errors = {
		"INVALID_EMAIL": "Invalid email",
		"MISSING_PASSWORD": "Missing password",
		"MISSING_EMAIL": "Missing email",
		"INVALID_LOGIN_CREDENTIALS": "Wrong email or password",
		"USER_DISABLED": "Account disabled",
		"EMAIL_NOT_FOUND": "Email not registered",
		"TOO_MANY_ATTEMPTS_TRY_LATER": "Too many attempts, try later",
		"OPERATION_NOT_ALLOWED": "Login disabled"
	}
	
	# Check if we have a short message for this error
	var error_key = message.get_slice(":", 0).strip_edges()
	if short_errors.has(error_key):
		%StateLabel.text = short_errors[error_key]
	else:
		%StateLabel.text = "Login failed"
	

func _on_create_account_pressed() -> void:
	print("Mudando para cena de criação de conta.")
	get_tree().change_scene_to_file("res://Cenas/UI/new_account.tscn")

func _on_quit_pressed() -> void:
	print("Fechando o jogo.")
	get_tree().quit()
