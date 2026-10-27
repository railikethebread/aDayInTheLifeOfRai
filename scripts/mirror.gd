# https://www.youtube.com/watch?v=psq76bEEr84

@tool
extends Node3D

@export var size: Vector2 = Vector2(1,1):
	set(v):
		size = v
		$mirrorMesh.mesh.size = size
		$SubViewport.size = size * pixels_per_unit
		
@export var pixels_per_unit:int = 200
@export var cull_near:float = 0.05
@export var cull_far:float = 50.0
@export_flags_3d_render var cull_mask:int = 0xFFFFF
@export var max_update_distance:float = 50.0

var main_cam: Camera3D
var last_main_cam_pos: Vector3


func _ready() -> void:
	if Engine.is_editor_hint():
		main_cam = Engine.get_singleton(&"EditorInterface").get_editor_viewport_3d().get_camera_3d()
	else:
		main_cam = get_viewport().get_camera_3d()
	
	last_main_cam_pos = main_cam.global_position
	setup()
	update_cam()
	
	
func _process(_delta: float) -> void:
	if !is_visible_in_tree(): return
	if !is_instance_valid(main_cam): return
	if last_main_cam_pos.distance_to(main_cam.global_position) < 0.01: return
	
	last_main_cam_pos = main_cam.global_position
	var diff = global_position - last_main_cam_pos
	if diff.length() > max_update_distance:
		$SubViewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	else:
		$SubViewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
		
	update_cam()
	
	
func setup():
	var viewport_texture = $SubViewport.get_texture()
	$SubViewport/Camera3D.cull_mask = cull_mask
	$SubViewport/Camera3D.fov = main_cam.fov
	$mirrorMesh.mesh.size = size
	$SubViewport.size = size*pixels_per_unit
	$mirrorMesh.get_active_material(0).set_shader_parameter(&"tex",viewport_texture)


func update_cam():
	var mirror_normal = $mirrorMesh.global_basis.z
	var mirror_transform = get_mirror_transform(mirror_normal,global_position)
	$SubViewport/Camera3D.global_transform = mirror_transform * main_cam.global_transform
	
	$SubViewport/Camera3D.global_transform = $SubViewport/Camera3D.global_transform.looking_at(
		$SubViewport/Camera3D.global_position / 2.0 + last_main_cam_pos / 2.0, $mirrorMesh.global_position
	)
	var camera_to_mirror_offset = $mirrorMesh.global_position - $SubViewport/Camera3D.global_position
	
	var near = abs(camera_to_mirror_offset.dot(mirror_normal)) + cull_near
	var far = camera_to_mirror_offset.length() + cull_far
	var cam_to_mirror_offset_local = $SubViewport/Camera3D.global_basis.inverse() * camera_to_mirror_offset
	var frustum_offset = Vector2(cam_to_mirror_offset_local.x,cam_to_mirror_offset_local.y)
	$SubViewport/Camera3D.set_frustum(size.x,frustum_offset,near,far)


static func get_mirror_transform(normal:Vector3,offset:Vector3):
	var basis_x = Vector3.RIGHT - (2*Vector3(normal.x * normal.x,normal.x * normal.y, normal.x * normal.z))
	var basis_y = Vector3.RIGHT - (2*Vector3(normal.y * normal.x,normal.y * normal.y, normal.y * normal.z))
	var basis_z = Vector3.RIGHT - (2*Vector3(normal.z * normal.x,normal.z * normal.y, normal.z * normal.z))
	var origin = 2 * normal.dot(offset) * normal
	return Transform3D(basis_x,basis_y,basis_z,origin)
	
