#!/usr/bin/env lua
local THIS_DIR = (... or '1'):match("(.-)[^%.]+$")

local info = require(THIS_DIR .. 'info')
local util = require(THIS_DIR .. 'util.util')

while true do
  info.main()
  util.draw_text(2, 120, {
      'Stored EG: ' .. info.stored_eg_string(),
      'Waterwalk: ' .. info.waterwalk_string(),
      'Spinspeed: ' .. info.spinspeed_string(),
      'Superbunny: ' .. info.superbunny_string(),
      'Supertempbunny: ' .. info.supertempbunny_string(),
  })
  snes9x.frameadvance()
end
