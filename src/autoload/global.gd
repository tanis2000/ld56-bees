extends Node

var player: Node2D
var main: Node2D
var menu: Node2D
var hud: Node2D
var hive: Node2D

enum InputType {
	INPUT_KEYBOARD,
	INPUT_CONTROLLER
}
var inputType := InputType.INPUT_KEYBOARD

enum GameState {
    MAIN_MENU,
    ARENA,
    GAME_OVER,
}

var game_state := GameState.MAIN_MENU

enum PlayerAction {
    PLAYER_ACTION_BEE,
    PLAYER_ACTION_BADA,
    PLAYER_ACTION_BON,
    PLAYER_ACTION_BOO,
}

var spawn_count := 0

var options := {
    name = "",
	sound_volume = 0.75,
	music_volume = 0.6,
}

var state := {
    dead = false,
    max_health = 10,
    health = 10,
    initial_bees = 1,
    initial_wasps = 1,
    time_elapsed = 0.0,
    wax = 0,
}

var stats := {
    total_enemies_killed = 0,
    total_bullets_fired = 0,
}
