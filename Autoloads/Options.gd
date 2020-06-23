extends Node

# Todo - zapisywanie ustawień do pliku jeśli nie jest to akurat zapisywanie ustawień przez benchmark

var msaa : int = 0
var default_environment : String = ""
var framebuffer_allocation : int = 0
var directional_shadow_size : int = 0
var shadow_atlas_size : int = 0
var filter_mode : int = 0
var texture_array_reflections : bool = false
var high_quality_ggx : bool = false
var irradiance_max_size : int = 0
var force_vertex_shading : bool = false
var force_lambert_over_burley : bool = false
var force_blinn_over_ggx : bool = false
var use_nearest_mipmap_filter : bool = false



func benchmark_save_current_settings_state():
	msaa = ProjectSettings.get_setting("rendering/quality/filters/msaa")
	default_environment = ProjectSettings.get_setting("rendering/environment/default_environment")
	framebuffer_allocation = ProjectSettings.get_setting("rendering/quality/intended_usage/framebuffer_allocation")
	directional_shadow_size = ProjectSettings.get_setting("rendering/quality/directional_shadow/size")
	shadow_atlas_size = ProjectSettings.get_setting("rendering/quality/shadow_atlas/size")
	filter_mode = ProjectSettings.get_setting("rendering/quality/shadows/filter_mode")
	texture_array_reflections = ProjectSettings.get_setting("rendering/quality/reflections/texture_array_reflections")
	high_quality_ggx = ProjectSettings.get_setting("rendering/quality/reflections/high_quality_ggx")
	irradiance_max_size = ProjectSettings.get_setting("rendering/quality/reflections/irradiance_max_size")
	force_vertex_shading = ProjectSettings.get_setting("rendering/quality/shading/force_vertex_shading")
	force_lambert_over_burley = ProjectSettings.get_setting("rendering/quality/shading/force_lambert_over_burley")
	force_blinn_over_ggx = ProjectSettings.get_setting("rendering/quality/shading/force_blinn_over_ggx")
	use_nearest_mipmap_filter = ProjectSettings.get_setting("rendering/quality/filters/use_nearest_mipmap_filter")
	

func benchmark_load_saved_settings_state():
	ProjectSettings.set_setting("rendering/quality/filters/msaa", msaa)
	ProjectSettings.set_setting("rendering/environment/default_environment", default_environment)
	ProjectSettings.set_setting("rendering/quality/intended_usage/framebuffer_allocation", framebuffer_allocation)
	ProjectSettings.set_setting("rendering/quality/directional_shadow/size", directional_shadow_size)
	ProjectSettings.set_setting("rendering/quality/shadow_atlas/size", shadow_atlas_size)
	ProjectSettings.set_setting("rendering/quality/shadows/filter_mode", filter_mode)
	ProjectSettings.set_setting("rendering/quality/reflections/texture_array_reflections", texture_array_reflections)
	ProjectSettings.set_setting("rendering/quality/reflections/high_quality_ggx", high_quality_ggx)
	ProjectSettings.set_setting("rendering/quality/reflections/irradiance_max_size", irradiance_max_size)
	ProjectSettings.set_setting("rendering/quality/shading/force_vertex_shading", force_vertex_shading)
	ProjectSettings.set_setting("rendering/quality/shading/force_lambert_over_burley", force_lambert_over_burley)
	ProjectSettings.set_setting("rendering/quality/shading/force_blinn_over_ggx", force_blinn_over_ggx)
	ProjectSettings.set_setting("rendering/quality/filters/use_nearest_mipmap_filter", use_nearest_mipmap_filter)
	
func load_min_settings():
	ProjectSettings.set_setting("rendering/quality/filters/msaa", Viewport.MSAA_DISABLED)
	ProjectSettings.set_setting("rendering/environment/default_environment", null)
	ProjectSettings.set_setting("rendering/quality/intended_usage/framebuffer_allocation", VisualServer.VIEWPORT_USAGE_3D_NO_EFFECTS)
	ProjectSettings.set_setting("rendering/quality/directional_shadow/size", 128)
	ProjectSettings.set_setting("rendering/quality/shadow_atlas/size", 128)
	ProjectSettings.set_setting("rendering/quality/shadows/filter_mode", 0)
	ProjectSettings.set_setting("rendering/quality/reflections/texture_array_reflections", false)
	ProjectSettings.set_setting("rendering/quality/reflections/high_quality_ggx", false)
	ProjectSettings.set_setting("rendering/quality/reflections/irradiance_max_size", 1)
	ProjectSettings.set_setting("rendering/quality/shading/force_vertex_shading", true)
	ProjectSettings.set_setting("rendering/quality/shading/force_lambert_over_burley", true)
	ProjectSettings.set_setting("rendering/quality/shading/force_blinn_over_ggx", true)
	ProjectSettings.set_setting("rendering/quality/filters/use_nearest_mipmap_filter", true)

func load_max_settings():
	ProjectSettings.set_setting("rendering/quality/filters/msaa", Viewport.MSAA_16X)
	ProjectSettings.set_setting("rendering/environment/default_environment", "res://default_env.tres")
	ProjectSettings.set_setting("rendering/quality/intended_usage/framebuffer_allocation", VisualServer.VIEWPORT_USAGE_3D)
	ProjectSettings.set_setting("rendering/quality/directional_shadow/size", 4096)
	ProjectSettings.set_setting("rendering/quality/shadow_atlas/size", 4096)
	ProjectSettings.set_setting("rendering/quality/shadows/filter_mode", 1)
	ProjectSettings.set_setting("rendering/quality/reflections/texture_array_reflections", true)
	ProjectSettings.set_setting("rendering/quality/reflections/high_quality_ggx", true)
	ProjectSettings.set_setting("rendering/quality/reflections/irradiance_max_size", 128)
	ProjectSettings.set_setting("rendering/quality/shading/force_vertex_shading", false)
	ProjectSettings.set_setting("rendering/quality/shading/force_lambert_over_burley", false)
	ProjectSettings.set_setting("rendering/quality/shading/force_blinn_over_ggx", false)
	ProjectSettings.set_setting("rendering/quality/filters/use_nearest_mipmap_filter", false)

