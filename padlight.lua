local THIS_DIR = (... or ''):match("(.-)[^%.]+$") or '.'
local gfx = require(THIS_DIR .. 'gfx')
local util = require(THIS_DIR .. 'util.util')
local LIP = require(THIS_DIR .. 'util.LIP')
local class = require(THIS_DIR .. 'util.class')

function parse_color_string(color_string)
  if color_string:sub(1,1) == '#' then
    len = color_string:len()
    if len == 7 or len == 9 then
      -- all the sub indexes seem stupid, because lua
      red = tonumber(color_string:sub(2, 3), 16)
      green = tonumber(color_string:sub(4, 5), 16)
      blue = tonumber(color_string:sub(6, 7), 16)
      if len > 7 then
        alpha = tonumber(color_string:sub(8, 9), 16)
      else
        alpha = 0xFF
      end
      return util.RGBA(red, green, blue, alpha)
    end
  end
  return nil
end
function lowercase_table_keys(tbl)
  new_table = {}
  for key, value in pairs(tbl) do
    new_table[string.lower(key)] = value
  end
  return new_table
end

ProxyTable=class()
function ProxyTable:__init(table_A, table_B)
  self.table_A = table_A
  self.table_B = table_B
end
function ProxyTable:get(key)
  value = self.table_A[key]
  if value == nil then
    value = self.table_B[key]
  end
  return value
end

Overlay = class()
function Overlay:__init()
  self:clear()
end
function Overlay:clear()
  self.drawer = nil
  self.button_default = {}
  self.preferences = {}
  self.palette = {}
  self.buttons = {}
  self.pressed = {}
end

function Overlay:set_pressed(pressed)
  self.pressed = lowercase_table_keys(pressed)
end
function Overlay:load_config(config_filepath)
  -- Load the config
  ini_data = LIP.load(config_filepath)
  self:clear()
  for section, data in pairs(ini_data) do
    section = string.lower(section)
    if section == 'palette' then
      for color_name, color_string in pairs(data) do
        color = parse_color_string(color_string)
        if color ~= nil then
          self.palette[color_name] = color
        else
          error('Color not in correct format: ' .. color_name .. '=' .. color_string)
        end
      end
    elseif section == 'preferences' then
      self.preferences = lowercase_table_keys(data)
    elseif section == 'default' then
      self.button_default = lowercase_table_keys(data)
    else
      -- this is a button
      config = lowercase_table_keys(data)
      if not config.button then
        config.button = section  -- default to the section name
      end
      self.buttons[section] = config
    end
  end
  self.drawer = gfx.ScaledDrawer(
      self.preferences.x, self.preferences.y, self.preferences.scale)
end
function Overlay:get_color(color_string)
  local color = parse_color_string(color_string)
  if color == nil then
    color = self.palette[color_string]
  end
  return color
end
function Overlay:draw_button(name)
  local name = string.lower(name)
  local config = ProxyTable(self.buttons[name], self.button_default)
  local x = config:get('x')
  local y = config:get('y')
  local width = config:get('width')
  local height = config:get('height')
  local button_name = config:get('button')
  if self.pressed[button_name] then
    color = self:get_color(config:get('pressed'))
  else
    color = self:get_color(config:get('released'))
  end
  local border = self:get_color(config:get('border'))
  local border_width = config:get('border_width')
  local border_nw = config:get('border_nw') and border_width or 0
  local border_ne = config:get('border_ne') and border_width or 0
  local border_se = config:get('border_se') and border_width or 0
  local border_sw = config:get('border_sw') and border_width or 0

  -- left
  self.drawer:draw_rect(x - border_width, y, border_width, height, border)
  -- right
  self.drawer:draw_rect(x + width, y, border_width, height, border)
  -- top/corners
  self.drawer:draw_rect(x - border_nw, y - border_width,
      width + border_nw + border_ne, border_width, border)
  -- bottom/corners
  self.drawer:draw_rect(x - border_sw, y + height,
      width + border_sw + border_se, border_width, border)
  -- button
  self.drawer:draw_rect(x, y, width, height, color)
end
function Overlay:draw()
  for name, config in pairs(self.buttons) do
    self:draw_button(name)
  end
end

