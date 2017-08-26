local THIS_DIR = (... or ''):match("(.-)[^%.]+$") or '.'

local info = require(THIS_DIR .. 'info')
local util = require(THIS_DIR .. 'util.util')
local var = require(THIS_DIR .. 'var')

local engine = emu or snes9x

local HudLocation = {
  TOP = 0,
  BOTTOM = 1,
}

HUD_LOCATION = HudLocation.BOTTOM
-- this mimics practice hack, good for select buffering
HUD_MOVEMENT_FRAME_ONLY = true

last_buttons = {}
last_movement_frame_buttons = {}
--print(gui)
while true do
  util.draw_text(2, 120, {
      --'Mode:' .. var.mode:read() .. '/' .. var.submode:read(),
      'Stored EG: ' .. info.stored_eg_string(),
      'Waterwalk: ' .. info.waterwalk_string(),
      'Spinspeed: ' .. info.spinspeed_string(),
      'Bunny mode: ' .. info.bunny_string(),
      'Tempbunny: ' .. info.tempbunny_string(),
      'Buttons: ' .. info.snes9x_button_string(last_buttons),
  })
  if HUD_LOCATION == HudLocation.TOP then
    hud_x = 114
    hud_y = 3  -- 1 is at edge, but looks better halfway to upper hud
  else -- if HUD_LOCATION == HudLocation.BOTTOM then
    hud_x = 114
    -- 214 is the lowest it can draw
    hud_y = 211
  end
  if HUD_MOVEMENT_FRAME_ONLY then
    buttons = last_movement_frame_buttons
  else
    buttons = last_buttons
  end
  info.draw_input_hud(hud_x, hud_y, buttons)

  last_buttons = info.buffered_buttons()
  mode = var.mode:read()
  if var.submode:read() == var.SubModeFlags.PLAYER_CONTROL and (
      mode == var.ModeFlags.OVERWORLD or mode == var.ModeFlags.UNDERWORLD) then
    last_movement_frame_buttons = last_buttons
  end
  engine.frameadvance()
end
