#!/usr/bin/env lua
local THIS_DIR = (... or '1'):match("(.-)[^%.]+$")
local ram = require(THIS_DIR .. 'util.ram')

return {
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
    JUMPING = 6,
    DASHING = 17,
    PERMABUNNY = 23,
    TEMPBUNNY = 28,
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
}