-- TODO: rip out shell stuff, put in an image somehow?  snes9x support?  gd?
function Overlay:draw_snes_controller_shell(x, y)
  border_color = util.RGBA(0x00, 0x00, 0x00, 0xFF)
  face_color = util.RGBA(0xB0, 0xB2, 0xB1, 0xFF)
  dark_face_color = util.RGBA(0x67, 0x6C, 0x6F, 0xFF)

  -- face (expects border to overlap it, to do this with fewer rectangles)
  self.drawer:draw_rect(x+8, y+1, 29, 1, face_color)  -- top row of face
  self.drawer:draw_rect(x+5, y+2, 35, 15, face_color)  -- main-section of face
  self.drawer:draw_rect(x+6, y+17, 8, 2, face_color)  -- left-lower face
  self.drawer:draw_rect(x+31, y+17, 8, 2, face_color)  -- right-lower face
  self.drawer:draw_rect(x+3, y+3, 2, 14, face_color) -- left of dpad face
  self.drawer:draw_rect(x+40, y+3, 2, 14, face_color) -- right of button face
  self.drawer:draw_rect(x+1, y+5, 2, 10, face_color) -- left edge face
  self.drawer:draw_rect(x+42, y+5, 2, 10, face_color) -- right edge face

  -- border
  self.drawer:draw_rect(x+8, y, 29, 1, border_color)  -- top border
  self.drawer:draw_rect(x+6, y+1, 2, 1, border_color)  -- next 2 left
  self.drawer:draw_rect(x+37, y+1, 2, 1, border_color)  --next 2 right
  self.drawer:draw_rect(x+4, y+2, 2, 1, border_color)  -- next 2 left
  self.drawer:draw_rect(x+39, y+2, 2, 1, border_color)  --next 2 right
  self.drawer:draw_rect(x+3, y+3, 1, 1, border_color)  -- next 1 left
  self.drawer:draw_rect(x+41, y+3, 1, 1, border_color)  --next 1 right
  self.drawer:draw_rect(x+2, y+4, 1, 1, border_color)  -- next 1 left
  self.drawer:draw_rect(x+42, y+4, 1, 1, border_color)  --next 1 right
  self.drawer:draw_rect(x+1, y+5, 1, 2, border_color)  -- next 2 left
  self.drawer:draw_rect(x+43, y+5, 1, 2, border_color)  --next 2 right
  self.drawer:draw_rect(x+0, y+7, 1, 6, border_color)  -- next 6 left
  self.drawer:draw_rect(x+44, y+7, 1, 6, border_color)  --next 6 right
  self.drawer:draw_rect(x+1, y+13, 1, 2, border_color)  -- next 2 left
  self.drawer:draw_rect(x+43, y+13, 1, 2, border_color)  --next 2 right
  self.drawer:draw_rect(x+2, y+15, 1, 1, border_color)  -- next 1 left
  self.drawer:draw_rect(x+42, y+15, 1, 1, border_color)  --next 1 right
  self.drawer:draw_rect(x+3, y+16, 1, 1, border_color)  -- next 1 left
  self.drawer:draw_rect(x+41, y+16, 1, 1, border_color)  --next 1 right
  -- going down the curved lower ends
  self.drawer:draw_rect(x+4, y+17, 2, 1, border_color)  -- next 2 left-left
  self.drawer:draw_rect(x+14, y+17, 2, 1, border_color)  -- next 2 left-right
  self.drawer:draw_rect(x+29, y+17, 2, 1, border_color)  -- next 2 right-left
  self.drawer:draw_rect(x+39, y+17, 2, 1, border_color)  -- next 2 right-right
  self.drawer:draw_rect(x+6, y+18, 2, 1, border_color)  -- next 2 left-left
  self.drawer:draw_rect(x+12, y+18, 2, 1, border_color)  -- next 2 left-right
  self.drawer:draw_rect(x+31, y+18, 2, 1, border_color)  -- next 2 right-left
  self.drawer:draw_rect(x+37, y+18, 2, 1, border_color)  -- next 2 right-right
  -- final edges
  self.drawer:draw_rect(x+16, y+16, 13, 1, border_color)  -- mid-lower border
  self.drawer:draw_rect(x+8, y+19, 4, 1, border_color)  -- left-lower border
  self.drawer:draw_rect(x+33, y+19, 4, 1, border_color)  -- right-lower border
end

