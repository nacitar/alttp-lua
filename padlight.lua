local THIS_DIR = (... or ''):match("(.-)[^%.]+$") or '.'
local gfx = require(THIS_DIR .. 'gfx')

SNES = {
  BORDER = gfx.RGBA(0x00, 0x00, 0x00, 0xFF),
  Y_PRESSED = gfx.RGBA(0x00, 0xFF, 0x00, 0xFF),
  Y_RELEASED = gfx.RGBA(0x29, 0x5A, 0x29, 0xFF),
  X_PRESSED = gfx.RGBA(0x8C, 0xD6, 0xFF, 0xFF),
  X_RELEASED = gfx.RGBA(0x42, 0x42, 0x84, 0xFF),
  A_PRESSED = gfx.RGBA(0xFF, 0x67, 0x7F, 0xFF),
  A_RELEASED = gfx.RGBA(0x95, 0x29, 0x29, 0xFF),
  B_PRESSED = gfx.RGBA(0xFF, 0xFF, 0xA0, 0xFF),
  B_RELEASED = gfx.RGBA(0xF0, 0xA0, 0x24, 0xFF),
  DPAD_RELEASED = gfx.RGBA(0x59, 0x5E, 0x62, 0xFF),
  FACE = gfx.RGBA(0xB0, 0xB2, 0xB1, 0xFF),
  BUTTON_RING = gfx.RGBA(0x67, 0x6C, 0x6F, 0xFF),
}
SNES.Y_BORDER = SNES.BORDER
SNES.X_BORDER = SNES.BORDER
SNES.A_BORDER = SNES.BORDER
SNES.B_BORDER = SNES.BORDER
SNES.DPAD_BORDER = SNES.BORDER
SNES.DPAD_PRESSED = SNES.B_PRESSED
SNES.SELECT_BORDER = SNES.BORDER
SNES.SELECT_PRESSED = SNES.B_PRESSED
SNES.SELECT_RELEASED = SNES.DPAD_RELEASED
SNES.START_BORDER = SNES.BORDER
SNES.START_PRESSED = SNES.B_PRESSED
SNES.START_RELEASED = SNES.DPAD_RELEASED
SNES.L_BORDER = SNES.BORDER
SNES.L_PRESSED = SNES.B_PRESSED
SNES.L_RELEASED = SNES.DPAD_RELEASED
SNES.R_BORDER = SNES.BORDER
SNES.R_PRESSED = SNES.B_PRESSED
SNES.R_RELEASED = SNES.DPAD_RELEASED
SNES.BUTTON_AREA = SNES.FACE
SNES.DPAD_RING = SNES.BUTTON_RING
SNES.DPAD_AREA = SNES.FACE


function draw_button(drawer, x, y, border_color, color)
  drawer:draw_rect(0+x, 1+y, 4, 2, border_color)
  drawer:draw_rect(1+x, 0+y, 2, 4, border_color)
  drawer:draw_rect(1+x, 1+y, 2, 2, color)
end

function draw_slanted_button(drawer, x, y, border_color, color)
  drawer:draw_rect(0+x, 2+y, 2, 2, border_color)
  drawer:draw_rect(1+x, 1+y, 2, 2, border_color)
  drawer:draw_rect(2+x, 0+y, 2, 2, border_color)
  drawer:draw_rect(1+x, 2+y, 1, 1, color)
  drawer:draw_rect(2+x, 1+y, 1, 1, color)
end

function draw_dpad(drawer, x, y, pressed, theme)
  drawer:draw_rect(0+x, 2+y, 8, 4, theme.DPAD_BORDER)
  drawer:draw_rect(2+x, 0+y, 4, 8, theme.DPAD_BORDER)
  drawer:draw_rect(1+x, 3+y, 2, 2,
      pressed['LEFT'] and theme.DPAD_PRESSED or theme.DPAD_RELEASED)
  drawer:draw_rect(3+x, 1+y, 2, 2,
      pressed['UP'] and theme.DPAD_PRESSED or theme.DPAD_RELEASED)
  drawer:draw_rect(5+x, 3+y, 2, 2,
      pressed['RIGHT'] and theme.DPAD_PRESSED or theme.DPAD_RELEASED)
  drawer:draw_rect(3+x, 5+y, 2, 2,
      pressed['DOWN'] and theme.DPAD_PRESSED or theme.DPAD_RELEASED)
end

