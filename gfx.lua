local THIS_DIR = (... or ''):match("(.-)[^%.]+$") or '.'

local class = require(THIS_DIR .. 'util.class')
local util = require(THIS_DIR .. 'util.util')

ScaledDrawer = class()
function ScaledDrawer:__init(x, y, scale)
  self.x = x
  self.y = y
  self.scale = scale
end

function ScaledDrawer:draw_rect(x, y, width, height, color)
  width = width * self.scale
  height = height * self.scale
  if width == 0 or height == 0 then
    return
  end
  x = self.x + x * self.scale
  y = self.y + y * self.scale
  if width == 1 and height == 1 then
    util.drawPixel(x, y, color)
  else
    x2 = x + width - 1
    y2 = y + height - 1
    if width == 1 or height == 1 then
      util.drawLine(x, y, x2, y2, color)
    else
      util.drawBox(x, y, x2, y2, color, color)
    end
  end
end
function ScaledDrawer:draw_cross(x, y, border_color,
    left_color, top_color, right_color, bottom_color)
  drawer:draw_rect(0+x, 2+y, 8, 4, border_color)
  drawer:draw_rect(2+x, 0+y, 4, 8, border_color)
  drawer:draw_rect(1+x, 3+y, 2, 2, left_color)
  drawer:draw_rect(3+x, 1+y, 2, 2, top_color)
  drawer:draw_rect(5+x, 3+y, 2, 2, right_color)
  drawer:draw_rect(3+x, 5+y, 2, 2, bottom_color)
end
function ScaledDrawer:draw_button(x, y, border_color, color)
  drawer:draw_rect(0+x, 1+y, 4, 2, border_color)
  drawer:draw_rect(1+x, 0+y, 2, 4, border_color)
  drawer:draw_rect(1+x, 1+y, 2, 2, color)
end
function ScaledDrawer:draw_simple_buttons(x, y, border_color,
    left_color, top_color, right_color, bottom_color)

  drawer:draw_button(0+x, 3+y, border_color, left_color)
  drawer:draw_button(3+x, 0+y, border_color, top_color)
  drawer:draw_button(6+x, 3+y, border_color, right_color)
  drawer:draw_button(3+x, 6+y, border_color, bottom_color)
end
function ScaledDrawer:draw_slanted_button(x, y, border_color, color)
  drawer:draw_rect(0+x, 2+y, 2, 2, border_color)
  drawer:draw_rect(1+x, 1+y, 2, 2, border_color)
  drawer:draw_rect(2+x, 0+y, 2, 2, border_color)
  drawer:draw_rect(1+x, 2+y, 1, 1, color)
  drawer:draw_rect(2+x, 1+y, 1, 1, color)
end
function ScaledDrawer:draw_shoulder_button(x, y, border_color, color)
  drawer:draw_rect(1+x, 0+y, 3, 3, border_color)
  drawer:draw_rect(0+x, 1+y, 5, 1, border_color)
  drawer:draw_rect(1+x, 1+y, 3, 1, color)
end

return {
  ScaledDrawer = ScaledDrawer,
}

