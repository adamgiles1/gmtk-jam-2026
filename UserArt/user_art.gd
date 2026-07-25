@tool
class_name UserArt extends Node2D

@export_tool_button("Randomize Appearance") var randomize_button = randomize_appearance
@export_tool_button("Play Idle") var play_idle_button = play_idle
@export_tool_button("Unequip Weapon") var unequip_weapon_button = unequip_weapon
@export_tool_button("Equip Weapon") var equip_weapon_button = equip_weapon
@export_tool_button("Equip Pickaxe") var equip_pickaxe_button = equip_pickaxe
@export_tool_button("Equip Fishing Rod") var equip_fishing_rod_button = equip_fishing_rod
@export_tool_button("Unequip Offhand") var unequip_offhand_button = unequip_offhand
@export_tool_button("Equip Offhand") var equip_offhand_button = equip_offhand
@export_tool_button("Apply Streamer Outfit") var streamer_button = apply_streamer_outfit
@export_tool_button("Apply Ugly Hat") var ugly_button = apply_ugly_hat
@export_tool_button("Apply PVP Hat") var pvp_button = apply_pvp_hat
@export_tool_button("Apply Rare Sword") var rare_sword_button = apply_rare_sword
@export_tool_button("Apply Happy Face") var happy_face_button = apply_happy_face
@export_tool_button("Apply Sad Face") var sad_face_button = apply_sad_face
@export_tool_button("Apply Upset Face") var upset_face_button = apply_upset_face
@export_tool_button("Apply Smug Face") var smug_face_button = apply_smug_face

@onready var _animator := $AnimationPlayer

enum _weapon_slot { EMPTY, WEAPON, PICKAXE, FISHING_ROD }
enum _offhand_slot { EMPTY, OFFHAND }
var _weapon_sprite
var _weapon_color
var _offhand_sprite

static var _streamer_hat := preload("res://UserArt/Hats/StreamerHat.png")
static var _ugly_hat := preload("res://UserArt/Hats/UglyHat.png")
static var _pvp_hat := preload("res://UserArt/Hats/PartyHat.png")
static var _rare_sword := preload("res://UserArt/Weapons/RareSword.png")

static var _smear_sprite = preload("res://UserArt/Weapons/WeaponSmear.png")
static var _pickaxe_sprite = preload("res://UserArt/Weapons/Pickaxe.png")
static var _fishing_rod_sprite = preload("res://UserArt/Weapons/FishingRod.png")

static var _happy_head := preload("res://UserArt/Heads/HappyHead.png")
static var _smug_head := preload("res://UserArt/Heads/SmugHead.png")
static var _sad_head := preload("res://UserArt/Heads/SadHead.png")
static var _upset_head := preload("res://UserArt/Heads/UpsetHead.png")

func _process(_delta: float) -> void:
	z_index = int(position.y * 100)
	
func play_idle() -> void:
	_animator.play("Idle")
	
func play_walk(move_dir: Vector2) -> void:
	_animator.play("Walk")
	if move_dir.x > 0:
		scale.x = -1
	elif move_dir.x < 0:
		scale.x = 1
	
func play_attack(attack_dir: Vector2) -> void:
	_animator.play("Attack")
	if attack_dir.x > 0:
		scale.x = -1
	elif attack_dir.x < 0:
		scale.x = 1
	
func play_interact(interact_dir: Vector2) -> void:
	_animator.play("Interact")
	if interact_dir.x > 0:
		scale.x = -1
	elif interact_dir.x < 0:
		scale.x = 1
		
func unequip_weapon() -> void:
	_modify_weapon_slot(_weapon_slot.EMPTY)
	
func equip_weapon() -> void:
	_modify_weapon_slot(_weapon_slot.WEAPON)
	
func equip_pickaxe() -> void:
	_modify_weapon_slot(_weapon_slot.PICKAXE)
	
func equip_fishing_rod() -> void:
	_modify_weapon_slot(_weapon_slot.FISHING_ROD)
	
func unequip_offhand() -> void:
	_modify_offhand_slot(_offhand_slot.EMPTY)
	
func equip_offhand() -> void:
	_modify_offhand_slot(_offhand_slot.OFFHAND)
		
func apply_streamer_outfit() -> void:
	%Hat.texture = _streamer_hat
	%Hat.self_modulate = Color.WHITE
	
func apply_ugly_hat() -> void:
	%Hat.texture = _ugly_hat
	%Hat.self_modulate = Color.WHITE
	
func apply_pvp_hat() -> void:
	%Hat.texture = _pvp_hat
	%Hat.self_modulate = Color.GREEN
	