function draw_buttons(drawer, x, y, pressed, theme)
  if theme.COMPACT_BUTTONS then
    offset = 3
  else
    -- accurately spaced
    offset = 4
  end
  drawer:draw_button(0+x, offset+y, theme.Y_BORDER,
      pressed['Y'] and theme.Y_PRESSED or theme.Y_RELEASED)
  drawer:draw_button(offset + x, y, theme.X_BORDER,
      pressed['X'] and theme.X_PRESSED or theme.X_RELEASED)
  drawer:draw_button(2*offset + x, offset + y, theme.A_BORDER,
      pressed['A'] and theme.A_PRESSED or theme.A_RELEASED)
  drawer:draw_button(offset + x, 2*offset + y, theme.B_BORDER,
      pressed['B'] and theme.B_PRESSED or theme.B_RELEASED)
end

function draw_select_and_start(drawer, x, y, pressed, theme)
  drawer:draw_slanted_button(x, y, theme.SELECT_BORDER,
      pressed['SELECT'] and theme.SELECT_PRESSED or theme.SELECT_RELEASED)
  drawer:draw_slanted_button(5+x, y, theme.START_BORDER,
      pressed['START'] and theme.START_PRESSED or theme.START_RELEASED)
end

function draw_L_button(drawer, x, y, pressed, theme) 
  drawer:draw_rect(x, y+3, 1, 1, theme.L_BORDER)  -- L top border left col
  drawer:draw_rect(x+1, y+2, 1, 1, theme.L_BORDER)  -- next col
  drawer:draw_rect(x+2, y+1, 2, 1, theme.L_BORDER)  -- next 2 cols
  drawer:draw_rect(x+4, y, 7, 1, theme.L_BORDER)  -- next 7 cols
  drawer:draw_rect(x+11, y+1, 1, 1, theme.L_BORDER)  -- last col
  drawer:draw_rect(x+4, y+2, 7, 1, theme.L_BORDER)  -- L bottom border
  drawer:draw_rect(x+2, y+3, 2, 1, theme.L_BORDER)  -- next 2 left
  drawer:draw_rect(x+1, y+4, 1, 1, theme.L_BORDER)  -- next 2 left

  color = pressed['L'] and theme.L_PRESSED or theme.L_RELEASED
  drawer:draw_rect(x+1, y+3, 1, 1, color)
  drawer:draw_rect(x+2, y+2, 2, 1, color)
  drawer:draw_rect(x+4, y+1, 7, 1, color)
end

function draw_R_button(drawer, x, y, pressed, theme)
  drawer:draw_rect(x, y+1, 1, 1, theme.R_BORDER)  -- R top border left col
  drawer:draw_rect(x+1, y, 7, 1, theme.R_BORDER)  -- next 7 cols
  drawer:draw_rect(x+8, y+1, 2, 1, theme.R_BORDER)  -- next 2 cols
  drawer:draw_rect(x+10, y+2, 1, 1, theme.R_BORDER)  -- next col
  drawer:draw_rect(x+11, y+3, 1, 1, theme.R_BORDER)  -- last col
  drawer:draw_rect(x+1, y+2, 7, 1, theme.R_BORDER)  -- R bottom border
  drawer:draw_rect(x+8, y+3, 2, 1, theme.R_BORDER)  --next 2 right
  drawer:draw_rect(x+10, y+4, 1, 1, theme.R_BORDER)  --next 2 right

  color = pressed['R'] and theme.R_PRESSED or theme.R_RELEASED
  drawer:draw_rect(x+1, y+1, 7, 1, color)
  drawer:draw_rect(x+8, y+2, 2, 1, color)
  drawer:draw_rect(x+10, y+3, 1, 1, color)
end

function draw_snes_buttons(drawer, x, y, pressed, theme)
  draw_dpad(drawer, x+2, y+8, pressed, theme)
  draw_select_and_start(drawer, x+13, x+12, pressed, theme)
  draw_buttons(drawer, x+25, y+6, pressed, theme)
  draw_L_button(drawer, x, y, pressed, theme)
  draw_R_button(drawer, x+25, y, pressed, theme)
end

