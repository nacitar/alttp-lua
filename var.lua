#!/usr/bin/env lua

local ram = require 'util/ram'

falling_state = ram.Unsigned(0x7E005B, 1)
local FallingStateFlags = {
  NORMAL = 0,
}

player_state = ram.Unsigned(0x7E005D, 1)
local PlayerStateFlags = {
  FALLING_OR_NEAR_HOLE = 1,
  JUMPING = 6,
  DASHING = 17,
}

hand_up_pose = ram.Unsigned(0x7E02DA, 1)
local HandUpPoseFlags = {
  NOT_UP = 0,
}

bonk_wall = ram.Unsigned(0x7E0372, 1)
dash_countdown = ram.Unsigned(0x7E0374, 1)  -- 29 during ss, but not checking
room_upper_layer = ram.Unsigned(0x7E044A, 2)
-- can be > 1 if it's queued and then you jump... code just adds 1 to it for
-- some reason, rather than setting to 1 like a bool
queued_layer_change = ram.Unsigned(0x7E047A, 2)
