local THIS_DIR = (... or ''):match("(.-)[^%.]+$") or '.'

local info = require(THIS_DIR .. 'info')
local util = require(THIS_DIR .. 'util.util')
local var = require(THIS_DIR .. 'var')
local padlight = require(THIS_DIR .. 'padlight')

local engine = emu or snes9x

-- this mimics practice hack, good for select buffering
HUD_MOVEMENT_FRAME_ONLY = false

last_buttons = {}
last_movement_frame_buttons = {}

pad_overlay = padlight.Overlay()
pad_overlay:load_config(THIS_DIR .. '/config.ini')
while true do
  util.draw_text(2, 170, {
      --'Mode:' .. var.mode:read() .. '/' .. var.submode:read(),
      'Stored EG: ' .. info.stored_eg_string(),
      'Waterwalk: ' .. info.waterwalk_string(),
      'Spinspeed: ' .. info.spinspeed_string(),
      'Bunny mode: ' .. info.bunny_string(),
      'Tempbunny: ' .. info.tempbunny_string(),
      'Buttons: ' .. info.snes9x_button_string(last_buttons),
  })
  if HUD_MOVEMENT_FRAME_ONLY then
    buttons = last_movement_frame_buttons
  else
    buttons = last_buttons
  end
  pad_overlay:set_pressed(buttons)
  --pad_overlay:draw_snes_controller_shell(0, 2)
  --pad_overlay:draw_snes_button_ring(27, 4)
  --pad_overlay:draw_snes_dpad_ring(4, 6)
  pad_overlay:draw()

  last_buttons = info.buffered_buttons()
  mode = var.mode:read()
  if var.submode:read() == var.SubModeFlags.PLAYER_CONTROL and (
      mode == var.ModeFlags.OVERWORLD or mode == var.ModeFlags.UNDERWORLD) then
    last_movement_frame_buttons = last_buttons
  end
  engine.frameadvance()
end