function draw_snes_controller_shell(drawer, x, y, theme)
  -- TAKE 2 away from Y
  -- face (expects border to overlap it, to do this with fewer rectangles)
  drawer:draw_rect(x+8, y+1, 29, 1, theme.FACE)  -- top row of face
  drawer:draw_rect(x+5, y+2, 35, 15, theme.FACE)  -- main-section of face
  drawer:draw_rect(x+6, y+17, 8, 2, theme.FACE)  -- left-lower face
  drawer:draw_rect(x+31, y+17, 8, 2, theme.FACE)  -- right-lower face
  drawer:draw_rect(x+3, y+3, 2, 14, theme.FACE) -- left of dpad face
  drawer:draw_rect(x+40, y+3, 2, 14, theme.FACE) -- right of button face
  drawer:draw_rect(x+1, y+5, 2, 10, theme.FACE) -- left edge face
  drawer:draw_rect(x+42, y+5, 2, 10, theme.FACE) -- right edge face

  -- border
  drawer:draw_rect(x+8, y, 29, 1, theme.BORDER)  -- top border
  drawer:draw_rect(x+6, y+1, 2, 1, theme.BORDER)  -- next 2 left
  drawer:draw_rect(x+37, y+1, 2, 1, theme.BORDER)  --next 2 right
  drawer:draw_rect(x+4, y+2, 2, 1, theme.BORDER)  -- next 2 left
  drawer:draw_rect(x+39, y+2, 2, 1, theme.BORDER)  --next 2 right
  drawer:draw_rect(x+3, y+3, 1, 1, theme.BORDER)  -- next 1 left
  drawer:draw_rect(x+41, y+3, 1, 1, theme.BORDER)  --next 1 right
  drawer:draw_rect(x+2, y+4, 1, 1, theme.BORDER)  -- next 1 left
  drawer:draw_rect(x+42, y+4, 1, 1, theme.BORDER)  --next 1 right
  drawer:draw_rect(x+1, y+5, 1, 2, theme.BORDER)  -- next 2 left
  drawer:draw_rect(x+43, y+5, 1, 2, theme.BORDER)  --next 2 right
  drawer:draw_rect(x+0, y+7, 1, 6, theme.BORDER)  -- next 6 left
  drawer:draw_rect(x+44, y+7, 1, 6, theme.BORDER)  --next 6 right
  drawer:draw_rect(x+1, y+13, 1, 2, theme.BORDER)  -- next 2 left
  drawer:draw_rect(x+43, y+13, 1, 2, theme.BORDER)  --next 2 right
  drawer:draw_rect(x+2, y+15, 1, 1, theme.BORDER)  -- next 1 left
  drawer:draw_rect(x+42, y+15, 1, 1, theme.BORDER)  --next 1 right
  drawer:draw_rect(x+3, y+16, 1, 1, theme.BORDER)  -- next 1 left
  drawer:draw_rect(x+41, y+16, 1, 1, theme.BORDER)  --next 1 right
  -- going down the curved lower ends
  drawer:draw_rect(x+4, y+17, 2, 1, theme.BORDER)  -- next 2 left-left
  drawer:draw_rect(x+14, y+17, 2, 1, theme.BORDER)  -- next 2 left-right
  drawer:draw_rect(x+29, y+17, 2, 1, theme.BORDER)  -- next 2 right-left
  drawer:draw_rect(x+39, y+17, 2, 1, theme.BORDER)  -- next 2 right-right
  drawer:draw_rect(x+6, y+18, 2, 1, theme.BORDER)  -- next 2 left-left
  drawer:draw_rect(x+12, y+18, 2, 1, theme.BORDER)  -- next 2 left-right
  drawer:draw_rect(x+31, y+18, 2, 1, theme.BORDER)  -- next 2 right-left
  drawer:draw_rect(x+37, y+18, 2, 1, theme.BORDER)  -- next 2 right-right
  -- final edges
  drawer:draw_rect(x+16, y+16, 13, 1, theme.BORDER)  -- mid-lower border
  drawer:draw_rect(x+8, y+19, 4, 1, theme.BORDER)  -- left-lower border
  drawer:draw_rect(x+33, y+19, 4, 1, theme.BORDER)  -- right-lower border
end

