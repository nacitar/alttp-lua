#!/usr/bin/env lua

local info = require 'info'
local util = require 'util/util'

while true do
  info.main()
  util.draw_text(2, 120, {
      'Stored EG: ' .. info.stored_eg_string()
      'Waterwalk: ' .. info.waterwalk_string(),
      'Spinspeed: ' .. info.spinspeed_string(),
  })
  snes9x.frameadvance()
end
