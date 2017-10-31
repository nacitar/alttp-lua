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
  output = info.glitched_states()
  table.insert(output, string.format('%05d,%05d',
      var.player_x:read(), var.player_y:read()))
  util.draw_text_above(10, 211, output)
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