function Overlay:draw_snes_button_ring(x, y)
  -- TOP-RIGHT
  self.drawer:draw_rect(x+6, y, 4, 1, dark_face_color)  -- N
  self.drawer:draw_rect(x+9, y+1, 3, 1, dark_face_color)  -- next row down
  self.drawer:draw_rect(x+10, y+2, 3, 1, dark_face_color)  -- next row down
  self.drawer:draw_rect(x+11, y+3, 2, 2, dark_face_color)  -- middle NE
  self.drawer:draw_rect(x+13, y+3, 1, 3, dark_face_color)  -- next col right
  self.drawer:draw_rect(x+14, y+4, 1, 3, dark_face_color)  -- next col right
  -- RIGHT-BOTTOM
  self.drawer:draw_rect(x+15, y+6, 1, 4, dark_face_color)  -- E
  self.drawer:draw_rect(x+14, y+9, 1, 3, dark_face_color)  -- next col left
  self.drawer:draw_rect(x+13, y+10, 1, 3, dark_face_color)  -- next col left
  self.drawer:draw_rect(x+12, y+11, 1, 3, dark_face_color)  -- next col left
  self.drawer:draw_rect(x+11, y+12, 1, 3, dark_face_color)  -- next col left
  self.drawer:draw_rect(x+10, y+13, 1, 2, dark_face_color)  -- next col left
  self.drawer:draw_rect(x+9, y+14, 1, 1, dark_face_color)  -- next pixel left
  -- BOTTOM-LEFT
  self.drawer:draw_rect(x+6, y+15, 4, 1, dark_face_color)  -- S
  self.drawer:draw_rect(x+4, y+14, 3, 1, dark_face_color)  -- next row up
  self.drawer:draw_rect(x+3, y+13, 3, 1, dark_face_color)  -- next row up
  self.drawer:draw_rect(x+3, y+11, 2, 2, dark_face_color)  -- middle SW
  self.drawer:draw_rect(x+2, y+10, 1, 3, dark_face_color)  -- next col left
  self.drawer:draw_rect(x+1, y+9, 1, 3, dark_face_color)  -- next col left
  -- LEFT-TOP
  self.drawer:draw_rect(x, y+6, 1, 4, dark_face_color)  -- W
  self.drawer:draw_rect(x+1, y+4, 1, 3, dark_face_color)  -- next col right
  self.drawer:draw_rect(x+2, y+3, 1, 3, dark_face_color)  -- next col right
  self.drawer:draw_rect(x+3, y+2, 1, 3, dark_face_color)  -- next col right
  self.drawer:draw_rect(x+4, y+1, 1, 3, dark_face_color)  -- next col right
  self.drawer:draw_rect(x+5, y+1, 1, 2, dark_face_color)  -- next col right
  self.drawer:draw_rect(x+6, y+1, 1, 1, dark_face_color)  -- next pixel right
  -- DIVIDER
  self.drawer:draw_rect(x+5, y+10, 1, 1, dark_face_color) -- bottom left
  self.drawer:draw_rect(x+6, y+9, 1, 1, dark_face_color)
  self.drawer:draw_rect(x+7, y+8, 1, 1, dark_face_color)
  self.drawer:draw_rect(x+8, y+7, 1, 1, dark_face_color)
  self.drawer:draw_rect(x+9, y+6, 1, 1, dark_face_color)
  self.drawer:draw_rect(x+10, y+5, 1, 1, dark_face_color) -- top right
end

function Overlay:draw_snes_dpad_ring(x, y)
  self.drawer:draw_rect(x+4, 6, 4, 1, dark_face_color)  -- N
  self.drawer:draw_rect(x+8, 7, 2, 1, dark_face_color)  -- N NE
  self.drawer:draw_rect(x+10, 8, 1, 2, dark_face_color)  -- E NE
  self.drawer:draw_rect(x+11, 10, 1, 4, dark_face_color)  -- E
  self.drawer:draw_rect(x+10, 14, 1, 2, dark_face_color)  -- E SE
  self.drawer:draw_rect(x+8, 16, 2, 1, dark_face_color)  -- S SE
  self.drawer:draw_rect(x+4, 17, 4, 1, dark_face_color)  -- S
  self.drawer:draw_rect(x+2, 16, 2, 1, dark_face_color)  -- S SW
  self.drawer:draw_rect(x+1, 14, 1, 2, dark_face_color)  -- W SW
  self.drawer:draw_rect(x, 10, 1, 4, dark_face_color)  -- W
  self.drawer:draw_rect(x+1, 8, 1, 2, dark_face_color)  -- W NW
  self.drawer:draw_rect(x+2, 7, 2, 1, dark_face_color)  -- N NW
end

return {
  draw_snes_controller_shell = draw_snes_controller_shell,
  Overlay = Overlay,
}
