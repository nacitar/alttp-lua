#!/usr/bin/env lua
local THIS_DIR = (... or '1'):match("(.-)[^%.]+$")
local ram = require(THIS_DIR .. 'util.ram')


-- look into pull glitch and taglongs

return {
  mode = ram.Unsigned(0x7E0010, 1),
  ModeFlags = {
    TEXT_ITEM_MAP = 14,
  },
  submode = ram.Unsigned(0x7E0011, 1),
  SubModeFlags = {
    DUCK_MAP = 10,
  },
  is_indoors = ram.Unsigned(0x7E001B, 1),
  falling_state = ram.Unsigned(0x7E005B, 1),
  FallingStateFlags = {
    NORMAL = 0,
  },

  aux_link_state = ram.Unsigned(0x7E004D, 1),
  AuxLinkStateFlags = {
    GROUND = 0,
    RECOIL = 1,
    JUMPING = 2,
    SWIMMING = 4,
  },
  player_state = ram.Unsigned(0x7E005D, 1),
  PlayerStateFlags = {
    GROUND = 0,
    FALLING_OR_NEAR_HOLE = 1,
    SPIN_ATTACKING = 3,
    JUMPING_NORTH_OR_INSIDE = 6,  -- resets queued_layer_change, even outside
    DASHING = 17,
    PERMABUNNY = 23,
    TEMPBUNNY = 28,
  },

  joypad1_main = ram.Unsigned(0x7E00F0, 1),  -- [BYST | udlr]
  joypad1_secondary = ram.Unsigned(0x7E00F2, 1),  -- [AXLR | ????]
  joypad1_main_filtered = ram.Unsigned(0x7E00F4, 1),
  joypad1_secondary_filtered = ram.Unsigned(0x7E00F6, 1),
  JoypadMain = {
    RIGHT = 1,
    LEFT = 2,
    DOWN = 4,
    UP = 8,
    START = 16,
    SELECT = 32,
    Y = 64,
    B = 128,
  },
  JoypadSecondary = {
    R = 16,
    L = 32,
    X = 64,
    A = 128,
  },

  hand_up_pose = ram.Unsigned(0x7E02DA, 1),
  HandUpPoseFlags = {
    NOT_UP = 0,
  },

  bunny_mode = ram.Unsigned(0x7E02E0, 1),

  bonk_wall = ram.Unsigned(0x7E0372, 1),
  dash_countdown = ram.Unsigned(0x7E0374, 1),
  tempbunny_timer = ram.Unsigned(0x7E03F5, 2),
  room_upper_layer = ram.Unsigned(0x7E044A, 2),
  -- can be > 1 if it's queued and then you jump... code just adds 1 to it for
  -- some reason, rather than setting to 1 like a bool
  queued_layer_change = ram.Unsigned(0x7E047A, 2),

  link_cannot_move = ram.Unsigned(0x7E0B7B, 1),
  -----------------------------------
  g_overlord_activator = ram.Unsigned(0x7E0CF4, 1),  -- bomb/snake trap if not 0
  -----------------------------------
  overlord_type = ram.Array(0x7E0B00, 1, 8),
  overlord_x_low = ram.Array(0x7E0B08, 1, 8),
  overlord_x_high = ram.Array(0x7E0B10, 1, 8),
  overlord_y_low = ram.Array(0x7E0B18, 1, 8),
  overlord_y_high = ram.Array(0x7E0B20, 1, 8),
  overlord_timer_1 = ram.Array(0x7E0B28, 1, 8),
  overlord_timer_2 = ram.Array(0x7E0B30, 1, 8),
  overlord_timer_3 = ram.Array(0x7E0B38, 1, 8),
  overlord_floor_selector = ram.Array(0x7E0B40, 1, 8),  -- bg1/2
  overlord_area_number = ram.Array(0x7E0CCA, 1, 8),
  -----------------------------------
  g_sprite_floor_status = ram.Unsigned(0x7E0B68, 1),
  g_sprite_unknown_tut_blind_01 = ram.Unsigned(0x7E0B69, 1),
  g_sprite_limiter_unknown = ram.Unsigned(0x7E0B6A, 1),
  g_sprite_unknown_tut_blind_02 = ram.Unsigned(0x7E0B96, 1),
  g_sprite_damage_type = ram.Unsigned(0x7E0CF2, 1),
  -----------------------------------
  sprite_overlord_position_offset = ram.Array(0x7E0B48, 1, 16),  -- overlord?
  sprite_stun_timer = ram.Array(0x7E0B58, 1, 16),
  sprite_misc_flags_1 = ram.Array(0x7E0B6B, 1, 16),  -- death, tile hitbox...
  sprite_priority_unknown = ram.Array(0x7E0B89, 1, 16),
  sprite_ignore_projectiles = ram.Array(0x7E0BA0, 1, 16),
  sprite_interacts_with_sprite = ram.Array(0x7E0BB0, 1, 16),
  -- $BC0 - $BDF some sort of sprite/dungeon index
  sprite_interaction_flags = ram.Array(0x7E0BE0, 1, 16),
  sprite_area_number = ram.Array(0x7E0C9A, 1, 16),
  sprite_deflection_flags = ram.Array(0x7E0CAA, 1, 16),  -- check bit c
  sprite_key_reward = ram.Array(0x7E0CBA, 1, 16),
  sprite_bump_damage = ram.Array(0x7E0CD2, 1, 16),
  sprite_hp_subtract = ram.Array(0x7E0CE2, 1, 16),
  sprite_y_low = ram.Array(0x7E0D00, 1, 16),
  sprite_x_low = ram.Array(0x7E0D10, 1, 16),
  sprite_y_high = ram.Array(0x7E0D20, 1, 16),
  sprite_x_high = ram.Array(0x7E0D30, 1, 16),
  sprite_y_velocity = ram.Array(0x7E0D40, 1, 16),
  sprite_x_velocity = ram.Array(0x7E0D50, 1, 16),
  sprite_y_2nd_derivative = ram.Array(0x7E0D60, 1, 16),
  sprite_x_2nd_derivative = ram.Array(0x7E0D70, 1, 16),
  sprite_spawned = ram.Array(0x7E0D80, 1, 16),
  sprite_misc_index = ram.Array(0x7E0D90, 1, 16),
  sprite_misc_01 = ram.Array(0x7E0DA0, 1, 16),
  sprite_misc_02 = ram.Array(0x7E0DB0, 1, 16),
  sprite_graphics = ram.Array(0x7E0DC0, 1, 16),
  sprite_state = ram.Array(0x7E0DD0, 1, 16),
  sprite_position_counter = ram.Array(0x7E0DE0, 1, 16),  -- statues, misc...
  sprite_main_delay_timer = ram.Array(0x7E0DF0, 1, 16),
  sprite_aux_delay_timer_1 = ram.Array(0x7E0E00, 1, 16),
  sprite_aux_delay_timer_2 = ram.Array(0x7E0E10, 1, 16),
  sprite_type = ram.Array(0x7E0E20, 1, 16),  -- huge list of types
  sprite_subtype_1 = ram.Array(0x7E0E30, 1, 16),
  sprite_misc_flags_2 = ram.Array(0x7E0E40, 1, 16),
  sprite_health = ram.Array(0x7E0E50, 1, 16),
  sprite_misc_flags_3 = ram.Array(0x7E0E60, 1, 16),
  sprite_collision_direction = ram.Array(0x7E0E70, 1, 16),
  sprite_subtype_2 = ram.Array(0x7E0E80, 1, 16),
  sprite_unknown_pikit = ram.Array(0x7E0E90, 1, 16),
  sprite_unknown_damage_related = ram.Array(0x7E0EA0, 1, 16),
  sprite_head_direction = ram.Array(0x7E0EB0, 1, 16),
  sprite_unknown_animation_clock = ram.Array(0x7E0EC0, 1, 16),
  sprite_unknown_giant_moldorm = ram.Array(0x7E0ED0, 1, 16),
  sprite_aux_delay_timer_3 = ram.Array(0x7E0EE0, 1, 16),
  sprite_unknown_death_timer = ram.Array(0x7E0EF0, 1, 16),
  sprite_paused = ram.Array(0x7E0F00, 1, 16),
  sprite_aux_delay_timer_4 = ram.Array(0x7E0F10, 1, 16),
  sprite_floor_selector = ram.Array(0x7E0F20, 1, 16),  -- bg1/2
  sprite_y_recoil_velocity = ram.Array(0x7E0F30, 1, 16),
  sprite_x_recoil_velocity = ram.Array(0x7E0F40, 1, 16),
  sprite_unknown_oam_related = ram.Array(0x7E0F50, 1, 16),
  sprite_misc_flags_4 = ram.Array(0x7E0F60, 1, 16),
  sprite_z = ram.Array(0x7E0F70, 1, 16),
  sprite_z_velocity = ram.Array(0x7E0F80, 1, 16),
  sprite_z_subpixel = ram.Array(0x7E0F90, 1, 16),
  -- higher $0Fxx values are global sprite settings

  -----------------------------------
  ancilla_unknown_01 = ram.Array(0x7E0BF0, 1, 10),
  ancilla_y_low = ram.Array(0x7E0BFA, 1, 10),
  ancilla_x_low = ram.Array(0x7E0C04, 1, 10),
  ancilla_y_high = ram.Array(0x7E0C0E, 1, 10),
  ancilla_x_high = ram.Array(0x7E0C18, 1, 10),
  ancilla_y_velocity = ram.Array(0x7E0C22, 1, 10),
  ancilla_x_velocity = ram.Array(0x7E0C2C, 1, 10),
  ancilla_y_subpixel = ram.Array(0x7E0C36, 1, 10),
  ancilla_x_subpixel = ram.Array(0x7E0C40, 1, 10),
  ancilla_type = ram.Array(0x7E0C4A, 1, 10),
  AncillaType = {
    DUCK = 39,
  },
  ancilla_effect_state = ram.Array(0x7E0C54, 1, 10),
  AncillaEffectState = {
    HOLDING_PLAYER = 2,
  },
  ancilla_item_index = ram.Array(0x7E0C5E, 1, 10),  -- 0x38 == pendant of power
  ancilla_dec_timer = ram.Array(0x7E0C68, 1, 10),
  ancilla_special_effect = ram.Array(0x7E0C72, 1, 10),  -- bomb direction laid
  ancilla_floor_selector = ram.Array(0x7E0C7C, 1, 10),  -- bg1/2
  ancilla_oam_offset = ram.Array(0x7E0C86, 1, 10),
  ancilla_special_effect_sprites_times_four = ram.Array(0x7E0C90, 1, 10),
  -----------------------------------
  in_dark_world = ram.Unsigned(0x7E0FFF, 1),
}
