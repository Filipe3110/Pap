extends Control


func _ready():
	Firebase.Auth.login_succeeded.connect(on_login_succeeded)
	Firebase.Auth.login_failed.connect(on_login_failed)
	
	if Firebase.Auth.check_auth_file():
		%StateLabel.text = "Logged in"
		get_tree().change_scene_to_file("res://Cenas/UI/main.tscn")


func _on_login_button_pressed():
	var email = %EmailLineEdit.text
	var password = %PasswordLineEdit.text
	Firebase.Auth.login_with_email_and_password(email, password)
	%StateLabel.text = "Logging in"



func on_login_succeeded(auth):
	print(auth)
	%StateLabel.text = "Login success!"
	Firebase.Auth.save_auth(auth)
	get_tree().change_scene_to_file("res://Cenas/UI/main.tscn")
	

	
func on_login_failed(error_code, message):
	print(error_code)
	print(message)
	%StateLabel.text = "Login failed. Error: %s" % message
	

func _on_create_account_pressed() -> void:
	print("Mudando para cena de criação de conta.")
	get_tree().change_scene_to_file("res://Cenas/UI/new_account.tscn")

func _on_quit_pressed() -> void:
	print("Fechando o jogo.")
	get_tree().quit()
