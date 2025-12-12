extends Node

const CFG_PATH := "user://settings.cfg"
const CFG_SECTION := "settings"
const CFG_KEY_LANG := "lang"

var lang := "et"

func _ready() -> void:
	load_settings()
	apply_language(lang)

func apply_language(new_lang: String) -> void:
	lang = new_lang
	TranslationServer.set_locale(lang)
	save_settings()

func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value(CFG_SECTION, CFG_KEY_LANG, lang)
	cfg.save(CFG_PATH)

func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(CFG_PATH) == OK:
		lang = str(cfg.get_value(CFG_SECTION, CFG_KEY_LANG, "et"))
	else:
		lang = "et"