func apply_rare_sword() -> void:
	_weapon_color = Color("ff029cff")
	%Weapon.texture = _rare_sword
	_weapon_sprite = _rare_sword
	%Weapon.self_modulate = _weapon_color
	%Smear.texture = _smear_sprite
	%Smear.self_modulate = _weapon_color
	
func apply_happy_face() -> void:
	%Head.texture = _happy_head
	
func apply_sad_face() -> void:
	%Head.texture = _sad_head
	
func apply_upset_face() -> void:
	%Head.texture = _upset_head
	
func apply_smug_face() -> void:
	%Head.texture = _smug_head
		
func randomize_appearance() -> void:
	_set_hips(%Hips)
	_set_legs(%Legs)
	_set_shoes(%LShoe, %RShoe)
	_set_torso(%Torso)
	_set_head(%Head) #hair????
	_set_hat(%Hat) #hair????
	_set_arms(%LeftArm, %RightArm) #left and right, inherit torso color, single sprite option
	_set_hands(%LHand, %RHand) #inherit head color?, single sprite option, gloves?????
	_set_weapon(%Weapon, %Smear) #called at runtime as well to swap equipment, or stow. Include smear
	_set_offhand(%OffHand) #match weapon color? Also changeable/stowable
	

func _modify_weapon_slot(weapon: _weapon_slot) -> void:
	if weapon == _weapon_slot.EMPTY:
		%Weapon.texture = null
		%Smear.texture = null
	if weapon == _weapon_slot.WEAPON:
		%Weapon.texture = _weapon_sprite
		%Weapon.self_modulate = _weapon_color
		%Smear.texture = _smear_sprite
		%Smear.self_modulate = _weapon_color
	if weapon == _weapon_slot.PICKAXE:
		%Weapon.texture = _pickaxe_sprite
		%Weapon.self_modulate = Color.WHITE
		%Smear.texture = _smear_sprite
		%Smear.self_modulate = Color.WHITE
	if weapon == _weapon_slot.FISHING_ROD:
		%Weapon.texture = _fishing_rod_sprite
		%Weapon.self_modulate = Color.WHITE
		%Smear.texture = null
		
func _modify_offhand_slot(offhand: _offhand_slot) -> void:
	if offhand == _offhand_slot.EMPTY:
		%OffHand.texture = null
	if offhand == _offhand_slot.OFFHAND:
		%OffHand.texture = _offhand_sprite
	
class SpriteOption:
	var sprite
	var colors
	
	func _init(s, c):
		sprite = s
		colors = c
	
static var _hip_colors := [
	Color(0.418, 0.214, 0.234),
	Color(0.452, 0.172, 0.135),
	Color(0.394, 0.516, 0.566, 1.0)
]
	
static var _hip_sprites := [
	SpriteOption.new(preload("res://UserArt/Hips/Jeans.png"), _hip_colors),
	SpriteOption.new(preload("res://UserArt/Hips/BeltedJeans.png"), _hip_colors),
]
func _set_hips(hips) -> void:
	var option = _hip_sprites.pick_random()
	hips.texture = option.sprite
	hips.self_modulate = option.colors.pick_random()
	
static var leg_sprites := [
	preload("res://UserArt/Legs/JeanLegs.png")	
]
	
func _set_legs(legs) -> void:
	legs.texture = leg_sprites.pick_random()
	legs.self_modulate = %Hips.self_modulate

static var _metal_colors := [
	Color(0.809, 0.809, 0.809, 1.0),
	Color(1.0, 0.82, 0.353, 1.0),
	Color(0.532, 0.714, 0.965, 1.0),
	Color(0.319, 0.357, 0.108, 1.0),
	Color(0.866, 0.456, 0.538, 1.0),
	Color(0.305, 0.487, 0.633, 1.0),
	Color(0.98, 0.613, 0.0, 1.0),
]

static var _leather_colors := [
	Color(0.312, 0.197, 0.107, 1.0),
	Color(0.412, 0.403, 0.223, 1.0),
	Color(0.197, 0.286, 0.141, 1.0)
]

static var _shoe_sprites := [
	SpriteOption.new(preload("res://UserArt/Shoes/MetalBoots.png"), _metal_colors),
	SpriteOption.new(preload("res://UserArt/Shoes/LeatherBoots.png"), _leather_colors)
]

func _set_shoes(l_shoe, r_shoe) -> void:
	var option = _shoe_sprites.pick_random()
	var shoe_color = option.colors.pick_random()
	l_shoe.texture = option.sprite
	l_shoe.self_modulate = shoe_color
	r_shoe.texture = option.sprite
	r_shoe.self_modulate = shoe_color
	