function draw_snes_button_ring(drawer, x, y, theme)
  -- TOP-RIGHT
  drawer:draw_rect(x+6, y, 4, 1, theme.BUTTON_RING)  -- N
  drawer:draw_rect(x+9, y+1, 3, 1, theme.BUTTON_RING)  -- next row down
  drawer:draw_rect(x+10, y+2, 3, 1, theme.BUTTON_RING)  -- next row down
  drawer:draw_rect(x+11, y+3, 2, 2, theme.BUTTON_RING)  -- middle NE
  drawer:draw_rect(x+13, y+3, 1, 3, theme.BUTTON_RING)  -- next col right
  drawer:draw_rect(x+14, y+4, 1, 3, theme.BUTTON_RING)  -- next col right
  -- RIGHT-BOTTOM
  drawer:draw_rect(x+15, y+6, 1, 4, theme.BUTTON_RING)  -- E
  drawer:draw_rect(x+14, y+9, 1, 3, theme.BUTTON_RING)  -- next col left
  drawer:draw_rect(x+13, y+10, 1, 3, theme.BUTTON_RING)  -- next col left
  drawer:draw_rect(x+12, y+11, 1, 3, theme.BUTTON_RING)  -- next col left
  drawer:draw_rect(x+11, y+12, 1, 3, theme.BUTTON_RING)  -- next col left
  drawer:draw_rect(x+10, y+13, 1, 2, theme.BUTTON_RING)  -- next col left
  drawer:draw_rect(x+9, y+14, 1, 1, theme.BUTTON_RING)  -- next pixel left
  -- BOTTOM-LEFT
  drawer:draw_rect(x+6, y+15, 4, 1, theme.BUTTON_RING)  -- S
  drawer:draw_rect(x+4, y+14, 3, 1, theme.BUTTON_RING)  -- next row up
  drawer:draw_rect(x+3, y+13, 3, 1, theme.BUTTON_RING)  -- next row up
  drawer:draw_rect(x+3, y+11, 2, 2, theme.BUTTON_RING)  -- middle SW
  drawer:draw_rect(x+2, y+10, 1, 3, theme.BUTTON_RING)  -- next col left
  drawer:draw_rect(x+1, y+9, 1, 3, theme.BUTTON_RING)  -- next col left
  -- LEFT-TOP
  drawer:draw_rect(x, y+6, 1, 4, theme.BUTTON_RING)  -- W
  drawer:draw_rect(x+1, y+4, 1, 3, theme.BUTTON_RING)  -- next col right
  drawer:draw_rect(x+2, y+3, 1, 3, theme.BUTTON_RING)  -- next col right
  drawer:draw_rect(x+3, y+2, 1, 3, theme.BUTTON_RING)  -- next col right
  drawer:draw_rect(x+4, y+1, 1, 3, theme.BUTTON_RING)  -- next col right
  drawer:draw_rect(x+5, y+1, 1, 2, theme.BUTTON_RING)  -- next col right
  drawer:draw_rect(x+6, y+1, 1, 1, theme.BUTTON_RING)  -- next pixel right
  -- DIVIDER
  drawer:draw_rect(x+5, y+10, 1, 1, theme.BUTTON_RING) -- bottom left
  drawer:draw_rect(x+6, y+9, 1, 1, theme.BUTTON_RING)
  drawer:draw_rect(x+7, y+8, 1, 1, theme.BUTTON_RING)
  drawer:draw_rect(x+8, y+7, 1, 1, theme.BUTTON_RING)
  drawer:draw_rect(x+9, y+6, 1, 1, theme.BUTTON_RING)
  drawer:draw_rect(x+10, y+5, 1, 1, theme.BUTTON_RING) -- top right
end

function draw_snes_dpad_ring(drawer, x, y, theme)
  drawer:draw_rect(x+4, 6, 4, 1, theme.DPAD_RING)  -- N
  drawer:draw_rect(x+8, 7, 2, 1, theme.DPAD_RING)  -- N NE
  drawer:draw_rect(x+10, 8, 1, 2, theme.DPAD_RING)  -- E NE
  drawer:draw_rect(x+11, 10, 1, 4, theme.DPAD_RING)  -- E
  drawer:draw_rect(x+10, 14, 1, 2, theme.DPAD_RING)  -- E SE
  drawer:draw_rect(x+8, 16, 2, 1, theme.DPAD_RING)  -- S SE
  drawer:draw_rect(x+4, 17, 4, 1, theme.DPAD_RING)  -- S
  drawer:draw_rect(x+2, 16, 2, 1, theme.DPAD_RING)  -- S SW
  drawer:draw_rect(x+1, 14, 1, 2, theme.DPAD_RING)  -- W SW
  drawer:draw_rect(x, 10, 1, 4, theme.DPAD_RING)  -- W
  drawer:draw_rect(x+1, 8, 1, 2, theme.DPAD_RING)  -- W NW
  drawer:draw_rect(x+2, 7, 2, 1, theme.DPAD_RING)  -- N NW
end

function draw_snes_dpad_area(drawer, x, y, theme)
  drawer:draw_rect(x+1, y+1, 8, 8, theme.DPAD_AREA)  -- main area
  drawer:draw_rect(x, y+3, 1, 4, theme.DPAD_AREA)  -- left
  drawer:draw_rect(x+3, y, 4, 1, theme.DPAD_AREA)  -- top
  drawer:draw_rect(x+9, y+3, 1, 4, theme.DPAD_AREA)  -- right
  drawer:draw_rect(x+3, y+9, 4, 1, theme.DPAD_AREA)  -- bottom
end
function draw_snes_button_area(drawer, x, y, theme)
  return nil
end
return {
  SNES = SNES,
  draw_button = draw_button,
  draw_slanted_button = draw_slanted_button,
  draw_dpad = draw_dpad,
  draw_buttons = draw_buttons,
  draw_select_and_start = draw_select_and_start,
  draw_L_button = draw_L_button,
  draw_R_button = draw_R_button,
  draw_snes_controller_shell = draw_snes_controller_shell,
  draw_snes_button_ring = draw_snes_button_ring,
  draw_snes_dpad_ring = draw_snes_dpad_ring,
  draw_snes_dpad_area = draw_snes_dpad_area,
  draw_snes_button_area = draw_snes_button_area,
}
