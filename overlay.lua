#!/usr/bin/env lua
local THIS_DIR = (... or '1'):match("(.-)[^%.]+$")

local info = require(THIS_DIR .. 'info')
local util = require(THIS_DIR .. 'util.util')
local var = require(THIS_DIR .. 'var')

last_buttons = {}
while true do
  util.draw_text(2, 120, {
      -- 'Mode:' .. var.mode:read() .. '/' .. var.submode:read(),
      'Stored EG: ' .. info.stored_eg_string(),
      'Waterwalk: ' .. info.waterwalk_string(),
      'Spinspeed: ' .. info.spinspeed_string(),
      'Bunny mode: ' .. info.bunny_string(),
      'Tempbunny: ' .. info.tempbunny_string(),
      'Buttons: ' .. info.snes9x_button_string(last_buttons),
  })
  last_buttons = info.buffered_buttons()
  snes9x.frameadvance()
end