static var _torso_sprites := [
	SpriteOption.new(preload("res://UserArt/Torsos/BodySuit.png"), _leather_colors),
	SpriteOption.new(preload("res://UserArt/Torsos/Platebody.png"), _metal_colors)
]

func _set_torso(torso) -> void:
	var option = _torso_sprites.pick_random()
	torso.texture = option.sprite
	torso.self_modulate = option.colors.pick_random()
	
static var _skin_colors := [
	Color(0.997, 0.754, 0.662, 1.0),
	Color(0.832, 0.517, 0.473, 1.0),
	Color(0.506, 0.295, 0.24, 1.0)
]
static var _head_sprites := [
	SpriteOption.new(preload("res://UserArt/Heads/HappyHead.png"), _skin_colors),
]

func _set_head(head) -> void:
	var option = _head_sprites.pick_random()
	head.texture = option.sprite
	head.self_modulate = option.colors.pick_random()
	
static var _party_colors := [
	Color.RED,
	Color.YELLOW,
	Color.GREEN,
	Color.BLUE,
]

static var _hair_colors := [
	Color(0.259, 0.259, 0.259, 1.0),
	Color(0.765, 0.725, 0.231, 1.0),
	Color(0.823, 0.413, 0.21, 1.0),
	Color(0.404, 0.262, 0.069, 1.0),
	Color(0.18, 0.62, 0.553, 1.0),
]
	
static var _hat_sprites := [
	SpriteOption.new(preload("res://UserArt/Hats/BucketHelm.png"), _metal_colors),
	SpriteOption.new(preload("res://UserArt/Hats/Haircut.png"), _hair_colors),
	SpriteOption.new(preload("res://UserArt/Hats/LongHaircut.png"), _hair_colors),
]

	
func _set_hat(hat) -> void:
	var option = _hat_sprites.pick_random()
	hat.texture = option.sprite
	hat.self_modulate = option.colors.pick_random()
	
static var _arm_sprites := [
	[preload("res://UserArt/LeftArms/LeftArm.png"), preload("res://UserArt/RightArms/RightArm.png")]
]
	
func _set_arms(left_arm, right_arm) -> void:
	var option = _arm_sprites.pick_random()
	left_arm.texture = option[0]
	right_arm.texture = option[1]
	left_arm.self_modulate = %Torso.self_modulate
	right_arm.self_modulate = %Torso.self_modulate
	
static var _hand_sprites := [
	preload("res://UserArt/Hands/Hand.png")
]

func _set_hands(r_hand, l_hand) -> void:
	var option = _hand_sprites.pick_random()
	r_hand.texture = option
	l_hand.texture = option
	r_hand.self_modulate = %Head.self_modulate
	l_hand.self_modulate = %Head.self_modulate
	
static var _weapon_sprites := [
	SpriteOption.new(preload("res://UserArt/Weapons/Sword.png"), _metal_colors),
	SpriteOption.new(preload("res://UserArt/Weapons/Axe.png"), _metal_colors),
	SpriteOption.new(preload("res://UserArt/Weapons/Mace.png"), _metal_colors),
	SpriteOption.new(null, [Color.TRANSPARENT]),
]
	
func _set_weapon(weapon, smear) -> void:
	var option = _weapon_sprites.pick_random()
	_weapon_color = option.colors.pick_random()
	weapon.texture = option.sprite
	_weapon_sprite = option.sprite
	weapon.self_modulate = _weapon_color
	smear.texture = _smear_sprite
	smear.self_modulate = _weapon_color
	
static var _wood_colors := [
	Color(0.233, 0.138, 0.033, 1.0),
	Color(0.255, 0.234, 0.085, 1.0),
	Color(0.557, 0.453, 0.281, 1.0),
]
	
static var _offhand_sprites := [
	SpriteOption.new(preload("res://UserArt/OffHands/CrestShield.png"), _metal_colors),
	SpriteOption.new(preload("res://UserArt/OffHands/WoodenShield.png"), _wood_colors),
	SpriteOption.new(null, [Color.TRANSPARENT]),
]
	
func _set_offhand(offhand) -> void:
	if %Weapon.self_modulate == Color.TRANSPARENT:
		offhand.texture = null
		offhand.self_modulate = Color.TRANSPARENT
		return
	var option = _offhand_sprites.pick_random()
	offhand.texture = option.sprite
	_offhand_sprite = option.sprite
	offhand.self_modulate = option.colors.pick_random()
